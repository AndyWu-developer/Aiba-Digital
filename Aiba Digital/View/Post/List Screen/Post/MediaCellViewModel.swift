//
//  MediaCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/11.
//

import Foundation
import Combine
import AVFoundation

class MediaCellViewModel {
    
    struct Input {
    
    }
    
    struct Output {
        let mediaDimensions: AnyPublisher<CGSize,Never>
        let imageData: AnyPublisher<Data,Never>
        let videoData: AnyPublisher<AVAsset,Never>
    }

    let mediaURL = "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    let mediaURL1 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2FSerial1App.mp4?alt=media&token=ff643f3f-4eee-429e-a8c0-ae49168a1621"
    private(set) var input: Input!
    private(set) var output: Output!
    
    private var subscriptions = Set<AnyCancellable>()
   
    @Published private var videoData: AVAsset?
    @Published private var imageData: Data?
    @Published private var dimensions = CGSize(width: 640, height: 360)
    
    private let mediaProvider: MediaProviding = MediaProvider.shared
    
    init(){
        configureInput()
        configureOutput()
    }
    
    private func configureInput(){
        
        
    }
    
    private func configureOutput(){
       
        mediaProvider.fetchVideoAsset(for: mediaURL)
            .compactMap{$0}
            .sink { [weak self] in
                print("video arrived")
                self?.videoData = $0
            }.store(in: &subscriptions)
        
        output = Output(mediaDimensions: $dimensions.eraseToAnyPublisher(),
                      imageData: $imageData.compactMap{$0}.eraseToAnyPublisher(),
                      videoData: $videoData.compactMap{$0}.eraseToAnyPublisher())
    }
    
    deinit{
        print("MediaCellViewModel deinit")
    }
}


extension MediaCellViewModel: Hashable, Identifiable {
    static func == (lhs: MediaCellViewModel, rhs: MediaCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
