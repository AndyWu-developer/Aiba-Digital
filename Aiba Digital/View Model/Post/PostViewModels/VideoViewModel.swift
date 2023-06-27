//
//  MediaCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/11.
//

import Foundation
import Combine
import AVFoundation

class VideoViewModel: MediaViewModel {
    
    override var contentPixelWidth: Int {
        videoAsset.dimensions.width
    }

    override var contentPixelHeight: Int {
        videoAsset.dimensions.height
    }
    
    
    private var contentURL: String {
        videoAsset.url
    }
    
    struct Input {
        
    }
    
    struct Output {
        let thumbnailData: AnyPublisher<Data,Never>
        let videoData: AnyPublisher<AVAsset,Never>
    }

    private(set) var input: Input!
    private(set) var output: Output!
    
    private var subscriptions = Set<AnyCancellable>()
   
    @Published private var videoData: AVAsset?
    @Published private var imageData: Data?
   
    private let videoProvider: MediaProviding
    private let videoAsset: MediaAsset
    
    init(videoAsset: MediaAsset, videoProvider: MediaProviding){
        self.videoAsset = videoAsset
        self.videoProvider = videoProvider
        super.init()
        configureInput()
        configureOutput()
    }
    
    private func configureInput(){
        
    }
    
    private func configureOutput(){
       
        videoProvider.fetchVideo(for: contentURL)
            .compactMap{$0}
            .sink { [weak self] in
                print("video arrived")
                self?.videoData = $0
            }.store(in: &subscriptions)
        
        output = Output(thumbnailData: $imageData.compactMap{$0}.eraseToAnyPublisher(),
                      videoData: $videoData.compactMap{$0}.eraseToAnyPublisher())
    }
    
    deinit{
        print("VideoCellViewModel deinit")
    }
}

