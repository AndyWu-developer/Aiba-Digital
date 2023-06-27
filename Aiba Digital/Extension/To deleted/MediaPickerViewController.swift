//
//  PostEditingViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/31.
//

import UIKit
import Combine

class MediaPickerViewController: UIViewController {
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var requestPhotoAccessView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Section { case all }
    private var dataSource: UICollectionViewDiffableDataSource<Section,MediaPickerCellViewModel>!
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: MediaPickerViewModel
    
    init(viewModel: MediaPickerViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        bindViewModelInput()
        bindViewModelOutput()
    }

    private func configureCollectionViewLayout(){
      
        let threeColumnGridLayout: UICollectionViewLayout = {
 
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
            group.interItemSpacing = .fixed(1)
            
            let section = NSCollectionLayoutSection(group: group)
         //   section.interGroupSpacing = 1
            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
        }()
        
        collectionView.collectionViewLayout = threeColumnGridLayout
    }
    
    private func configureCollectionViewDataSource(){
        
        let cellRegistration = UICollectionView.CellRegistration<MediaPickerCell, MediaPickerCellViewModel>(cellNib: UINib(nibName: String(describing: MediaPickerCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.viewModel = viewModel
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section,MediaPickerCellViewModel>(collectionView: collectionView) { collectionView, indexPath, viewModel in
            return collectionView.dequeueConfiguredReusableCell(using:  cellRegistration, for: indexPath, item: viewModel)
        }
    }
    
    private func bindViewModelInput(){
        
        settingsButton.publisher(for: .touchUpInside)
            .sink { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                           return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                     UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)")
                     })
                }
            }.store(in: &subscriptions)
    }
    
    private func bindViewModelOutput(){
        
        viewModel.output.galleryMediaViewModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModels in
                guard let self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Section,MediaPickerCellViewModel>()
                snapshot.appendSections([.all])
                snapshot.appendItems(viewModels)
                dataSource.apply(snapshot,animatingDifferences: false)
            }.store(in: &subscriptions)
        
        viewModel.output.hasPhotoLibraryAccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasAccess in
                self?.requestPhotoAccessView.isHidden = hasAccess
            }.store(in: &subscriptions)
        
    }
    
}

extension MediaPickerViewController: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
      //  print("prefetch \(indexPaths)")
    }
              
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
       // print("cancel prefetch \(indexPaths)")
    }
}
