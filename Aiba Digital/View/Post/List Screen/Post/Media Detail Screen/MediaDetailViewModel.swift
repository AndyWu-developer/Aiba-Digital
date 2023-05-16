//
//  MediaDetailViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/14.
//

import Foundation
import Combine

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
    }

    private(set) var input: Input!
    private(set) var output: Output!
    
    
    let imageURL1 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fimage1.jpg?alt=media&token=3a8c22cf-9b77-49d7-845b-e3f116a7ad20"
    let imageURL2 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fimage2.jpg?alt=media&token=df7ced21-0f9c-492a-9d29-e97b86029bba"
    let imageURL3 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fimage3.jpg?alt=media&token=85637121-53ff-4d78-b8bd-d25a09f891e0"
    let imageURL4 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fimage4.jpg?alt=media&token=b96f13d3-0343-4d73-92d2-0e9cb18b5d2e"
    let imageURL5 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fimage5.jpg?alt=media&token=b0d2fb5a-5fc9-4292-94f8-b445673833d8"
    
    let imageSize1 = CGSize(width: 1080, height: 1080)
    let imageSize2 = CGSize(width: 1080, height: 1080)
    @Published private var mediaViewModels: [MediaCellViewModel]
    
    
    init(){
        mediaViewModels = [
            PhotoCellViewModel(url: imageURL1, size: imageSize1, imageProvider: MediaProvider.shared),
            PhotoCellViewModel(url: imageURL2, size: imageSize1, imageProvider: MediaProvider.shared),
            PhotoCellViewModel(url: imageURL3, size: imageSize1, imageProvider: MediaProvider.shared),
            PhotoCellViewModel(url: imageURL4, size: imageSize1, imageProvider: MediaProvider.shared),
            PhotoCellViewModel(url: imageURL5, size: imageSize1, imageProvider: MediaProvider.shared),
            PhotoCellViewModel(url: imageURL1, size: imageSize1, imageProvider: MediaProvider.shared),
            VideoCellViewModel()
        ]
        
       output = Output(mediaViewModels: $mediaViewModels.eraseToAnyPublisher())
      
    }
    
}
