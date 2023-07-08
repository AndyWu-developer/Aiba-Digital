//
//  MediaDetailViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/14.
//

import Foundation
import Combine
import UIKit.UIImage

class MediaDetailViewModel{
    
    struct Input {
        let dismiss: AnySubscriber<Void,Never>
      //  let delete: AnyPublisher<[MediaCellViewModel],Error>
//        let like: AnyPublisher<Void,Never>
//        let comment: AnyPublisher<Void,Never>
//        let shop: AnyPublisher<Void,Never>
//        let share: AnyPublisher<Void,Never>
    }
    
    struct Output {
        let mediaViewModels: AnyPublisher<[MediaViewModel],Never>
        let userName: AnyPublisher<String,Never>
        let userImageData: AnyPublisher<Data,Never>
        let text: AnyPublisher<String,Never>
    }

    private(set) var input: Input!
    private(set) var output: Output!
    
    @Published private var userName: String = "😎"
    @Published private var userText: String
    @Published private var mediaViewModels: [MediaViewModel]
    @Published private var image = UIImage(named: "userIcon")!.jpegData(compressionQuality: 0.5)!
    
    private var subscriptions = Set<AnyCancellable>()
    var dismiss: (()->())?
    private let post: Post
    
    init(post: Post){
        self.post = post
        userText = post.text ?? ""
        
        mediaViewModels = post.media.map{ media in
            switch media.type{
            case .photo:
                return PhotoViewModel(media: media, imageProvider: MediaManager.shared)
            case .video:
                return VideoViewModel(videoAsset: media, videoProvider: MediaManager.shared)
            case .gif: fatalError("code should not go here")
            }
        }
    
        let dismissSubject = PassthroughSubject<Void,Never>()
        
        dismissSubject.sink { [unowned self] _ in
            dismiss?()
        }.store(in: &subscriptions)
        
        input = Input(dismiss: dismissSubject.eraseToAnySubscriber())
        output = Output(mediaViewModels: $mediaViewModels.eraseToAnyPublisher(),
                        userName: $userName.eraseToAnyPublisher(),
                        userImageData: $image.eraseToAnyPublisher(),
                        text: $userText.eraseToAnyPublisher() )
    }
    
    
    deinit{
        print("MediaDetailViewModel deinit")
    }
}
