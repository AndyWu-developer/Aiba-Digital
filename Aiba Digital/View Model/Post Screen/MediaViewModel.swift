//
//  MediaViewModel.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/27.
//

import Foundation
import AVKit
import Combine

enum MediaType {
    case image
    case video
    case gif
    case unknown
}

class MediaViewModel{
   
    struct Input {
    
    }
    
    struct Output {
        let imageData: AnyPublisher<Data,Never>
        let videoAsset: AnyPublisher<AVAsset,Never>
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
  
    private var subscriptions = Set<AnyCancellable>()
    private var mediaType: MediaType?
    private var mediaURL: String
    private let mediaProvider: MediaProviding = MediaProvider.shared
    private let videoAssetSubject = CurrentValueSubject<AVAsset?, Never>(nil)
  
    let mediaContentSize: (width: Double, height: Double)
    
    init(url: String, fileExtension: String, contentSize: (width: Double, height: Double) = (1365,2048)){
        mediaContentSize = contentSize
        mediaType = fileExtension == ".mp4" ? .video : .image
        mediaURL = url
        if mediaType == .video{
            mediaProvider.fetchVideo(for: mediaURL)
                .compactMap{$0}
                .subscribe(videoAssetSubject)
                .store(in: &subscriptions)
        }
        configureViewModelOutput()
    }
   
    private func configureViewModelOutput(){
       
        var imageDataPublisher: AnyPublisher<Data,Never>
        if mediaType == .image{
            imageDataPublisher = mediaProvider.fetchImage(for:mediaURL)
                .replaceNil(with: Data())
                .eraseToAnyPublisher()
        }else{
            imageDataPublisher = mediaProvider.fetchVideoTumbnail(for:mediaURL)
                .replaceNil(with: Data())
                .eraseToAnyPublisher()
        }
        
        let videoAssetPublisher = videoAssetSubject.compactMap{$0}.eraseToAnyPublisher()
       
        output = Output(imageData: imageDataPublisher, videoAsset: videoAssetPublisher)
    }
    
    deinit{
        print("Media View Model deinit")
    }
}
