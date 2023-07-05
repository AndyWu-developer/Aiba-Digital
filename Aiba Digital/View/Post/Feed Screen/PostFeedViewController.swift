//
//  FeedListViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/22.
//

import UIKit
import Combine

class PostFeedViewController: UIViewController {
    
    typealias PostID = String
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var fetchingState: FooterCell.State = .idle {
        didSet{
            if let visibleFooter = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter).first as? FooterCell{
                visibleFooter.configure(with: fetchingState)
               // collectionView.collectionViewLayout.invalidateLayout()
               // view.layoutIfNeeded()
            }
        }
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<PostID,AnyHashable>!
    private var subscriptions = Set<AnyCancellable>()
    
    
    //will be set to false when:
    // 1. initilize
    // 2. received posts > 0
    private var allPostLoaded = false {
        didSet{
            if allPostLoaded {
                print("all post loaded :)")
            
            }
        }
    }
    
    private var isLoadingPost = false
    
    private var refreshControl: UIRefreshControl = {
        let c = UIRefreshControl()
        return c
    }()
    
    private let latestNum = 2
    private let oldNum = 1
    
    private var playingIndexPath: IndexPath? {
        didSet{
            //same indexPath doesnt mean the same cell !
           // guard playingIndexPath != oldValue else { return }
            //PrevCell might not exisit (off screen)! use didEndDisplay to catch
            let prevCell = {
                if let prevIndexPath = oldValue {
                    return self.collectionView.cellForItem(at: prevIndexPath) as? PostMediaCell
                }
                return nil
            }()
            
            let curCell = {
                if let curIndexPath = self.playingIndexPath {
                    return self.collectionView.cellForItem(at: curIndexPath) as? PostMediaCell
                }
                return nil
            }()
            
            if curCell != prevCell {
                prevCell?.canPlayVideo = false
            }
            curCell?.canPlayVideo = true
        }
    }
    
    private let viewModel: PostFeedViewModel
    private let loadLatestPosts = PassthroughSubject<Void,Never>()
    private let loadMorePosts = PassthroughSubject<Void,Never>()
    private let createPostSubject = PassthroughSubject<Void,Never>()
    private let deletePostSubject = PassthroughSubject<String,Never>()
    
    init(viewModel: PostFeedViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("PostFeedViewController deinit")
    }
    
    func hideLoadingUI(){
        isLoadingPost = false
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        if allPostLoaded, collectionView.contentSize.height > collectionView.bounds.height {
            fetchingState = .reachedBottom
        }else{
            fetchingState = .idle
        }
    }
    
    func loadMorePost(){
        guard !isLoadingPost, !allPostLoaded else { print("denied request") ; return }
        print("start loading more post")
        isLoadingPost = true
        loadMorePosts.send(())
        fetchingState = .loading
    }
    
    func loadLatestPost(){
        isLoadingPost = true
        loadLatestPosts.send(())
        fetchingState = .idle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        configureAutoPlayback()
        collectionView.refreshControl = refreshControl
        bindViewModelInput()
        bindViewModelOutput()
     
        configureButtonActions()
       // FileManager.default.clearTmpDirectory()
     
        let barButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(barButtonTapped))
              
        navigationItem.rightBarButtonItem = barButton
        
        createPostSubject
            .bind(to: viewModel.input.createPost)
            .store(in: &subscriptions)
       
        startRefreshing()
    }
    
    private func startRefreshing(){
        guard let refreshControl = collectionView.refreshControl else {return}
        let top = collectionView.adjustedContentInset.top
        let y = refreshControl.frame.maxY + top
        collectionView.setContentOffset(CGPoint(x: 0, y: -y), animated: true)
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
    }
    
    @objc func barButtonTapped() {
        //createPostSubject.send(())
        //fetchingState = .error(message: "Try Again")
        loadMorePost()
        // var snap = dataSource.snapshot()
        // setting animatingDifferences to false will cause collectionview to jump on each update
        //dataSource.apply(snap, animatingDifferences: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playCellIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playingIndexPath = nil
    }
   
    private func configureCollectionViewLayout(){
        
       let listStyleLayout: UICollectionViewLayout = {
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
         
            let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
            layoutConfig.interSectionSpacing = 5
           
            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
           
            layoutConfig.boundarySupplementaryItems = [footer]
            let layout = UICollectionViewCompositionalLayout(section: section, configuration: layoutConfig)
            return layout
        }()
   
        collectionView.collectionViewLayout = listStyleLayout
        collectionView.backgroundColor = .gapGray
    }
     
    private func configureCollectionViewDataSource(){
        
        let postHeaderCellRegistration = UICollectionView.CellRegistration<PostHeaderCell, PostHeaderViewModel>(cellNib: UINib(nibName: String(describing: PostHeaderCell.self), bundle: nil)){ [unowned self] cell, indexPath, viewModel in
            cell.delegate = self
            cell.viewModel = viewModel
        }
       
        let postMediaCellRegistration = UICollectionView.CellRegistration<PostMediaCell, PostMediaViewModel>(cellNib: UINib(nibName: String(describing: PostMediaCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.viewModel = viewModel
        }
        //Be careful to use weak references in here 
        let postTextCellRegistration = UICollectionView.CellRegistration<PostTextCell, PostTextViewModel>(cellNib: UINib(nibName: String(describing: PostTextCell.self), bundle: nil)){ [unowned self] cell, indexPath, viewModel in
            cell.delegate = self
            cell.configure(with: viewModel)
        }
        
        let postActionCellRegistration = UICollectionView.CellRegistration<PostActionCell, PostActionViewModel>(cellNib: UINib(nibName: String(describing: PostActionCell.self), bundle: nil)){ cell, indexPath, viewModel in
            cell.configure(with: viewModel)
        }
        
        let loadingViewRegistration = UICollectionView.SupplementaryRegistration<FooterCell>(supplementaryNib: UINib(nibName: String(describing: FooterCell.self), bundle: nil), elementKind: UICollectionView.elementKindSectionFooter) { [unowned self] cell, elementKind, indexPath in
            cell.configure(with: fetchingState)
            cell.delegate = self
        }
        
        dataSource = UICollectionViewDiffableDataSource<PostID,AnyHashable>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
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
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: loadingViewRegistration, for: indexPath)
        }
    }
    
    private func bindViewModelInput(){
    
        loadLatestPosts
            .map{ [unowned self] in
                return latestNum
            }
            .bind(to: viewModel.input.loadLatestPosts)
            .store(in: &subscriptions)

        loadMorePosts
            .map{ [unowned self] in
                return oldNum
            }
            .bind(to: viewModel.input.loadMorePosts)
            .store(in: &subscriptions)
        
        deletePostSubject
            .bind(to: viewModel.input.deletePostID)
            .store(in: &subscriptions)
    }
    

    private func bindViewModelOutput(){
//        
//        viewModel.output.latestPostViewModels
//            .receive(on: DispatchQueue.main)
//            .delay(for: 1, scheduler: DispatchQueue.main)
//
//            .sink { [unowned self] viewModels in
//                defer { hideLoadingUI() }
//                allPostLoaded = viewModels.isEmpty
//                if viewModels.isEmpty { return }
//           
//                var snap = dataSource.snapshot()
//                snap.deleteSections(snap.sectionIdentifiers)
//                snap.deleteAllItems()
//                viewModels.forEach { post in
//                    snap.appendSections([post.ID])
//                    snap.appendItems([post.header, post.media, post.text, post.action].compactMap{$0})
//                }
//                dataSource.apply(snap, animatingDifferences: true)
//            }.store(in: &subscriptions)
//        
//        viewModel.output.oldPostViewModels
//            .receive(on: DispatchQueue.main)
//            .delay(for: 3, scheduler: DispatchQueue.main)
//            .sink { [unowned self] viewModels in
//                defer { hideLoadingUI() }
//                allPostLoaded = viewModels.isEmpty
//                if viewModels.isEmpty { return }
//                
//                var snap = dataSource.snapshot()
//                viewModels.forEach { feed in
//                    snap.appendSections([feed.ID])
//                    snap.appendItems([feed.header, feed.media, feed.text, feed.action].compactMap{$0})
//                }
//                // setting animatingDifferences to false will cause collectionview to jump on each update
//                dataSource.apply(snap, animatingDifferences: true)
//            }.store(in: &subscriptions)
        
        
        viewModel.output.latestPosts
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] result in
                defer { hideLoadingUI() }
                
                switch result{
                case .success(let viewModels):
                    allPostLoaded = viewModels.isEmpty
                    var snap = dataSource.snapshot()
                    snap.deleteSections(snap.sectionIdentifiers)
                    snap.deleteAllItems()
                    viewModels.forEach { post in
                        snap.appendSections([post.ID])
                        snap.appendItems([post.header, post.media, post.text, post.action].compactMap{$0})
                    }
                    dataSource.apply(snap, animatingDifferences: true)
                    
                case .failure(let error):
                    print("Cannot fetch latest posts \(error)")
                    break
                }
            }
            .store(in: &subscriptions)
        
        
        viewModel.output.oldPosts
            .receive(on: DispatchQueue.main)
            .delay(for: 2, scheduler: DispatchQueue.main)
            .sink { [unowned self] result in
                defer { hideLoadingUI() }
                switch result{
                case .success(let viewModels):
                    allPostLoaded = viewModels.isEmpty
                    if viewModels.isEmpty { return }
                    
                    var snap = dataSource.snapshot()
                    viewModels.forEach { feed in
                        snap.appendSections([feed.ID])
                        snap.appendItems([feed.header, feed.media, feed.text, feed.action].compactMap{$0})
                    }
                    dataSource.apply(snap, animatingDifferences: true)
                    
                case .failure(let error):
                    print("Cannot fetch more old posts \(error)")
                    break
                }
            }
            .store(in: &subscriptions)
        
        
        
        
        
    }
    
    private func configureButtonActions(){
        // Even if when the post is Loading (because of loading more), we want to fetch anyway
        collectionView.refreshControl?.publisher(for: .valueChanged)
            .sink{ [unowned self] c in
                loadLatestPost()
            }
            .store(in: &subscriptions)
    
    }
 
    

}

extension PostFeedViewController: UICollectionViewDelegate{
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        playCellIfNeeded()
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//
//        if (offsetY >= contentHeight - scrollView.frame.height * 3) && !isLoading{
//            print("loadMoreData")
//            isLoading = true
//            loadMorePosts.send(())
//        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.numberOfSections - indexPath.section <= 2 {
            print("request more posts")
            //loadMorePost()
        }
    }
    
    // This is important or the cell will still play when not on screen!
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
        if let mediaCell = cell as? PostMediaCell {
            print("DID END DISPLAY")
            mediaCell.canPlayVideo = false
        }
    }
 

//    // user drags and stops (willDecelerate is false).
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        playCellIfNeeded()
//    }
//    // user drags and the scroll continues afterward.
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        playCellIfNeeded()
//    }
//    // user uses the scroll-to-top feature.
//    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
//        playCellIfNeeded()
//    }
//    // scroll with animation
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        playCellIfNeeded()
//    }
   
    private func playCellIfNeeded(){
       
        let cellToPlay = collectionView.visibleCells
            .filter {$0 is PostMediaCell}
            .filter {
                let threshold = CGPoint(x: $0.frame.midX, y: $0.frame.minY + $0.frame.height/3)
                return collectionView.bounds.inset(by: collectionView.safeAreaInsets).contains(threshold)
            }
            .min{$0.frame.midY < $1.frame.midY}
        
        if cellToPlay != nil {
            playingIndexPath = collectionView.indexPath(for: cellToPlay!)
        }
    }
    
    
    private func configureAutoPlayback(){
        
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [unowned self] _ in
                playingIndexPath = nil
            }.store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .filter { [unowned self] _ in view.window != nil}
            .sink { [unowned self] _ in
                print("Active")
                playCellIfNeeded()
            }.store(in: &subscriptions)
    }
}


extension PostFeedViewController: PostHeaderCellDelegate{
    
    func delete(_ cell: PostHeaderCell) {
        
        if let deleteSectionIndex = collectionView.indexPath(for: cell)?.section{
            var snapshot = dataSource.snapshot()
            let deleteSectionID = snapshot.sectionIdentifiers[deleteSectionIndex]
            let items = snapshot.itemIdentifiers(inSection: deleteSectionID)
            snapshot.deleteItems(items)
            snapshot.deleteSections([deleteSectionID])
            dataSource.apply(snapshot,animatingDifferences: true)
            deletePostSubject.send(deleteSectionID)
        }
    }
}

extension PostFeedViewController: PostTextCellDelegate{
    
    func updateHeight(_ cell: PostTextCell) {
         let snapshot = dataSource.snapshot()
         dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension PostFeedViewController: FooterCellDelegate{
    
    func refreshButtonTapped(_ footerCell: FooterCell) {
        loadMorePost()
    }
    
}
