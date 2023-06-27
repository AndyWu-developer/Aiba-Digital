//
//  EditPostViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/19.
//

import Foundation
import Photos
import Combine

class EditPostViewModel {
    
    struct Input {
        let cancelPosting: AnySubscriber<Void,Never>
        let finishPosting: AnySubscriber<Void,Never>
        let text: AnySubscriber<String,Never>
    }
    
    struct Output {
        let selectedMediaViewModels: AnyPublisher<[MediaPickerCellViewModel],Never>
    }

    private(set) var input: Input!
    private(set) var output: Output!
    private var subscriptions = Set<AnyCancellable>()
    
    var didCancelEditing: (() -> Void)?
    var didFinishEditing: (([PHAsset], String) -> Void)?

    @Published var cellViewModels = [MediaPickerCellViewModel]()
    private let cancelPostingSubject = PassthroughSubject<Void,Never>()
    private let finishPostingSubject = PassthroughSubject<Void,Never>()
    private let mediaPicks: MediaPicks = MediaPicks()
    
    private(set) lazy var pickerViewModel: MediaPickerViewModel = {
        return MediaPickerViewModel(mediaPicks: mediaPicks)
    }()
    
    private let textSubject = CurrentValueSubject<String,Never>("")
    let imageManager = PHCachingImageManager()
    
    init(){
        cancelPostingSubject
            .sink { [unowned self] _ in
                didCancelEditing?()
            }.store(in: &subscriptions)
        
        mediaPicks.$pickedAssets
            .sink{ [weak self] assets in
                guard let self = self else {return }
                print("received \(assets.count) items")
                cellViewModels = assets.map { asset in
                    let cellViewModel = MediaPickerCellViewModel(asset: asset, imageCacheManager: self.imageManager)
                   // cellViewModel.delegate = self
                    return cellViewModel
                }
               
            }
            .store(in: &subscriptions)
        
        finishPostingSubject.sink { [unowned self] _ in
            didFinishEditing?(mediaPicks.pickedAssets, textSubject.value)
        }.store(in: &subscriptions)
        
        
        
        
        input = Input(cancelPosting: cancelPostingSubject.eraseToAnySubscriber(),
                      finishPosting: finishPostingSubject.eraseToAnySubscriber(),
                      text: textSubject.eraseToAnySubscriber())
        output = Output(selectedMediaViewModels: $cellViewModels.eraseToAnyPublisher())
        
    }
    
    
}
