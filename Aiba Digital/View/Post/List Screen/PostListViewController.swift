//
//  PostViewController.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import UIKit
import Combine
import AVFoundation

protocol PostListViewControllerDelegate: AnyObject{
    func plusButtonTapped()
}

class PostListViewController: UIViewController {
    
    var totalPlayers = [AVPlayer(),AVPlayer(),AVPlayer()]
    
    var playercount = 1
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var plusButton: AnimatedButton!
    var updating = false
    let cellViewModels = [PostCellViewModel(indexPath: IndexPath(item: 0, section: 0)),
                      PostCellViewModel(indexPath: IndexPath(item: 1, section: 0)),
                      PostCellViewModel(indexPath: IndexPath(item: 2, section: 0)),
                      PostCellViewModel(indexPath: IndexPath(item: 3, section: 0)),
                      PostCellViewModel(indexPath: IndexPath(item: 4, section: 0)),
                      PostCellViewModel(indexPath: IndexPath(item: 5, section: 0)),
                      PostCellViewModel(indexPath: IndexPath(item: 6, section: 0)),
                      PostCellViewModel(indexPath: IndexPath(item: 7, section: 0)),
                      PostCellViewModel(indexPath: IndexPath(item: 8, section: 0)),
                      PostCellViewModel(indexPath: IndexPath(item: 9, section: 0))
    ]
    private let viewModel: PostViewModel
  //  private var cellViewModels = [PostCellViewModel]()
    weak var flowDelegate: PostListViewControllerDelegate?
    
    let viewDidAppearSubject = PassthroughSubject<Void,Never>()
    let viewWillDisAppearSubject = PassthroughSubject<Void,Never>()
    
    
    private let postLayout: UICollectionViewLayout = {
        
        let postHeaderItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .absolute(50)))
        let postMediaItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .absolute(50)))
        let postTextItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .absolute(50)))
        let postActionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .absolute(40)))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .estimated(600)), subitems: [postHeaderItem, postMediaItem, postTextItem, postActionItem])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private let tableViewLayout: UICollectionViewLayout = {
        // To acheive a tableview dynamic height layout, make sure to:
        // 1. use .estimated height dimension for BOTH NSCollectionLayoutItem and NSCollectionLayoutGroup
//        // 2. the group must be .horizontal not .vertical, so the group's heightDimension can be .estimated :)
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                  heightDimension: .estimated(300))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                   heightDimension: .estimated(300))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,subitem: item,
//              count: 1)
//        let gp = NSCollectionLayoutGroup.vertical(layoutSize: groupSize , subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 5
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
//       Using ListConfiguration does the same thing with less code, but you cannot change the collectionView's background color :(
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }()
    
    init(viewModel: PostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
       
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = tableViewLayout
        collectionView.register(UINib(nibName: PostCell.nibName, bundle: nil), forCellWithReuseIdentifier: PostCell.reuseIdentifier)
        bindViewModelInput()
        bindViewModelOutput()
    }
    
    private func bindViewModelInput(){
        viewDidAppearSubject.subscribe(viewModel.input.userEnterScreen)
        viewWillDisAppearSubject.subscribe(viewModel.input.userLeaveScreen)
    }
    
    private func bindViewModelOutput(){
        
    }
}

extension PostListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    //The purpose of cellForRowAtIndexPath is to dequeue a cell and hand it data. That’s it. Full stop. The cell should take care of all of its state internally from this data. Simply pass the model object (or view model, depending on your architecture) and let the cell work its magic :)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cell for row \(indexPath)")
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseIdentifier, for: indexPath) as! PostCell
        cell.viewModel = cellViewModels[indexPath.row]
       // cell. = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        print("pressed")
        //collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    }
    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool ) {
//
//         let visibleIndexPaths = collectionView.indexPathsForVisibleItems
//         let fullyVisibleIndexPaths = visibleIndexPaths.filter { indexPath in
//             let layoutAttribute = collectionView.layoutAttributesForItem(at: indexPath)!
//             let cellFrame = layoutAttribute.frame.insetBy(dx: 0, dy: layoutAttribute.frame.height/3)
//             let isCellFullyVisible = collectionView.bounds.contains(cellFrame)
//             return isCellFullyVisible
//         }
//        print("can play at \(fullyVisibleIndexPaths.map{$0.row})")
//        let visibleTags = Notification.Name("visibleTags")
//        NotificationCenter.default.post(name: visibleTags, object: fullyVisibleIndexPaths)
//    }
    
   
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! PostCell).player = nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

//        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
//        let fullyVisibleIndexPaths = visibleIndexPaths.filter { indexPath in
//             let layoutAttribute = collectionView.layoutAttributesForItem(at: indexPath)!
//             let cellFrame = layoutAttribute.frame.insetBy(dx: 0, dy: layoutAttribute.frame.height/3)
//             let isCellFullyVisible = collectionView.bounds.contains(cellFrame)
//             return isCellFullyVisible
//        }
//        print("can play at \(fullyVisibleIndexPaths.map{$0.row})")
//        var visibleCells = collectionView.visibleCells
//        visibleCells.sort { cell1, cell2 in
//            collectionView.indexPath(for: cell1)!.row < collectionView.indexPath(for: cell2)!.row
//        }
//
//        visibleCells.enumerated().forEach { <#EnumeratedSequence<[UICollectionViewCell]>.Iterator.Element#> in
//            <#code#>
//        }
        collectionView.indexPathsForVisibleItems.sorted{$0 < $1}.prefix(3).forEach { index in
            if let cell = collectionView.cellForItem(at: index) as? PostCell{
                cell.player = totalPlayers[index.row % 3]
            }
        }


    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//
//       // collectionView.collectionViewLayout.ite
//        let visibleHeight:CGFloat = 349
//        // It's either we go forwards or backwards.
//        let indexOfItemToSnap = round(targetContentOffset.pointee.y / visibleHeight)
//        // Create custom flickVelocity.
//            let flickVelocity = velocity.y * 0.3
//
//            // Check how many pages the user flicked, if <= 1 then flickedPages should return 0.
//            let flickedPages = (abs(round(flickVelocity)) <= 1) ? 0 : round(flickVelocity)
//
//            let newVerticalOffset = ((indexOfItemToSnap + flickedPages) * 349) - collectionView.contentInset.top
//
//        var stoppedYPosition = targetContentOffset.pointee.y
//        let currentCell = Int(floor((stoppedYPosition) / 349))
//        print(currentCell)
//        print("stop at \(stoppedYPosition)")
//        let firstIndex = collectionView.indexPathsForVisibleItems.first!
//        print("fully visible index \(firstIndex)")
//        print(heights)
//        let offset = heights[0...firstIndex.row].reduce(0){ $0 + $1!}
//        print(offset)
//        let point = CGPoint(x: 0, y: (indexOfItemToSnap)*349 )
//        targetContentOffset.pointee = point
//    }
    //paging for pagingScrollView
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        // Switch the indicator when more than 50% of the previous/next page is visible.
//        let pageWidth = scrollView.frame.width
//        if currentPage != Int(floor((scrollView.contentOffset.x ) / pageWidth)){
//            currentPage = Int(floor((scrollView.contentOffset.x ) / pageWidth))
//            print("switched to page \(currentPage)")
//            //Load the visible page and also the page on either side of it to avoid flashes when the user starts scrolling
//            loadPage(currentPage - 1)
//            loadPage(currentPage)
//            loadPage(currentPage + 1)
//        }
//    }
    
}

extension PostListViewController: PostCellDelegate{
    func update(_ cell: PostCell) {
       // updating = true
//        DispatchQueue.main.async {
//            self.collectionView.performBatchUpdates(nil)
//        }
       
    }
  
//
//
    
}


extension UICollectionView {

    func isCellAtIndexPathFullyVisible(_ indexPath: IndexPath) -> Bool {

        guard let layoutAttribute = layoutAttributesForItem(at: indexPath) else {
            return false
        }

        let cellFrame = layoutAttribute.frame
        return self.bounds.contains(cellFrame)
    }

    func indexPathsForFullyVisibleItems() -> [IndexPath] {

        let visibleIndexPaths = indexPathsForVisibleItems

        return visibleIndexPaths.sorted{$0 < $1}.filter { indexPath in
            return isCellAtIndexPathFullyVisible(indexPath)
        }
    }
}

extension UITableView {

    func isCellAtIndexPathFullyVisible(_ indexPath: IndexPath) -> Bool {
        let cellFrame = rectForRow(at: indexPath)
        return bounds.contains(cellFrame)
    }

    func indexPathsForFullyVisibleRows() -> [IndexPath] {

        let visibleIndexPaths = indexPathsForVisibleRows ?? []
        return visibleIndexPaths.filter { indexPath in
            return isCellAtIndexPathFullyVisible(indexPath)
        }
    }
}
