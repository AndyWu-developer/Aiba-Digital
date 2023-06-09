//
//  FeedMediaCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/23.
//

import UIKit
import Combine

class PostMediaCell: UICollectionViewCell {

    deinit {
        print("PostMediaCell deinit")
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    private enum Section { case main, sub }
    
    var canPlayVideo = false {
        didSet{
          
            if let videoCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? VideoPreviewCell{
                canPlayVideo ? videoCell.playVideo() : videoCell.stopVideo()
            }
        }
    }
    
    var viewModel: PostMediaViewModel!{
        didSet{
            bindViewModelOutput()
        }
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section,MediaViewModel>!
    private var subscriptions = Set<AnyCancellable>()
    
    private let selectedItemSubject = PassthroughSubject<MediaViewModel,Never>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionViewDataSource()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutIfNeeded() //don't even need to call this if you do things correctly :) really?
        layoutAttributes.size = collectionView.collectionViewLayout.collectionViewContentSize
        return layoutAttributes
    }
   
    private func configureCollectionViewDataSource(){
        
        let photoCellRegistration = UICollectionView.CellRegistration<PhotoPreviewCell,PhotoViewModel>(cellNib: UINib(nibName: String(describing: PhotoPreviewCell.self), bundle: nil)) { cell, indexPath, viewModel in
            cell.viewModel = viewModel
        }
        
        let videoCellRegistration = UICollectionView.CellRegistration<VideoPreviewCell,VideoViewModel>(cellNib: UINib(nibName: String(describing: VideoPreviewCell.self), bundle: nil)) { cell, indexPath, viewModel in
            cell.viewModel = viewModel
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section,MediaViewModel>(collectionView: collectionView){ collectionView, indexPath, item in
            switch item {
            case let viewModel as PhotoViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: photoCellRegistration, for: indexPath, item: viewModel)
            case let viewModel as VideoViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: videoCellRegistration, for: indexPath, item: viewModel)
            default: fatalError("Unknown MediaCellViewModel subclass")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let videoCell = cell as? VideoPreviewCell{
            videoCell.stopVideo()
        }
    }
    
    func bindViewModelOutput(){
        
        subscriptions.removeAll()
        
        selectedItemSubject
            .bind(to: viewModel.input.selectItem)
            .store(in: &subscriptions)
        
        var snapshot = NSDiffableDataSourceSnapshot<Section,MediaViewModel>()
        var layout: UICollectionViewLayout
        snapshot.appendSections([.main, .sub])
        
        let cellViewModels = viewModel.mediaViewModels
     
        switch cellViewModels.count{
        case 0:
            snapshot.appendItems(cellViewModels, toSection: .main)
            layout = .squareGridLayout(itemsPerRow: 3)
        case 1:
            snapshot.appendItems(cellViewModels, toSection: .main)
            layout = .oneItemGridLayout
        case 2:
            snapshot.appendItems(cellViewModels, toSection: .main)
            layout = .squareGridLayout(itemsPerRow: 2)
        case 3:
            snapshot.appendItems(cellViewModels, toSection: .main)
            let item = cellViewModels.first!
            if item.contentPixelHeight > item.contentPixelWidth {
                layout = .threeItemHorizontalGridLayout
            }else{
                layout = .threeItemVerticalGridLayout
            }
        case 4:
            snapshot.appendItems(cellViewModels, toSection: .main)
            layout = .squareGridLayout(itemsPerRow: 2)
            
        default:
            snapshot.appendItems([cellViewModels.first!], toSection: .main)
            snapshot.appendItems(Array(cellViewModels.dropFirst(1)), toSection: .sub)
            layout = .scrollableGridLayout()
        }
        dataSource.apply(snapshot,animatingDifferences: false)
        collectionView.setCollectionViewLayout(layout, animated: false)
//        viewModel.output.mediaViewModels too slow!
    }
}

extension PostMediaCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedItem = dataSource.itemIdentifier(for: indexPath){
            selectedItemSubject.send(selectedItem)
        }
    }
}

