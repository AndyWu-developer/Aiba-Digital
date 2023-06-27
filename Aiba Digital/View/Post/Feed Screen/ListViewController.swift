////
////  PostViewController.swift
////  Aiba Digital
////
////  Created by Andy on 2023/3/17.
////
//
//import UIKit
//import Combine
//import AVFoundation
//
//
//class ListViewController: UIViewController {
//    
//    @IBOutlet private weak var collectionView: UICollectionView!
//    @IBOutlet private weak var plusButton: AnimatedButton!
//    
//    private let sharedPlayers = [AVPlayer(),AVPlayer(),AVPlayer()]
//    private var currentPlayingIndexPath: IndexPath?
//    private var dataSource: UICollectionViewDiffableDataSource<String, String>!
//    private let cellViewModels = []
//    private let viewModel: ListViewModel
//    weak var flowDelegate: PostListViewControllerDelegate?
//    
//    let viewDidAppearSubject = PassthroughSubject<Void,Never>()
//    let viewWillDisAppearSubject = PassthroughSubject<Void,Never>()
// 
//    private let tableViewLayout: UICollectionViewLayout = {
//        // To acheive a tableview dynamic height layout, make sure to:
//        // 1. use .estimated height dimension for BOTH NSCollectionLayoutItem and NSCollectionLayoutGroup
//        // 2. the group must be .horizontal not .vertical, so the group's heightDimension can be .estimated :)
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                  heightDimension: .estimated(300))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                   heightDimension: .estimated(300))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,subitem: item,
//              count: 1)
//        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 5
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
//    }()
//    
//    init(viewModel: ListViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//         super.viewDidAppear(animated)
//        //collectionView.scrollsToTop
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//         super.viewWillDisappear(animated)
//         sharedPlayers.forEach{$0.pause()}
//     }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        collectionView.collectionViewLayout = tableViewLayout
//        collectionView.register(UINib(nibName: PostCell.nibName, bundle: nil), forCellWithReuseIdentifier: PostCell.reuseIdentifier)
//        bindViewModelInput()
//        bindViewModelOutput()
//    }
//    
//    private func bindViewModelInput(){
//        viewDidAppearSubject.subscribe(viewModel.input.userEnterScreen)
//        viewWillDisAppearSubject.subscribe(viewModel.input.userLeaveScreen)
//    }
//    
//    private func bindViewModelOutput(){
//        
//    }
//}
//
//extension ListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching{
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 10
//    }
//    
//    //The purpose of cellForRowAtIndexPath is to dequeue a cell and hand it data. That’s it. Full stop. The cell should take care of all of its state internally from this data. Simply pass the model object (or view model, depending on your architecture) and let the cell work its magic :)
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseIdentifier, for: indexPath) as! PostCell
//        cell.viewModel = cellViewModels[indexPath.row]
//        cell.delegate = self
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//    }
//    
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
//        let cell = collectionView.cellForItem(at: indexPathToPlay) as! PostCell
//        cell.player = sharedPlayers[indexPathToPlay.row % sharedPlayers.count]
//        cell.player?.play()
//        currentPlayingIndexPath = indexPathToPlay
//    }
//    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        
//       // collectionView.collectionViewLayout.ite
//        let visibleHeight:CGFloat = collectionView.bounds.width
//        // It's either we go forwards or backwards.
//        let indexOfItemToSnap = round(targetContentOffset.pointee.y / visibleHeight)
//        // Create custom flickVelocity.
//       // collectionView.scrollToItem(at: IndexPath(item: Int(indexOfItemToSnap), section: 0), at: .top, animated: true)
////        let flickVelocity = velocity.y * 0.3
////
////            // Check how many pages the user flicked, if <= 1 then flickedPages should return 0.
////        let flickedPages = (abs(round(flickVelocity)) <= 1) ? 0 : round(flickVelocity)
////
////        let newVerticalOffset = ((indexOfItemToSnap + flickedPages) * 349) - collectionView.contentInset.top
////
////        var stoppedYPosition = targetContentOffset.pointee.y
////        let currentCell = Int(floor((stoppedYPosition) / 349))
////
////        let offset = heights[0...firstIndex.row].reduce(0){ $0 + $1!}
////        print(offset)
////        let point = CGPoint(x: 0, y: (indexOfItemToSnap)*349 )
////        targetContentOffset.pointee = point
//
//    }
//    //paging for pagingScrollView
////    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
////        // Switch the indicator when more than 50% of the previous/next page is visible.
////        let pageWidth = scrollView.frame.width
////        if currentPage != Int(floor((scrollView.contentOffset.x ) / pageWidth)){
////            currentPage = Int(floor((scrollView.contentOffset.x ) / pageWidth))
////            print("switched to page \(currentPage)")
////            //Load the visible page and also the page on either side of it to avoid flashes when the user starts scrolling
////            loadPage(currentPage - 1)
////            loadPage(currentPage)
////            loadPage(currentPage + 1)
////        }
////    }
//    
//}
