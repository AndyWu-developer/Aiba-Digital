//
//  MediaDetailViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/14.
//

import Foundation
import Combine
import UIKit.UIImage

let imageURL1 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fcase4.JPG?alt=media&token=e64f46d3-d2af-4212-99ea-399a4a9beaaf"
let imageURL2 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fcase3.JPG?alt=media&token=ed68985f-edd6-4bbc-b88e-34d21196fd73"
let imageURL3 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fcase2.JPG?alt=media&token=b269e97c-9f46-4c89-aa3e-832cca3966ef"
let imageURL4 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fcase1.JPG?alt=media&token=9538508c-2ef2-4586-9845-6be4b59c97c1"
let imageURL5 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fimage5.jpg?alt=media&token=b0d2fb5a-5fc9-4292-94f8-b445673833d8"

let videoURL1 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2FSerial1App.mp4?alt=media&token=ff643f3f-4eee-429e-a8c0-ae49168a1621"

let videoURL2 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2FNOMAD.mp4?alt=media&token=4af8f03f-59c1-4a8e-9395-8ca858fe85ba"

let imageSize1 = (width: 1080, height: 1440)
let imageSize2 = (width: 1080, height: 1080)
let videoSize1 = (width: 640, height: 360)
let videoSize2 = (width: 720, height: 1280)

class AibaPost{
    let postID: String = ""
    let userName: String = "黃志銘-艾巴數位/瘋好殼"
    let userImageURL: String = ""
    let text: String = "美國NOMAD iPhone 14 Pro\n真牛皮皮革背板殼！現貨供應中\n\n艾巴數位\n台中市南屯區大墩路894號\n04-23272366\n#NOMAD\n#牛皮手機殼"
    let likes: Int = 1
    let comments: Int = 2
    
    let media: [AibaMedia] = [
        //AibaMedia(type: .video, url: videoURL2, dimensions: videoSize2),
        AibaMedia(type: .photo, url: imageURL1, dimensions: imageSize1),
        AibaMedia(type: .photo, url: imageURL2, dimensions: imageSize1),
        AibaMedia(type: .photo, url: imageURL3, dimensions: imageSize1),
        AibaMedia(type: .photo, url: imageURL4, dimensions: imageSize1),
//        //AibaMedia(type: .video, url: videoURL1, dimensions: videoSize1)
        AibaMedia(type: .photo, url: imageURL1, dimensions: imageSize1),
//        AibaMedia(type: .photo, url: imageURL2, dimensions: imageSize1),
//        AibaMedia(type: .photo, url: imageURL3, dimensions: imageSize1),
//        AibaMedia(type: .photo, url: imageURL4, dimensions: imageSize1),
//        AibaMedia(type: .photo, url: imageURL1, dimensions: imageSize1),
//        AibaMedia(type: .photo, url: imageURL2, dimensions: imageSize1),
//        AibaMedia(type: .photo, url: imageURL3, dimensions: imageSize1),
//        AibaMedia(type: .photo, url: imageURL4, dimensions: imageSize1),
    ]
}

class AibaMedia{
    
    enum AibaMediaType { case photo, video, gif }
    
    let type: AibaMediaType
    let url: String
    let dimensions: (width: Int, height: Int)
    
    init(type: AibaMediaType, url: String, dimensions: (width: Int, height: Int)) {
        self.url = url
        self.type = type
        self.dimensions = dimensions
    }
}


class MediaDetailViewModel{
    
    struct Input {
        let delete: AnyPublisher<[MediaCellViewModel],Error>
//        let like: AnyPublisher<Void,Never>
//        let comment: AnyPublisher<Void,Never>
//        let shop: AnyPublisher<Void,Never>
//        let share: AnyPublisher<Void,Never>
    }
    
    struct Output {
        let mediaViewModels: AnyPublisher<[MediaCellViewModel],Never>
        let userName: AnyPublisher<String,Never>
        let userImageData: AnyPublisher<Data,Never>
        let text: AnyPublisher<String,Never>
    }

    private(set) var input: Input!
    private(set) var output: Output!
    
    @Published private var userName: String
    @Published private var userText: String
    @Published private var mediaViewModels: [MediaCellViewModel]
    @Published private var image = UIImage(named: "userIcon")!.jpegData(compressionQuality: 0.5)!
    
    private let post: AibaPost
    
    init(post: AibaPost = AibaPost()){
        self.post = post
        userName = post.userName
        userText = post.text
        
        mediaViewModels = post.media.map{ media in
            switch media.type{
            case .photo:
                return PhotoCellViewModel(url: media.url, size: media.dimensions, imageProvider: MediaProvider.shared)
            case .video:
                return VideoCellViewModel(url: media.url, size: media.dimensions, videoProvider: MediaProvider.shared)
            case .gif: fatalError("code should not go here")
            }
        }
    
        output = Output(mediaViewModels: $mediaViewModels.eraseToAnyPublisher(),
                        userName: $userName.eraseToAnyPublisher(),
                        userImageData: $image.eraseToAnyPublisher(),
                        text: $userText.eraseToAnyPublisher() )
    }
    
}
