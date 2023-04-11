//
//  PostCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import Foundation
import Combine
import AVFoundation

class PostCellViewModel{
    
    struct Input {
       // let expand: AnySubscriber<Void,Never>
//        let pin: AnySubscriber<Void,Never>
//        let like: AnySubscriber<Void,Never>
//        let comment: AnySubscriber<Void,Never>=
//        let shop: AnySubscriber<Void,Never>
//        let share: AnySubscriber<Void,Never>
    }
    
    struct Output {
        let mediaViewModels: AnyPublisher<[MediaViewModel],Never>
        let itemsInTopRow: AnyPublisher<Int,Never>
        let text: AnyPublisher<String,Never>
       // let isExpanded: AnyPublisher<Bool,Never>
    }
   
    private(set) var input: Input!
    private(set) var output: Output!
    private var subscriptions = Set<AnyCancellable>()
    private var indices = [Int]()
    private var currentIndex = 0
    private var mediaViewModels: [MediaViewModel] = []
    var isExpanded: Bool = false
    
    var sharedPlayer: AVPlayer? {
        didSet{
            mediaViewModels[currentIndex].player = sharedPlayer
        }
    }
    
    func playNextVideo(){
        mediaViewModels[currentIndex].player = nil
        currentIndex = (currentIndex+1) % indices.count
        mediaViewModels[currentIndex].player = sharedPlayer
      //  mediaViewModels[currentIndex].player?.play()
    }
    
    @Published var text: String
    @Published var itemsInTopRow = 1
    var indexPath: IndexPath?
    let isExpandedSubject = CurrentValueSubject<Bool,Never>(false)
    
    init(indexPath: IndexPath){
        self.indexPath = indexPath
        self.text = "QuadLock 手機殼，是一款專為現代生活設計的手機保護殼。它輕薄耐用，採用高質量的材料製成，可以在日常生活中保護您的手機免受損壞。它的獨特設計還可以快速輕鬆地將手機固定在您的自行車、汽車、運動器材上，讓您在運動、旅行和日常使用中更方便地使用手機。選擇 Quadlock 手機殼，讓您的手機更安全，更方便。"
        configureInput()
        configureOutput()
        //Publishers.Sequence.init(sequence: [])
    }
    
    private func configureInput(){
        
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .compactMap{ $0.object as? AVPlayerItem }
            .map{ [weak self] in self?.sharedPlayer?.currentItem === $0 }
            .filter{$0}
            .sink { [weak self] _ in
                self?.playNextVideo()
            }.store(in: &subscriptions)
        
        let e = PassthroughSubject<Void,Never>()
        e.sink { [weak self] _ in
            self?.isExpandedSubject.value = true
        }.store(in: &subscriptions)
        
       // input = Input(expand: e.eraseToAnySubscriber())
    }
    
    private func configureOutput(){
        let imageURL1 = "https://testPullZone20230325.b-cdn.net/image1.jpg"
        let imageURL2 = "https://testPullZone20230325.b-cdn.net/image2.jpg"
        let imageURL3 = "https://testPullZone20230325.b-cdn.net/image3.jpg"
        let imageURL4 = "https://testPullZone20230325.b-cdn.net/image4.jpg"
        let imageURL5 = "https://testPullZone20230325.b-cdn.net/image5.jpg"
        
        let videoURL1 = "https://testPullZone20230325.b-cdn.net/360.mp4"
        let videoURL2 = "https://testPullZone20230325.b-cdn.net/OtterBox.mp4"
        let videoURL3 = "https://testPullZone20230325.b-cdn.net/SerialApp%20480p.mp4"
        
        var urlStrings = [videoURL3,videoURL1, imageURL3, imageURL4, imageURL5,imageURL1]
        var types = [".mp4",".mp4",".jpg",".jpg",".jpg",".jpg"]
      
        urlStrings = Array(urlStrings[0...indexPath!.row % 6])
        types = Array(types[0...indexPath!.row % 6])
      
        indices = (0..<types.count).filter{ types[$0] == ".mp4" }
        mediaViewModels = zip(urlStrings,types).map(MediaViewModel.init)
 
        output = Output(mediaViewModels: Just(mediaViewModels).eraseToAnyPublisher(),
                        itemsInTopRow: $itemsInTopRow.eraseToAnyPublisher(),
                        text: $text.eraseToAnyPublisher())
    }


}

