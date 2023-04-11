//
//  PostMediaCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/7.
//

import Foundation
import Combine
import AVFoundation

class PostMediaViewModel{
    
    struct Input {
        
    }
    
    struct Output {
        let videoAsset: AnyPublisher<AVAsset,Never>
        let imageData: AnyPublisher<[Data],Never>
        
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    private var subscriptions = Set<AnyCancellable>()
    private let mediaProvider: MediaProviding = MediaProvider.shared
    
    private var mediaURL: String = ""
    typealias Dependencies = HasPostManager & HasMediaProvider
    private var dependencies: Dependencies!
    @Published private var imageData: [Data]
    /// This function does magic by converting an array of links into a publisher
    
    func dataPublishers(from links: [String]) -> [AnyPublisher<Data,Never>] {
        
        links.map{ url in
            mediaProvider.fetchImage(for: url).compactMap{$0}.eraseToAnyPublisher()
        }
    }
    
    func publisherSequence(from links: [String]) -> AnyPublisher<Data, Never> {
        Publishers.Sequence(sequence: dataPublishers(from: links)) // <-- At this point we convert an array of publishers to a sequence which is just AnyPublisher as  a result
            .flatMap { $0 }
            .eraseToAnyPublisher()
    }
    init(){
        let urls = [String]()
        imageData = Array(repeating: Data(), count: urls.count)
        
      //  let imageArrayPublisher = Publishers.Sequence.init(sequence: [imageDataPublisher])
        mediaProvider.fetchVideoAsset(for: mediaURL)
            .compactMap{$0}
            .sink { [weak self] item in
                self?.playerAssetSubject.value = item
            }.store(in: &subscriptions)
        
        // self.dependencies = dependencies
        configureInput()
        configureOutput()
    }
    
    private func configureInput(){
        
    }
    
    var player: AVPlayer?{
        didSet{
            createNewVideoProccessingChain()
        }
    }
    private var videoChainSubscriptions = Set<AnyCancellable>()
    
    func createNewVideoProccessingChain(){
        guard let player = player else { return }
        let playerLayer = AVPlayerLayer(player: player)
        playerAssetSubject
            .compactMap{$0}
            .sink {
                player.replaceCurrentItem(with: AVPlayerItem(asset: $0))
            }.store(in: &videoChainSubscriptions)
        
//        playerLayer.publisher(for: \.isReadyForDisplay)
//            .filter{$0}
//            .
        
    }
    
    
    
    private let playerAssetSubject = CurrentValueSubject<AVAsset?, Never>(nil)
    
    
    private func configureOutput(){
        
      
    }
}



extension PostMediaViewModel: Hashable, Identifiable {
    static func == (lhs: PostMediaViewModel, rhs: PostMediaViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
