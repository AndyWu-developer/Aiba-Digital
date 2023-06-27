//
//  GalleryMediaViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/2.
//

import Foundation
import Photos
import Combine
import UIKit.UIImage

protocol MediaPickerCellViewModelDelegate: AnyObject{
    func galleryMediaViewModel(_ viewModel: MediaPickerCellViewModel, didSelectAsset asset: PHAsset)
    func galleryMediaViewModel(_ viewModel: MediaPickerCellViewModel, didDeselectAsset asset: PHAsset)
}

class MediaPickerCellViewModel {
    
    struct Input {
        let imageTargetSize: AnySubscriber<CGSize,Never>
        let toggleSelection: AnySubscriber<Void,Never>
    }
    
    struct Output {
        let thumbnailImage: AnyPublisher<UIImage?,Never>
        let videoDuration: AnyPublisher<String?,Never>
        let selectedNumber: AnyPublisher<Int,Never>
    }

    private(set) var input: Input!
    private(set) var output: Output!
    var id = UUID().uuidString
    weak var delegate: MediaPickerCellViewModelDelegate?
    
    @Published var selectedNumber = 0
    @Published private var videoDurationText: String?
    private(set) var asset: PHAsset
    
    private var subscriptions = Set<AnyCancellable>()
    private let imageManager: PHCachingImageManager
    private let toggleSelectionSubject = PassthroughSubject<Void,Never>()
    private let imageSubject = PassthroughSubject<UIImage?,Never>()
    
    private(set) var contentWidth: Int
    private(set) var contentHeight: Int
    
    init(asset: PHAsset, imageCacheManager: PHCachingImageManager){
        self.asset = asset
        self.imageManager = imageCacheManager
        contentWidth = asset.pixelWidth
        contentHeight = asset.pixelHeight
        configureInput()
        configureOutput()
    }

    private func configureInput(){
        let targetSizeSubject = PassthroughSubject<CGSize,Never>()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        targetSizeSubject
            .sink { [unowned self] size in
                print("\(id) received size \(size)")
                imageManager.requestImage(for: self.asset,targetSize: size, contentMode: .aspectFill, options: options) { [weak self] image, info in
                    self?.imageSubject.send(image)
                }
            }.store(in: &subscriptions)
       
        toggleSelectionSubject
            .sink { [unowned self] _ in
                if selectedNumber == 0{
                    delegate?.galleryMediaViewModel(self, didSelectAsset: asset)
                }else{
                    delegate?.galleryMediaViewModel(self, didDeselectAsset: asset)
                }
            }.store(in: &subscriptions)
       
        input = Input(imageTargetSize: targetSizeSubject.eraseToAnySubscriber(),
                      toggleSelection: toggleSelectionSubject.eraseToAnySubscriber())
    }
    
    private func configureOutput(){
        
        if asset.mediaType == .video{
            let totalSeconds = asset.duration
            let hours = Int(totalSeconds / 3600)
            let minutes = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
            let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
            if hours > 0 {
                videoDurationText = String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                videoDurationText = String(format: "%d:%02d", minutes, seconds)
            }
        }else{
            videoDurationText = nil
        }

        output = Output(thumbnailImage: imageSubject.eraseToAnyPublisher(),
                       videoDuration: $videoDurationText.eraseToAnyPublisher(),
                       selectedNumber: $selectedNumber.eraseToAnyPublisher())
    }
   
}


extension MediaPickerCellViewModel: Hashable {
    
    static func == (lhs: MediaPickerCellViewModel, rhs: MediaPickerCellViewModel) -> Bool {
        return lhs.asset.localIdentifier == rhs.asset.localIdentifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.localIdentifier)
    }
}
