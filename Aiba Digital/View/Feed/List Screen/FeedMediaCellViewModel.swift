//
//  FeedMediaCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/23.
//

import Foundation
import Combine

class FeedMediaCellViewModel: FeedViewModel{
    
    struct Input {
        let delete: AnyPublisher<[MediaCellViewModel],Error>
    }
    
    struct Output {
        let mediaViewModels: AnyPublisher<[MediaCellViewModel],Never>
    }

    private(set) var input: Input!
    private(set) var output: Output!
    let numberOfItems = Int.random(in: 1...6)
    
    @Published var mediaViewModels: [MediaCellViewModel]
   
    private let post: AibaPost
    
    init(post: AibaPost = AibaPost()){
        self.post = post
 
        mediaViewModels = post.media.map{ media in
            switch media.type{
            case .photo:
                return PhotoCellViewModel(url: media.url, size: media.dimensions, imageProvider: MediaProvider.shared)
            case .video:
                return VideoCellViewModel(url: media.url, size: media.dimensions, videoProvider: MediaProvider.shared)
            case .gif: fatalError("code should not go here")
            }
        }
        super.init()
        output = Output(mediaViewModels: $mediaViewModels.eraseToAnyPublisher())
    }
}
