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
    
    
    let imageURL1 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fcase4.JPG?alt=media&token=e64f46d3-d2af-4212-99ea-399a4a9beaaf"
    let imageURL2 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fcase3.JPG?alt=media&token=ed68985f-edd6-4bbc-b88e-34d21196fd73"
    let imageURL3 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fcase2.JPG?alt=media&token=b269e97c-9f46-4c89-aa3e-832cca3966ef"
    let imageURL4 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fcase1.JPG?alt=media&token=9538508c-2ef2-4586-9845-6be4b59c97c1"
    let imageURL5 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fimage5.jpg?alt=media&token=b0d2fb5a-5fc9-4292-94f8-b445673833d8"
    
    let imageSize1 = CGSize(width: 1080, height: 1440)
    let imageSize2 = CGSize(width: 1080, height: 1080)
    @Published private var mediaViewModels: [MediaCellViewModel]
    
    
    init(){
        mediaViewModels = [
            PhotoCellViewModel(url: imageURL1, size: imageSize1, imageProvider: MediaProvider.shared),
            PhotoCellViewModel(url: imageURL2, size: imageSize1, imageProvider: MediaProvider.shared),
            PhotoCellViewModel(url: imageURL3, size: imageSize1, imageProvider: MediaProvider.shared),
            PhotoCellViewModel(url: imageURL4, size: imageSize1, imageProvider: MediaProvider.shared),
//            PhotoCellViewModel(url: imageURL5, size: imageSize1, imageProvider: MediaProvider.shared),
//            PhotoCellViewModel(url: imageURL1, size: imageSize1, imageProvider: MediaProvider.shared),
//            VideoCellViewModel()
        ]
        
       output = Output(mediaViewModels: $mediaViewModels.eraseToAnyPublisher())
    }
    
}
