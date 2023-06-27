//
//  PostViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/12.
//

import Foundation
import Photos
import Combine

class UploadPostViewModel{
    
    struct Input {
        let startUpload: AnySubscriber<Void,Never>
        let cancelUpload: AnySubscriber<Void,Never>
    }
    
    struct Output {
        let uploadProgress: AnyPublisher<Double,Never>
        let uploadSuccess: AnyPublisher<Void,Never>
        let uploadError: AnyPublisher<String,Never>
    }

    private(set) var input: Input!
    private(set) var output: Output!
    private var subscriptions = Set<AnyCancellable>()
    
    private var mediaManager: (MediaCompressing & MediaUploading)!
    private var postManager: PostManaging!
    private let postText: String
    private let postAssets: [PHAsset]
    
    init(assets: [PHAsset], text: String){
        self.postText = text
        self.postAssets = assets
        postManager = PostManager()
        mediaManager = MediaManager()
        configureInput()
    }
    
    let uploadSuccessSubject = PassthroughSubject<Bool,Never>()
    let uploadErrorSubject = PassthroughSubject<String,Never>()
    let uploadProgressSubject = PassthroughSubject<Double,Never>()
    
    private var uploadingTask: Task<Any,Error>?

    private func configureInput(){
        
        let uploadSubject = PassthroughSubject<Void,Never>()
        
        uploadSubject
            .flatMap{
                Future{ promise in
                    Task{
                        do{
                            try await self.uploadPost(assets: self.postAssets)
                            promise(.success(true))
                        }catch{
                            var errorMessage: String
                            switch error{
                            case UploadError.failedToFetchImageURL:
                                errorMessage = "無法讀取用戶照片"
                            case UploadError.failedToFetchVideoURL:
                                errorMessage = "無法讀取用戶影片"
                            
                            default:
                                print(error)
                                errorMessage = "Unkown error when uploading"
                            }
                            self.uploadErrorSubject.send(errorMessage)
                            promise(.success(false))
                        }
                    }
                }
            }
            .filter{$0}
            .subscribe(uploadSuccessSubject)
            .store(in: &subscriptions)
        
        uploadSuccessSubject.sink { _ in
            print("upload success :)")
        }.store(in: &subscriptions)
        input = Input(startUpload: uploadSubject.eraseToAnySubscriber(),
                      cancelUpload: uploadSubject.eraseToAnySubscriber())
    }
    
    private func uploadPost(assets: [PHAsset]) async throws {
        let mediaAssets = try await self.convertToMediaAssets(assets: assets)
        let post = Post(userID: "", media: mediaAssets, text: postText)
        try postManager.addNewPost(post)
    }
    
    private func convertToMediaAssets(assets: [PHAsset]) async throws -> [MediaAsset]{
        
        var tuples = [(asset: PHAsset, url: URL)]()
        
        try await withThrowingTaskGroup(of: (PHAsset,URL).self){ group in
            
            assets.forEach{ asset in
                switch asset.mediaType {
                case .image:
                    group.addTask {
                        let imageURL = try await self.fetchImageURL(from: asset)
                        let localURL = try await self.mediaManager.compressImage(from: imageURL)
                        let remoteURL = try await self.mediaManager.uploadImage(from: localURL,progressHandler: nil)
                        return (asset, remoteURL)
                    }
                case .video:
                    group.addTask {
                        let videoURL = try await self.fetchVideoURL(from: asset)
                        let localURL = try await self.mediaManager.compressVideo(from: videoURL, progressHandler: nil)
                        let remoteURL = try await self.mediaManager.uploadVideo(from: localURL, progressHandler: nil)
                        return (asset, remoteURL)
                    }
                default: fatalError("Unsupported upload media type '\(String(describing: asset.mediaType))'")
                }
            }
            
            for try await tuple in group {
                tuples.append(tuple)
            }
        }
        
        let sortedTuples = assets.map{ asset in
            tuples.first{$0.asset.localIdentifier == asset.localIdentifier}!
        }
        
        let mediaAssets = sortedTuples.map { (asset,url) in
            MediaAsset(type: asset.mediaType == .video ? .video : .photo,
                      dimensions: .init(width: asset.pixelWidth, height: asset.pixelHeight),
                      url: url.absoluteString)
        }
        
        return mediaAssets
    }
    
    
}

// MARK: - Fetch Media URL from Photo Library
extension UploadPostViewModel{
    
    private func fetchImageURL(from asset: PHAsset) async throws -> URL{
        
        try await withCheckedThrowingContinuation{ continuation in
            
            let options = PHContentEditingInputRequestOptions()
            
            asset.requestContentEditingInput(with: options){ eidtingInput, info in
                if let input = eidtingInput, let imageUrl = input.fullSizeImageURL {
                    continuation.resume(returning: imageUrl)
                }else{
                    continuation.resume(throwing: UploadError.failedToFetchVideoURL)
                }
            }
        }
    }
    
    private func fetchVideoURL(from asset: PHAsset) async throws -> URL{
        
        try await withCheckedThrowingContinuation{ continuation in
            let options = PHVideoRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
       
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options){ avAsset,_,_ in
                if let videoAsset = avAsset as? AVURLAsset {
                    continuation.resume(returning: videoAsset.url)
                }else{
                    continuation.resume(throwing: UploadError.failedToFetchVideoURL)
                }
            }
        }
    }
}
// MARK: - To be deleted
extension UploadPostViewModel{
//    private func loadImage(from asset: PHAsset) async throws -> UIImage {
//
//        try await withCheckedThrowingContinuation{ continuation in
//            let options = PHImageRequestOptions()
//            options.deliveryMode = .highQualityFormat
//            options.isNetworkAccessAllowed = true
//            options.resizeMode = .exact
//
//            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { image, info in
//                if let image = image{
//                    continuation.resume(returning: image)
//                }else{
//                    continuation.resume(throwing: UploadError.failedToFetchImageURL)
//                }
//            }
//        }
//    }
//
//    private func loadVideo(from asset: PHAsset) async throws -> AVAsset{
//
//        try await withCheckedThrowingContinuation{ continuation in
//            let options = PHVideoRequestOptions()
//            options.deliveryMode = .highQualityFormat
//            options.isNetworkAccessAllowed = true
//
//            PHImageManager.default().requestAVAsset(forVideo: asset, options: options){ videoAsset,_,_ in
//                if let videoAsset = videoAsset{
//                    continuation.resume(returning: videoAsset)
//                }else{
//                    continuation.resume(throwing: UploadError.failedToFetchVideoURL)
//                }
//            }
//        }
//    }
//
//    private func uploadMedia(for assets: [PHAsset]) async throws -> [(PHAsset,URL)] {
//        var tuples = [(asset: PHAsset, url: URL)]()
//
//        try await withThrowingTaskGroup(of: (PHAsset,URL).self){ group in
//
//            assets.forEach{ asset in
//                switch asset.mediaType{
//                case .image:
//                    group.addTask {
//                        let imageURL = try await self.fetchImageURL(from: asset)
//                        let localURL = try await self.mediaManager.compressImage(from: imageURL)
//                        let remoteURL = try await self.mediaManager.uploadImage(from: localURL)
//                        return (asset, remoteURL)
//                    }
//                case .video:
//                    group.addTask {
//                        let videoURL = try await self.fetchVideoURL(from: asset)
//                        let localURL = try await self.mediaManager.compressVideo(from: videoURL)
//                        let remoteURL = try await self.mediaManager.uploadVideo(from: localURL)
//                        return (asset, remoteURL)
//                    }
//                default: fatalError("Unsupported upload media type '\(String(describing: asset.mediaType))'")
//                }
//            }
//
//            for try await tuple in group {
//                tuples.append(tuple)
//            }
//        }
//
//        let sortedTuples = assets.map{ asset in
//            tuples.first{$0.asset.localIdentifier == asset.localIdentifier}!
//        }
//        return sortedTuples
//    }
    
}


extension UploadPostViewModel{
    
    enum UploadError: Error {
        case failedToFetchImageURL
        case failedToFetchVideoURL
        case failedToCompressImage
        case failedToCompressVideo
        case failedToUploadPost
    }
}

