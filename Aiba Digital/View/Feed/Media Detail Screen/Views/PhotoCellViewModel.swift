//
//  PhotoCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/15.
//

import Foundation
import Combine

class PhotoCellViewModel: MediaCellViewModel {
    
    struct Input {}
    
    struct Output {
        let imageDimensions: AnyPublisher<(width: Int, height: Int),Never>
        let imageData: AnyPublisher<Data,Never>
    }
    
    private(set) var input: Input!
    private(set) var output: Output!

    @Published private var imageData: Data?
    @Published private var dimensions: (width: Int, height: Int)
    
    private var subscriptions = Set<AnyCancellable>()
    private let imageURL: String
    private let imageProvider: MediaProviding
    
    init(url: String, size: (width: Int, height: Int), imageProvider: MediaProviding){
        self.imageURL = url
        self.dimensions = size
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
        
        output = Output(imageDimensions: $dimensions.eraseToAnyPublisher(),
                      imageData: $imageData.compactMap{$0}.eraseToAnyPublisher())
    }
    
    deinit{
        print("PhotoCellViewModel deinit")
    }
}

