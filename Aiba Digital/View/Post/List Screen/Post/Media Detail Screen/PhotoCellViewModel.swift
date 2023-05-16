//
//  PhotoCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/15.
//

import Foundation
import Combine

class PhotoCellViewModel: MediaCellViewModel {
    
    struct Input { }
    
    struct Output {
        let imageDimensions: AnyPublisher<CGSize,Never>
        let imageData: AnyPublisher<Data,Never>
    }
    
    private(set) var input: Input!
    private(set) var output: Output!

    @Published private var imageData: Data?
    @Published private var dimensions: CGSize
    
    private var subscriptions = Set<AnyCancellable>()
    private let imageURL: String
    private let imageProvider: MediaProviding
    
    init(url: String, size: CGSize, imageProvider: MediaProviding){
        self.imageURL = url
        self.dimensions = size
        self.imageProvider = imageProvider
        
        super.init()
        configureInput()
        configureOutput()
    }
    
    private func configureInput(){}
    
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

