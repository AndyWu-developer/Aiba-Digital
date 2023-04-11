//
//  CollectionViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/6.
//

import UIKit
import Combine
import AVFoundation

class CollectionViewController: UICollectionViewController {
    
    init(){
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var postListDataSource: UICollectionViewDiffableDataSource<UUID,AnyHashable>!
    
    private let viewModel = CollectionViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
       
        viewModel.output.postViewModels
            .sink { [unowned self] viewModelGroup in
                var snapshot = self.postListDataSource.snapshot()
                viewModelGroup.forEach { viewModels in
                    snapshot.appendSections([UUID()])
                    snapshot.appendItems(viewModels)
                }
                self.postListDataSource.apply(snapshot,animatingDifferences: false)
            }.store(in: &subscriptions)
    }
    
    private func configureCollectionView(){
        let postListLayout: UICollectionViewLayout = {
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .estimated(200)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets.bottom = 5
            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
        }()
        
        collectionView.collectionViewLayout = postListLayout
        collectionView.backgroundColor = .gapGray
    }
    
    private func configureDataSource(){
        
        let postHeaderCellRegistration = UICollectionView.CellRegistration<PostHeaderCell, PostHeaderViewModel>(cellNib: UINib(nibName: "PostHeaderCell", bundle: nil)){ cell, indexPath, viewModel in
            cell.configure(with: viewModel)
        }
        
        let postMediaCellRegistration = UICollectionView.CellRegistration<PostMediaCell, PostMediaViewModel>(cellNib: UINib(nibName: "PostMediaCell", bundle: nil)){ cell, indexPath, viewModel in
            cell.configure(with: viewModel)
        }
        
        let postTextCellRegistration = UICollectionView.CellRegistration<PostTextCell, PostTextViewModel>(cellNib: UINib(nibName: "PostTextCell", bundle: nil)){ cell, indexPath, viewModel in
            cell.configure(with: viewModel)
        }
        
        let postActionCellRegistration = UICollectionView.CellRegistration<PostActionCell, PostActionViewModel>(cellNib: UINib(nibName: "PostActionCell", bundle: nil)){ cell, indexPath, viewModel in
            cell.configure(with: viewModel)
        }
        
        postListDataSource = UICollectionViewDiffableDataSource<UUID,AnyHashable>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let viewModel as PostHeaderViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postHeaderCellRegistration, for: indexPath, item: viewModel)
            case let viewModel as PostMediaViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postMediaCellRegistration, for: indexPath, item: viewModel)
            case let viewModel as PostTextViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postTextCellRegistration, for: indexPath, item: viewModel)
            case let viewModel as PostActionViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postActionCellRegistration, for: indexPath, item: viewModel)
            default: fatalError("Unknown type")
            }
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<UUID,AnyHashable>()
        postListDataSource.apply(snapshot,animatingDifferences: false)
    }
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        
//        guard let indexPathToPlay = collectionView.indexPathsForVisibleItems.filter({ indexPath in
//            let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)!.frame
//            let cellCenter = CGPoint(x: cellFrame.midX, y: cellFrame.minY + cellFrame.height/3)
//            let isCellVisible = collectionView.bounds.contains(cellCenter)
//            return isCellVisible
//        }).min() else {
//            sharedPlayers.forEach{$0.pause()}
//            return
//        }
//        
//        if indexPathToPlay != currentPlayingIndexPath, currentPlayingIndexPath != nil {
//            sharedPlayers[currentPlayingIndexPath!.row % sharedPlayers.count].pause()
//        }
//        
//        if let viewModel = postListDataSource.itemIdentifier(for: indexPathToPlay) as? PostMediaViewModel{
//            viewModel.player = AVPlayer()
//        }
//    
//        let cell = collectionView.cellForItem(at: indexPathToPlay) as! PostCell
//        cell.player = sharedPlayers[indexPathToPlay.row % sharedPlayers.count]
//        cell.player?.play()
//        currentPlayingIndexPath = indexPathToPlay
//    }

}
