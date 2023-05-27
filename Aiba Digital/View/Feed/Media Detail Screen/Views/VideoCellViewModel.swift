//
//  MediaCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/11.
//

import Foundation
import Combine
import AVFoundation

class VideoCellViewModel: MediaCellViewModel{
    
    struct Input {
    
    }
    
    struct Output {
        let videoDimensions: AnyPublisher<(width: Int, height: Int),Never>
        let thumbnailData: AnyPublisher<Data,Never>
        let videoData: AnyPublisher<AVAsset,Never>
    }

   
   
    private(set) var input: Input!
    private(set) var output: Output!
    
    private var subscriptions = Set<AnyCancellable>()
   
    @Published private var videoData: AVAsset?
    @Published private var imageData: Data?
    @Published private var dimensions: (width: Int, height: Int)
    
    private let videoProvider: MediaProviding
    private let mediaURL: String
    
    init(url: String, size: (width: Int, height: Int), videoProvider: MediaProviding){
        mediaURL = url
        dimensions = size
        self.videoProvider = videoProvider
        super.init()
        configureInput()
        configureOutput()
    }
    
    private func configureInput(){
        
    }
    
    private func configureOutput(){
       
        videoProvider.fetchVideo(for: mediaURL)
            .compactMap{$0}
            .sink { [weak self] in
                print("video arrived")
                self?.videoData = $0
            }.store(in: &subscriptions)
        
        output = Output(videoDimensions: $dimensions.eraseToAnyPublisher(),
                      thumbnailData: $imageData.compactMap{$0}.eraseToAnyPublisher(),
                      videoData: $videoData.compactMap{$0}.eraseToAnyPublisher())
    }
    
    deinit{
        print("VideoCellViewModel deinit")
    }
}
