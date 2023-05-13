//
//  PostMediaCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/5.
//

import Foundation
import Combine
import AVFoundation

class PostMediaCellViewModel{
    
    struct Input {

    }
    
    struct Output {
        let mediaViewModels: AnyPublisher<[MediaViewModel],Never>
        let itemsInTopRow: AnyPublisher<Int,Never>
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
            //mediaViewModels[currentIndex].player = sharedPlayer
        }
    }
    
    func playNextVideo(){
       // mediaViewModels[currentIndex].player = nil
        currentIndex = (currentIndex+1) % indices.count
        //mediaViewModels[currentIndex].player = sharedPlayer
    }
    
    @Published var itemsInTopRow = 1
    var indexPath: IndexPath?
    let isExpandedSubject = CurrentValueSubject<Bool,Never>(false)
    
    init(indexPath: IndexPath){
        self.indexPath = indexPath
        configureInput()
        configureOutput()
    }
    
    private func configureInput(){
        
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .compactMap{ $0.object as? AVPlayerItem }
            .map{ [weak self] in self?.sharedPlayer?.currentItem === $0 }
            .filter{$0}
            .sink { [weak self] _ in
                self?.playNextVideo()
            }.store(in: &subscriptions)
        
    }
    
    private func configureOutput(){
        let imageURL1 = "https://testPullZone20230325.b-cdn.net/image1.jpg"
        let imageURL2 = "https://testPullZone20230325.b-cdn.net/image2.jpg"
        let imageURL3 = "https://testPullZone20230325.b-cdn.net/image3.jpg"
        let imageURL4 = "https://testPullZone20230325.b-cdn.net/image4.jpg"
        let imageURL5 = "https://testPullZone20230325.b-cdn.net/image5.jpg"
        
        let videoURL1 = "https://testPullZone20230325.b-cdn.net/360.mp4"
        let videoURL2 = "https://testPullZone20230325.b-cdn.net/OtterBox.mp4"
        let videoURL3 = "https://firebasestorage.googleapis.com/v0/b/stock-check-e7b95.appspot.com/o/media%2Fdemo.mp4?alt=media&token=37a2bf32-1788-4686-9a23-be572f1154d7"
        
        var urlStrings = [videoURL2,videoURL1, imageURL3, imageURL4, imageURL5,imageURL1]
        var types = [".mp4",".mp4",".jpg",".jpg",".jpg",".jpg"]
      
        urlStrings = Array(urlStrings[0...indexPath!.row % 6])
        types = Array(types[0...indexPath!.row % 6])
      
        indices = (0..<types.count).filter{ types[$0] == ".mp4" }
        mediaViewModels = zip(urlStrings,types).map{MediaViewModel(url: $0, fileExtension: $1)}
 
        output = Output(mediaViewModels: Just(mediaViewModels).eraseToAnyPublisher(),
                        itemsInTopRow: $itemsInTopRow.eraseToAnyPublisher())
    }


}


