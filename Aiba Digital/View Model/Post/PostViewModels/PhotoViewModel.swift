//
//  PhotoCellViewModel.swift
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

    @Published private var imageData: Data?
    
    private var imageURL: String {
        imageAsset.url
    }
    
    private var subscriptions = Set<AnyCancellable>()
 
    private let imageAsset: MediaAsset
    private let imageProvider: MediaProviding
    
    init(media: MediaAsset, imageProvider: MediaProviding){
        self.imageAsset = media
        self.imageProvider = imageProvider
        super.init()
        configureOutput()
    }
    
    private func configureOutput(){
       
        Just(imageURL)
            .flatMap { [weak self] url -> AnyPublisher<Data?, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.imageProvider.fetchImage(for: url)
            }.assign(to: &$imageData)
        
        output = Output(imageData: $imageData.compactMap{$0}.eraseToAnyPublisher())
    }
    
    deinit{
        print("PhotoCellViewModel deinit")
    }
}
