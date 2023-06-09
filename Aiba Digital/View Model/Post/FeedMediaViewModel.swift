////
////  PostMediaCellViewModel.swift
////  Aiba Digital
////
////  Created by Andy Wu on 2023/4/7.
////
//
//import Foundation
//import Combine
//import AVFoundation
//
//class FeedMediaViewModel: FeedViewModel{
//    
//    struct Input {
//        
//    }
//    
//    struct Output {
//        let videoAsset: AnyPublisher<AVAsset,Never>
//        let imageData: AnyPublisher<[Data],Never>
//        
//    }
//    
//    private(set) var input: Input!
//    private(set) var output: Output!
//    private var subscriptions = Set<AnyCancellable>()
//    private let mediaProvider: MediaProviding = MediaProvider.shared
//    
//    private var mediaURL: String = ""
//    typealias Dependencies = HasMediaProvider
//    //private let dependencies: Dependencies
//    @Published private var imageData: [Data]
//    /// This function does magic by converting an array of links into a publisher
//    
//    func dataPublishers(from links: [String]) -> [AnyPublisher<Data,Never>] {
//        
//        links.map{ url in
//            mediaProvider.fetchImage(for: url).compactMap{$0}.eraseToAnyPublisher()
//        }
//    }
//    
//    func publisherSequence(from links: [String]) -> AnyPublisher<Data, Never> {
//        Publishers.Sequence(sequence: dataPublishers(from: links)) // <-- At this point we convert an array of publishers to a sequence which is just AnyPublisher as  a result
//            .flatMap { $0 }
//            .eraseToAnyPublisher()
//    }
//    private let post: Post
//    
//    init(post: Post){
//        self.post = post
//        //self.dependencies = dependencies
//        
//        let urls = [String]()
//        imageData = Array(repeating: Data(), count: urls.count)
//        super.init()
//      //  let imageArrayPublisher = Publishers.Sequence.init(sequence: [imageDataPublisher])
//        mediaProvider.fetchVideo(for: mediaURL)
//            .compactMap{$0}
//            .sink { [weak self] item in
//                self?.playerAssetSubject.value = item
//            }.store(in: &subscriptions)
//        
//        // self.dependencies = dependencies
//        configureInput()
//        configureOutput()
//    }
//    
//    private func configureInput(){
//        
//    }
//    
//    var player: AVPlayer?{
//        didSet{
//            createNewVideoProccessingChain()
//        }
//    }
//    private var videoChainSubscriptions = Set<AnyCancellable>()
//    
//    func createNewVideoProccessingChain(){
//        guard let player = player else { return }
//        let playerLayer = AVPlayerLayer(player: player)
//        playerAssetSubject
//            .compactMap{$0}
//            .sink {
//                player.replaceCurrentItem(with: AVPlayerItem(asset: $0))
//            }.store(in: &videoChainSubscriptions)
//        
////        playerLayer.publisher(for: \.isReadyForDisplay)
////            .filter{$0}
////            .
//        
//    }
//    
//    
//    
//    private let playerAssetSubject = CurrentValueSubject<AVAsset?, Never>(nil)
//    
//    
//    private func configureOutput(){
//        
//      
//    }
//}
