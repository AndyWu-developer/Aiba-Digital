//
//  VideoViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/11.
//

import Foundation
import AVFoundation.AVAsset
import Combine

class VideoViewModel: MediaViewModel {
    
    override var contentPixelWidth: Int {
        videoAsset.dimensions.width
    }

    override var contentPixelHeight: Int {
        videoAsset.dimensions.height
    }
    
    struct Input { }
    
    struct Output {
        let videoData: AnyPublisher<AVAsset,Never>
        let videoThumbnail: AnyPublisher<Data,Never>
    }

    private(set) var input: Input!
    private(set) var output: Output!
    
    @Published private var videoAsset: MediaAsset
    private let videoProvider: MediaDownloading
 
    init(videoAsset: MediaAsset, videoProvider: MediaDownloading){
        self.videoAsset = videoAsset
        self.videoProvider = videoProvider
        super.init()
        configureOutput()
    }
    
    deinit{
        print("VideoViewModel deinit")
    }
    
    private func configureOutput(){

        let videoDataPublisher = $videoAsset
            .compactMap { URL(string: $0.url) }
            .flatMap{ videoURL -> AnyPublisher<AVURLAsset?,Never> in
                Deferred{
                    Future{ promise in
                        Task(priority: .high){
                            do{
                                let videoAsset = try await MediaManager.shared.fetchVideoAsset(from: videoURL, progressHandler: nil)
                                promise(.success(videoAsset))
                            }catch{
                                print("VideoViewModel Error: \(error)")
                                promise(.success(nil))
                            }
                        }
                    }
                }.eraseToAnyPublisher()
            }
            .compactMap{$0}
            .map{$0 as AVAsset}
//
        let videoThumbnailPublisher = $videoAsset
            .compactMap { URL(string: $0.url) }
            .flatMap{ imageURL -> AnyPublisher<Data?,Never> in
                Deferred{
                    Future{ promise in
                        Task(priority: .high){
                            do{
                                let imageData = try await MediaManager.shared.fetchVideoThumbnail(from: imageURL, progressHandler: nil)
                                promise(.success(imageData))
                            }catch{
                                print(error)
                                promise(.success(nil))
                            }
                        }
                    }
                }.eraseToAnyPublisher()
            }
            .compactMap{$0}
          
        output = Output(videoData: videoDataPublisher.eraseToAnyPublisher(),
                        videoThumbnail: videoThumbnailPublisher.eraseToAnyPublisher())
    }
}

