//
//  FeedMediaCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/23.
//

import UIKit
import Combine

protocol FeedMediaCellDelegate: AnyObject {
    func update()
}

class FeedMediaCell: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    private enum Section { case main, sub }
    
    weak var delegate: FeedMediaCellDelegate?
    
    var viewModel: FeedMediaCellViewModel!{
        didSet{
            bindViewModelOutput()
        }
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section,MediaCellViewModel>!
    private var subscriptions = Set<AnyCancellable>()
    
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
    
    private let tableViewLayout: UICollectionViewLayout = {
        // To acheive a tableview dynamic height layout, make sure to:
        // 1. use .estimated height dimension for BOTH NSCollectionLayoutItem and NSCollectionLayoutGroup
        // 2. the group must be .horizontal not .vertical, so the group's heightDimension can be .estimated :)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(300))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(300))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,subitems: [item])
//      let gp = NSCollectionLayoutGroup.vertical(layoutSize: groupSize , subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
       // section.interGroupSpacing = 5
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private let twoThreeLayout: UICollectionViewLayout = {
        // there are exactly two cells per row and they have equal widths; the item’s layoutSize: width dimension is effectively ignored
        let topItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalWidth(1/2))
        let topItem = NSCollectionLayoutItem(layoutSize: topItemSize)
        
        let topGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(200))
        let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topGroupSize,
                                                       subitem: topItem, count: 2)
        topGroup.interItemSpacing = .fixed(1)
        
        let bottomItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalWidth(1/3))
        let bottomItem = NSCollectionLayoutItem(layoutSize: bottomItemSize)
        
        let bottomGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(200))
        let bottomGroup = NSCollectionLayoutGroup.horizontal(layoutSize: bottomGroupSize,
                                                       subitem: bottomItem, count: 3)
        bottomGroup.interItemSpacing = .fixed(1)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [topGroup, bottomGroup])
        group.interItemSpacing = .fixed(1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private let threeLayout: UICollectionViewLayout = {
        // there are exactly two cells per row and they have equal widths; the item’s layoutSize: width dimension is effectively ignored
        let topItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let topItem = NSCollectionLayoutItem(layoutSize: topItemSize)
        
        let topGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalWidth(1.7/2.7))
        
        let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topGroupSize,
                                                       subitem: topItem, count: 1)
        topGroup.interItemSpacing = .fixed(1)
        
        let bottomItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalWidth(1/2))
        let bottomItem = NSCollectionLayoutItem(layoutSize: bottomItemSize)
        
        let bottomGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(200))
        let bottomGroup = NSCollectionLayoutGroup.horizontal(layoutSize: bottomGroupSize,
                                                       subitem: bottomItem, count: 2)
        bottomGroup.interItemSpacing = .fixed(1)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [topGroup, bottomGroup])
        group.interItemSpacing = .fixed(1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private let twoColumnLayout: UICollectionViewLayout = {
        // there are exactly two cells per row and they have equal widths; the item’s layoutSize: width dimension is effectively ignored
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/2))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private let gridLayout: UICollectionViewLayout = {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 2
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment in
                if sectionIndex == 0{
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    let topGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1.7/2.7))
                    let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topGroupSize,
                                                                      subitem: item,count: 1)
                    let section = NSCollectionLayoutSection(group: topGroup)
                    return section
                }else{
                    let bottomItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1))
                    let bottomItem = NSCollectionLayoutItem(layoutSize: bottomItemSize)
                    let pages: CGFloat = 2 + 0.7
                    let bottomGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/pages), heightDimension: .fractionalWidth(1/pages))
                    let bottomGroup = NSCollectionLayoutGroup.horizontal(layoutSize: bottomGroupSize, subitems: [bottomItem])
                    let section = NSCollectionLayoutSection(group: bottomGroup)
                    section.interGroupSpacing = 2
                    section.orthogonalScrollingBehavior = .continuous
                    return section
                }
        }, configuration: configuration)
        return layout
    }()
    
    private let mygridLayout: UICollectionViewLayout = {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 2
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment in
                if sectionIndex == 0{
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    let topGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
                    let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topGroupSize,
                                                                      subitems: [item])
                    let section = NSCollectionLayoutSection(group: topGroup)
                    return section
                }else{
                    let bottomItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1))
                    let bottomItem = NSCollectionLayoutItem(layoutSize: bottomItemSize)
                    let pages: CGFloat = 2 + 0.7
                    let bottomGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/pages), heightDimension: .fractionalWidth(1/pages))
                    let bottomGroup = NSCollectionLayoutGroup.horizontal(layoutSize: bottomGroupSize, subitems: [bottomItem])
                    let section = NSCollectionLayoutSection(group: bottomGroup)
                    section.interGroupSpacing = 2
                    section.orthogonalScrollingBehavior = .continuous
                    return section
                }
        }, configuration: configuration)
        return layout
    }()
    
    
    private func configureCollectionViewDataSource(){
        
        let photoCellRegistration = UICollectionView.CellRegistration<PhotoPreviewCell,PhotoCellViewModel>(cellNib: UINib(nibName: String(describing: PhotoPreviewCell.self), bundle: nil)) { cell, indexPath, viewModel in
            cell.delegate = self
            cell.viewModel = viewModel
        }
        
        let videoCellRegistration = UICollectionView.CellRegistration<VideoPreviewCell,VideoCellViewModel>(cellNib: UINib(nibName: String(describing: VideoPreviewCell.self), bundle: nil)) { cell, indexPath, viewModel in
            cell.configure(with: viewModel, index: 0)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section,MediaCellViewModel>(collectionView: collectionView){ collectionView, indexPath, item in
            switch item {
            case let viewModel as PhotoCellViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: photoCellRegistration, for: indexPath, item: viewModel)
            case let viewModel as VideoCellViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: videoCellRegistration, for: indexPath, item: viewModel)
            default: fatalError("Unknown MediaCellViewModel subclass")
            }
        }
    }
    
    func bindViewModelOutput(){
        
        let cellViewModels = viewModel.mediaViewModels
        
        if viewModel.numberOfItems == 1{
            var snapshot = NSDiffableDataSourceSnapshot<Section,MediaCellViewModel>()
            snapshot.appendSections([.main])
            snapshot.appendItems(Array(cellViewModels.prefix(4)), toSection: .main)
            dataSource.apply(snapshot,animatingDifferences: false)
            collectionView.setCollectionViewLayout(twoColumnLayout, animated: false)
        }else if viewModel.numberOfItems == 2{
            var snapshot = NSDiffableDataSourceSnapshot<Section,MediaCellViewModel>()
            snapshot.appendSections([.main])
            snapshot.appendItems(Array(cellViewModels.prefix(1)), toSection: .main)
            dataSource.apply(snapshot,animatingDifferences: false)
            collectionView.setCollectionViewLayout(tableViewLayout, animated: false)
        }
        else{
            var snapshot = NSDiffableDataSourceSnapshot<Section,MediaCellViewModel>()
            snapshot.appendSections([.main, .sub])
            snapshot.appendItems([cellViewModels.first!], toSection: .main)
            snapshot.appendItems(Array(cellViewModels.dropFirst(1)), toSection: .sub)
            dataSource.apply(snapshot,animatingDifferences: false)
            collectionView.setCollectionViewLayout(mygridLayout, animated: false)
        }
//        viewModel.output.mediaViewModels too slow!
    }
    
  
}

extension FeedMediaCell: PhotoPreviewCellDelegate{
    func updateHegiht() {

    }
}
