//
//  FeedMediaCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/23.
//

import Foundation
import Combine

protocol PostMediaViewModelDelegate: AnyObject {
    func postMediaViewModel(_ postMediaViewModel: PostMediaViewModel, didSelectedItemAt index: Int)
}

class PostMediaViewModel: FeedViewModel{
    
    struct Input {
        let selectItem: AnySubscriber<MediaViewModel,Never>
    }
    
    struct Output {
        let mediaViewModels: AnyPublisher<[MediaViewModel],Never>
    }

    private(set) var input: Input!
    private(set) var output: Output!
    
    
    private var subscriptions = Set<AnyCancellable>()
    weak var delegate: PostMediaViewModelDelegate?
    @Published var mediaViewModels: [MediaViewModel]
    
    private let post: Post
    
    init(post: Post){
        self.post = post
        
        mediaViewModels = post.media.map{ media in
            switch media.type{
            case .photo:
                return PhotoViewModel(media: media, imageProvider: MediaProvider.shared)
            case .video:
                return VideoViewModel(videoAsset: media, videoProvider: MediaProvider.shared)
            case .gif: fatalError("code should not go here")
            }
        }
        super.init()
        
        
        let selectSubject = PassthroughSubject<MediaViewModel,Never>()
        selectSubject.sink { [unowned self] selectedItem in
            let index = mediaViewModels.firstIndex(of: selectedItem)!
            delegate?.postMediaViewModel(self, didSelectedItemAt: index)
        }.store(in: &subscriptions)
        
        
        input = Input(selectItem: selectSubject.eraseToAnySubscriber())
        output = Output(mediaViewModels: $mediaViewModels.eraseToAnyPublisher())
    }
}
