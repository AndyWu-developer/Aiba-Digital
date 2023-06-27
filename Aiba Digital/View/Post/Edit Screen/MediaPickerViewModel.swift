//
//  MediaPickerViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/2.
//

import UIKit
import Combine
import Photos

class MediaPickerViewModel: NSObject {
    
    struct Input {
        let selectedMediaViewModel: AnySubscriber<[MediaPickerCellViewModel],Never>
        let requestPhotoLibraryAccess: AnySubscriber<Void,Never>
    }
    
    struct Output {
        let galleryMediaViewModels: AnyPublisher<[MediaPickerCellViewModel],Never>
        let hasPhotoLibraryAccess: AnyPublisher<Bool,Never>
    }
    
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var isAuthorized: Bool?
    @Published var cellViewModels = [MediaPickerCellViewModel]()
    
    private let sharedImageCachingManager = PHCachingImageManager()
    private let selectedSubject = PassthroughSubject<[MediaPickerCellViewModel],Never>()
    private let settingSubject = PassthroughSubject<Void,Never>()
    
    private var fetchResult: PHFetchResult<PHAsset>!
    private let mediaPicks: MediaPicks
    
    init(mediaPicks: MediaPicks = MediaPicks()){
        
        self.mediaPicks = mediaPicks
        super.init()
        
        input = Input(selectedMediaViewModel: selectedSubject.eraseToAnySubscriber(), requestPhotoLibraryAccess: settingSubject.eraseToAnySubscriber())
        output = Output(galleryMediaViewModels: $cellViewModels.eraseToAnyPublisher(),
                        hasPhotoLibraryAccess: $isAuthorized.compactMap{$0}.eraseToAnyPublisher())
        
        mediaPicks.$pickedAssets
            .scan((added: [PHAsset](), removed: [PHAsset]())){ tuple, assets in
                let removedAssets = Set(tuple.added).subtracting(Set(assets))
                return (assets, Array(removedAssets))
            }
            .sink{ [weak self] (addedAssets, removedAssets) in
                guard let self = self else {return }
           
                removedAssets.forEach { removedAsset in
                    self.cellViewModels.first{ $0.asset == removedAsset }?.selectedNumber = 0
                }
                addedAssets.enumerated().forEach { index, addedAsset in
                    self.cellViewModels.first{ $0.asset == addedAsset }!.selectedNumber = index + 1
                }
            }
            .store(in: &subscriptions)
        
        settingSubject
            .sink { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                guard UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url) { success in
                    print("Settings opened: \(success)")
                }
            }
            .store(in: &subscriptions)
        
        start()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private func start() {
        
        Task{
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .authorized, .limited:
                isAuthorized = true
            case .denied, .restricted:
                isAuthorized = false
            case .notDetermined:
                let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                isAuthorized = (status == .authorized || status == .limited)
            @unknown default:
                fatalError()
            }
            
            if isAuthorized == true {
                loadPhotoLibraryInfo()
                PHPhotoLibrary.shared().register(self)
            }
        }
    }

    private func loadPhotoLibraryInfo(){
      
        let album = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(
            format: "mediaType = %d || mediaType = %d",
            PHAssetMediaType.image.rawValue,
            PHAssetMediaType.video.rawValue)
        
        fetchResult = PHAsset.fetchAssets(in: album.firstObject!, options: fetchOptions)
        let assets = Array(fetchResult.objects(at: IndexSet(0..<fetchResult.count)).reversed())
       
        cellViewModels = assets.map { asset in
            let cellViewModel = MediaPickerCellViewModel(asset: asset, imageCacheManager: sharedImageCachingManager)
            cellViewModel.delegate = self
            return cellViewModel
        }
    }
    
}


extension MediaPickerViewModel: PHPhotoLibraryChangeObserver{
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
       
        guard let details = changeInstance.changeDetails(for: fetchResult) else { return }
        fetchResult = details.fetchResultAfterChanges
        let assets = Array(fetchResult.objects(at: IndexSet(0..<fetchResult.count)).reversed())
        cellViewModels = assets.map { asset in
            let cellViewModel = MediaPickerCellViewModel(asset: asset, imageCacheManager: sharedImageCachingManager)
            cellViewModel.delegate = self
            return cellViewModel
        }
        mediaPicks.pickedAssets.removeAll{ !assets.contains($0) }
    }
}

extension MediaPickerViewModel: MediaPickerCellViewModelDelegate{
    
    func galleryMediaViewModel(_ viewModel: MediaPickerCellViewModel, didSelectAsset asset: PHAsset) {
        mediaPicks.pickedAssets.append(asset)
    }
    
    func galleryMediaViewModel(_ viewModel: MediaPickerCellViewModel, didDeselectAsset asset: PHAsset) {
        let index = mediaPicks.pickedAssets.firstIndex(of: asset)!
        mediaPicks.pickedAssets.remove(at: index)
    }
    
}


