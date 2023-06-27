//
//  MediaManager.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/12.
//

import Foundation
import AVFoundation
import UIKit.UIImage

typealias progressHandler = ((Double) -> ())

protocol MediaDownloading: AnyObject {
    func fetchImageData(from url: URL, progressHandler: progressHandler?) async throws -> Data
    func fetchVideoTumbnail(from url: URL, progressHandler: progressHandler?) async throws -> Data
    func fetchVideo(from url: URL, progressHandler: progressHandler?) async throws -> AVURLAsset
}

protocol MediaUploading: AnyObject {
    func uploadImage(from url: URL, progressHandler: progressHandler?) async throws -> URL
    func uploadVideo(from url: URL, progressHandler: progressHandler?) async throws -> URL
    //TODO: uploadGif
}

protocol MediaCompressing: AnyObject {
    func compressVideo(from url: URL, progressHandler: progressHandler?) async throws -> URL
    func compressImage(from url: URL) async throws -> URL
}


final class MediaManager{
    
    private let uploadAPIKey: String = {
        let filePath = Bundle.main.path(forResource: "BunnyCDN-Info", ofType: "plist")!
        let plist = NSDictionary(contentsOfFile: filePath)!
        let value = plist.object(forKey: "API_KEY") as! String
        return value
    }()
    
    private let imageCompressor = ImageCompressor()
    private let videoCompressor = VideoCompressor()
  
    private let imageCache = NSCache<NSString, NSData>()
    private let videoCache = NSCache<NSString, AVURLAsset>()
}

// MARK: - MediaCompressing
extension MediaManager: MediaCompressing {
    
    enum MediaCompressError: Error { case cannotCompressVideo, cannotCompressImage }
    
    //When compressing image, do not wrapping the compressed cgImage to UIImage and convert to jpg will increase file size, save the cgImage to jpeg directly :)
    func compressImage(from url: URL) async throws -> URL {
       
        try await withCheckedThrowingContinuation { continuation in
            let id = UUID().uuidString
            let imageData = try! Data(contentsOf: url)
            print("image before compression: \(Double(imageData.count) / (1024 * 1024)) MB")
         
            imageCompressor.compressImage(from: url, maxDimentionInPixels: 1080){ image in
         
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                
                if let cgImage = image, let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, UTType.jpeg.identifier as CFString, 1, nil) {
                    CGImageDestinationAddImage(destination, cgImage, nil)
                    if CGImageDestinationFinalize(destination) {
                        let data = try! Data(contentsOf: fileURL)
                        print("image after compression: \(Double(data.count) / (1024 * 1024)) MB")
                        continuation.resume(returning: fileURL)
                    }else{
                        continuation.resume(throwing: MediaCompressError.cannotCompressImage)
                    }
                }else{
                    continuation.resume(throwing: MediaCompressError.cannotCompressImage)
                }
            }
        }

    }
    
    func compressVideo(from url: URL, progressHandler: progressHandler?) async throws -> URL {
        let asset = AVAsset(url: url)
        do{
            let url = try await videoCompressor.compress(asset: asset, progressHandler: progressHandler)
            return url
        }catch{
            print(error)
            throw MediaCompressError.cannotCompressVideo
        }
    }
    
}


// MARK: - MediaUploading
extension MediaManager: MediaUploading{
    
    enum MediaUploadError: Error { case uploadError }
    
    func uploadImage(from url: URL, progressHandler: progressHandler?) async throws -> URL{
        let id = UUID().uuidString
        let uploadURL = URL(string:"https://sg.storage.bunnycdn.com/storage0625/Post/\(id).jpg")!
        var request = URLRequest(url: uploadURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "PUT"
        request.setValue(uploadAPIKey, forHTTPHeaderField: "AccessKey")
        
        do{
            let (_, response) = try await URLSession.shared.upload(for: request, fromFile: url)
            let statusCode = (response as! HTTPURLResponse).statusCode
            if (200...299).contains(statusCode){
                print("upload sucess")
            }else{
                throw MediaUploadError.uploadError
            }
        }catch{
            print(error)
            throw error
        }
        
        return URL(string: "https://PullZone0625.b-cdn.net/Post/\(id).jpg")!
    }
    
    func uploadVideo(from url: URL, progressHandler: progressHandler?) async throws -> URL{
        let id = UUID().uuidString
        let uploadURL = URL(string:"https://sg.storage.bunnycdn.com/storage0625/Post/\(id).mp4")!
        var request = URLRequest(url: uploadURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "PUT"
        request.setValue(uploadAPIKey, forHTTPHeaderField: "AccessKey")
        
        do{
            let (_, response) = try await URLSession.shared.upload(for: request, fromFile: url)
            let statusCode = (response as! HTTPURLResponse).statusCode
            if (200...299).contains(statusCode){
                print("upload sucess")
            }else{
                throw MediaUploadError.uploadError
            }
        }catch{
            print(error)
            throw error
        }
        
        return URL(string: "https://PullZone0625.b-cdn.net/Post/\(id).mp4")!
    }
}
