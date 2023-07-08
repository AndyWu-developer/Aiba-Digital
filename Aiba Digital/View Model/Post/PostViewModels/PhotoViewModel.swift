//
//  PhotoViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/15.
//

import Foundation
import Combine


class PhotoViewModel: MediaViewModel{
    
    override var contentPixelWidth: Int{
        imageAsset.dimensions.width
    }
    
    override var contentPixelHeight: Int{
        imageAsset.dimensions.height
    }
 
    struct Input { }
    
    struct Output {
        let imageData: AnyPublisher<Data,Never>
    }
    
    private(set) var input: Input!
    private(set) var output: Output!

    @Published private var imageAsset: MediaAsset
    private let imageProvider: MediaDownloading
    
    init(media: MediaAsset, imageProvider: MediaDownloading){
        self.imageAsset = media
        self.imageProvider = imageProvider
        super.init()
        configureOutput()
    }
    
    deinit{
        print("PhotoViewModel deinit")
    }

    private func configureOutput(){

        let imageDataPublisher = $imageAsset
            .map(\.url)
            .flatMap{ imageURL -> AnyPublisher<Data?,Never> in
                Deferred{
                    Future{ promise in
                        Task(priority: .high){
                            do{
                                let imageData = try await MediaManager.shared.fetchImageData(from: imageURL, progressHandler: nil)
                                promise(.success(imageData))
                            }catch{
                                print(error)
                                promise(.success(nil))
                            }
                        }
                    }
                }.eraseToAnyPublisher()
            }
            .compactMap{$0}
        
        output = Output(imageData: imageDataPublisher.eraseToAnyPublisher())
    }
    
}


//        let imageDataPublisher = $imageAsset
//            .map{$0.url}
//            .flatMap { [weak self] url -> AnyPublisher<Data?, Never> in
//                guard let self = self else { return Empty().eraseToAnyPublisher() }
//                return self.imageProvider.fetchImage(for: url)
//            }
//            .compactMap{$0}
