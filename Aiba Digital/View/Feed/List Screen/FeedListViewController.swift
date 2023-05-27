//
//  FeedListViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/22.
//

import UIKit
import Combine

class FeedListViewController: UIViewController {
    
    typealias FeedID = String
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<FeedID,FeedViewModel>!
    private var subscriptions = Set<AnyCancellable>()
    private var currentPlayingIndexPath: IndexPath?
    private var shouldInvalidateLayout = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        bindViewModelInput()
        bindViewModelOutput()
        //configureButtonActions()
    }

    private func configureCollectionViewLayout(){
        
       let listStyleLayout: UICollectionViewLayout = {
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.showsSeparators = false
            let layout = UICollectionViewCompositionalLayout.list(using: config)
            return layout
//            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
//            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
//            let section = NSCollectionLayoutSection(group: group)
//            section.contentInsets.bottom = 5
//            let layout = UICollectionViewCompositionalLayout(section: section)
//            return layout
        }()
        
        collectionView.collectionViewLayout = listStyleLayout
        collectionView.backgroundColor = .gapGray
    }
   
    private func configureCollectionViewDataSource(){
        
        let postHeaderCellRegistration = UICollectionView.CellRegistration<PostHeaderCell, FeedHeaderViewModel>(cellNib: UINib(nibName: String(describing: PostHeaderCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.configure(with: viewModel)
        }
        
        let postMediaCellRegistration = UICollectionView.CellRegistration<FeedMediaCell, FeedMediaCellViewModel>(cellNib: UINib(nibName: String(describing: FeedMediaCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.viewModel = viewModel
        }
        
        let postTextCellRegistration = UICollectionView.CellRegistration<PostTextCell, FeedTextViewModel>(cellNib: UINib(nibName: String(describing: PostTextCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.delegate = self
            cell.configure(with: viewModel)
        }
        
        let postActionCellRegistration = UICollectionView.CellRegistration<PostActionCell, FeedActionViewModel>(cellNib: UINib(nibName: String(describing: PostActionCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.configure(with: viewModel)
        }
        
        dataSource = UICollectionViewDiffableDataSource<FeedID,FeedViewModel>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let viewModel as FeedHeaderViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postHeaderCellRegistration, for: indexPath, item: viewModel)
                
            case let viewModel as FeedMediaCellViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postMediaCellRegistration, for: indexPath, item: viewModel)
                
            case let viewModel as FeedTextViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postTextCellRegistration, for: indexPath, item: viewModel)
                
            case let viewModel as FeedActionViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postActionCellRegistration, for: indexPath, item: viewModel)
                
            default: fatalError("Unknown view model type")
            }
        }
    }
    
    let feeds = [Feed(),Feed(),Feed(),Feed(),Feed(),Feed(),Feed(),Feed(),Feed(),Feed(),
                 Feed(),Feed(),Feed(),Feed(),Feed(),Feed(),Feed(),Feed(),Feed(),Feed(),]
    
    private func bindViewModelInput(){
        
        var snap = NSDiffableDataSourceSnapshot<FeedID,FeedViewModel>()
        feeds.forEach { feed in
            snap.appendSections([feed.ID])
            snap.appendItems([feed.header, feed.media, feed.text, feed.action].compactMap{$0})
        }
        dataSource.apply(snap,animatingDifferences: false)
    }
    
    private func bindViewModelOutput(){
         
    }
}

extension FeedListViewController: UICollectionViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let indexPathToPlay = collectionView.indexPathsForVisibleItems.filter({ indexPath in
            let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)!.frame
            let cellCenter = CGPoint(x: cellFrame.midX, y: cellFrame.minY + cellFrame.height/3)
            let isCellVisible = collectionView.bounds.contains(cellCenter)
            return isCellVisible
        }).min() else {
            //sharedPlayers.forEach{$0.pause()}
           // print("no cell should play ")
            return
        }
      //  print("cell \(indexPathToPlay.row) should play")
        
//        if indexPathToPlay != currentPlayingIndexPath, currentPlayingIndexPath != nil {
//            sharedPlayers[currentPlayingIndexPath!.row % sharedPlayers.count].pause()
//        }
//            
//        let cell = collectionView.cellForItem(at: indexPathToPlay) as! PostCell
//        cell.player = sharedPlayers[indexPathToPlay.row % sharedPlayers.count]
//        cell.player?.play()
//        currentPlayingIndexPath = indexPathToPlay
    }
    
}

extension FeedListViewController: PostTextCellDelegate{
    
    func updateHeight(_ cell: PostTextCell) {
         let snapshot = dataSource.snapshot()
         dataSource.apply(snapshot, animatingDifferences: true)
    }
}

