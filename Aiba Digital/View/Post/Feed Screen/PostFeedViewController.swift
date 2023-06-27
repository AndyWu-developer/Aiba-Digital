//
//  FeedListViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/22.
//

import UIKit
import Combine

class PostFeedViewController: UIViewController {
    
    typealias FeedID = String
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var plusButton: UIButton!
    
    private var dataSource: UICollectionViewDiffableDataSource<FeedID,FeedViewModel>!
    private var subscriptions = Set<AnyCancellable>()
    private var currentPlayingIndexPath: IndexPath?
    private let viewModel: PostFeedViewModel
    private var allPostLoaded = false
    private var isLoading = false
    private let loadLatestPosts = PassthroughSubject<Void,Never>()
    private let loadMorePosts = PassthroughSubject<Void,Never>()
    
    init(viewModel: PostFeedViewModel){
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
        configureButtonActions()
        extendedLayoutIncludesOpaqueBars = false
        edgesForExtendedLayout = []
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("did appear")
        playCellIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("will disappear")
    }
    
    
    private var currentPlayingIndexpath: IndexPath?
    private func configureCollectionViewLayout(){
        
       let listStyleLayout: UICollectionViewLayout = {
//            var config = UICollectionLayoutListConfiguration(appearance: .plain)
//            config.showsSeparators = false
//            let layout = UICollectionViewCompositionalLayout.list(using: config)
//            return layout
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets.bottom = 5
            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
        }()
        
        collectionView.collectionViewLayout = listStyleLayout
        collectionView.backgroundColor = .gapGray
        
    }
   
    private func configureCollectionViewDataSource(){
        
        let postHeaderCellRegistration = UICollectionView.CellRegistration<PostHeaderCell, PostHeaderViewModel>(cellNib: UINib(nibName: String(describing: PostHeaderCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.viewModel = viewModel
        }
        
        let postMediaCellRegistration = UICollectionView.CellRegistration<PostMediaCell, PostMediaViewModel>(cellNib: UINib(nibName: String(describing: PostMediaCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.viewModel = viewModel
        }
        
        let postTextCellRegistration = UICollectionView.CellRegistration<PostTextCell, PostTextViewModel>(cellNib: UINib(nibName: String(describing: PostTextCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.delegate = self
            cell.configure(with: viewModel)
        }
        
        let postActionCellRegistration = UICollectionView.CellRegistration<PostActionCell, PostActionViewModel>(cellNib: UINib(nibName: String(describing: PostActionCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.configure(with: viewModel)
        }
        
        dataSource = UICollectionViewDiffableDataSource<FeedID,FeedViewModel>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let viewModel as PostHeaderViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postHeaderCellRegistration, for: indexPath, item: viewModel)
                
            case let viewModel as PostMediaViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postMediaCellRegistration, for: indexPath, item: viewModel)
                
            case let viewModel as PostTextViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postTextCellRegistration, for: indexPath, item: viewModel)
                
            case let viewModel as PostActionViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: postActionCellRegistration, for: indexPath, item: viewModel)
                
            default: fatalError("Unknown view model type")
            }
        }
    }
    
    private func bindViewModelInput(){
        // need error handling :)
        plusButton.publisher(for: .touchUpInside)
            .map{ _ in }
            .bind(to: viewModel.input.createNewPost)
            .store(in: &subscriptions)
    }
    
    private func bindViewModelOutput(){
        viewModel.output.postViewModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModels in
                guard let self else { return }
                guard !viewModels.isEmpty else {
                    print("all post loaded")
                    allPostLoaded = true
                    return
                }
                
                var snap = dataSource.snapshot()
                viewModels.forEach { feed in
                    snap.appendSections([feed.ID])
                    snap.appendItems([feed.header, feed.media, feed.text, feed.action].compactMap{$0})
                }
                // animatingDifferences = false will cause collectionview jump to top on each update
                dataSource.apply(snap,animatingDifferences: true)
            }.store(in: &subscriptions)
        
        
    }
    
    private func configureButtonActions(){
     
    }
}

extension PostFeedViewController: UICollectionViewDelegate{
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (offsetY > contentHeight - scrollView.frame.height * 4) && !isLoading {
            //print("loadMoreData")
        }
      
        playCellIfNeeded()
    }
    
    private func playCellIfNeeded(){
        print("invoked")
        let cellToPlay = collectionView.visibleCells
            .filter {$0 is PostMediaCell}
            .filter {
                let threshold = CGPoint(x: $0.frame.midX, y: $0.frame.minY + $0.frame.height/3)
                return collectionView.bounds.contains(threshold)
            }
            .min {$0.frame.midY < $1.frame.midY}
        
        guard let mediaCell = cellToPlay as? PostMediaCell else { print("gg");return }
        
        let indexpath = collectionView.indexPath(for: mediaCell)
        
        if indexpath != currentPlayingIndexpath {
            print("cell \(indexpath!.section + 1) should play")
            if let prev = currentPlayingIndexpath{
                (collectionView.cellForItem(at: prev) as? PostMediaCell)?.canPlayVideo = false
            }
            currentPlayingIndexpath = indexpath
            mediaCell.canPlayVideo = true
        }
       
    }
}

extension PostFeedViewController: PostTextCellDelegate{
    
    func updateHeight(_ cell: PostTextCell) {
         let snapshot = dataSource.snapshot()
         dataSource.apply(snapshot, animatingDifferences: true)
    }
}

