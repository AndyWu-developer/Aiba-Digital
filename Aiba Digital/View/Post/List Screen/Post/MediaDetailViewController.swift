//
//  GalleryViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/9.
//

import UIKit
import Combine

class MediaDetailViewController: UIViewController {

    @IBOutlet weak var scrollIndicator: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    private var subscriptions = Set<AnyCancellable>()
    private var images = [UIImage(named: "image1"),
                        UIImage(named: "image2"),
                        UIImage(named: "image3"),
                        UIImage(named: "image4"),
    ]

    private var pageBeforeRotate: Int?
    private var playingIndexPath: IndexPath?
    private var dataSource: UICollectionViewDiffableDataSource<Int,MediaCellViewModel>!

    private let pageStyleLayout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        config.contentInsetsReference = .none //Key! https://stackoverflow.com/a/68475321/21419169
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        return layout
    }()
    
    private let singleTapGesture: UIGestureRecognizer = {
        let singleTap = UITapGestureRecognizer()
        singleTap.numberOfTapsRequired = 1
        return singleTap
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        collectionView.collectionViewLayout = pageStyleLayout
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.allowsSelection = false
        configureDataSource()
        view.addGestureRecognizer(singleTapGesture)
        singleTapGesture.publisher()
            .sink { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.2) {
                    self.indicatorView.alpha = self.indicatorView.alpha == 0 ? 1 : 0
                    self.scrollIndicator.alpha = self.scrollIndicator.alpha == 0 ? 1 : 0
                    self.dismissButton.alpha = self.dismissButton.alpha == 0 ? 1 : 0
                }
            }.store(in: &subscriptions)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let isLandscape = size.width > size.height
        pageBeforeRotate = Int(collectionView.contentOffset.x / (collectionView.frame.width))

        coordinator.animate(alongsideTransition: { context in
            self.collectionView.backgroundColor = isLandscape ? .black : .white
            self.scrollIndicator.alpha = isLandscape ? 0 : 1
            self.dismissButton.alpha = isLandscape ? 0 : 1
            self.indicatorView.alpha = isLandscape ? 0 : 1
        }, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //handle screen rotation
        if let pageBeforeRotate {
            let offset = (collectionView.bounds.width) * CGFloat(pageBeforeRotate)
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        }
        updateScrollIndicator(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollViewDidEndDecelerating(collectionView)
    }
    
    private func configureDataSource(){
        let cellRegistration = UICollectionView.CellRegistration<MediaCell,MediaCellViewModel> { cell, indexPath, viewModel in
            cell.configure(with: viewModel,index: indexPath.row)
        }
     
        dataSource = UICollectionViewDiffableDataSource<Int,MediaCellViewModel>(collectionView: collectionView){ collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int,MediaCellViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems([MediaCellViewModel(),MediaCellViewModel(),MediaCellViewModel(),MediaCellViewModel(),MediaCellViewModel()], toSection: 0)
        dataSource.apply(snapshot,animatingDifferences: false)
    }
}


extension MediaDetailViewController: UIScrollViewDelegate{
    
    func updateScrollIndicator(animated: Bool){
        let pageWidth = collectionView.bounds.width
        let totalPages = Int(max(1, collectionView.contentSize.width / pageWidth))
        
        //let maxContentOffsetX = max(0, collectionView.contentSize.width - pageWidth)
        var currentPage = Int(round(collectionView.contentOffset.x / pageWidth)) + 1
        currentPage = max(1, min(currentPage, totalPages))
        let interval = scrollIndicator.bounds.width / CGFloat(totalPages)
        
        let toMove = interval * CGFloat(currentPage - 1) + interval/2
        let offset = toMove - (scrollIndicator.bounds.midX)
        let scale = CGAffineTransform(scaleX: 1 / CGFloat(totalPages), y: 1)
        let translation = CGAffineTransform(translationX: offset , y: 0)
       
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.scrollIndicator.transform = scale.concatenating(translation)
            }
        }else{
            scrollIndicator.transform = scale.concatenating(translation)
        }
    }
  
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        updateScrollIndicator(animated: true)
//        let visibleCells = self.collectionView.indexPathsForVisibleItems
//            .sorted { top, bottom -> Bool in
//                return top.section < bottom.section || top.row < bottom.row
//            }.compactMap { indexPath -> ZoomableMediaCell? in
//                return collectionView.cellForItem(at: indexPath) as? ZoomableMediaCell
//            }
//        let indexPaths = collectionView.indexPathsForVisibleItems.sorted()
//        let cellCount = visibleCells.count
//        guard let firstCell = visibleCells.first, let firstIndex = indexPaths.first else {return}
//        checkVisibilityOfCell(cell: firstCell, indexPath: firstIndex)
//        if cellCount == 1 {return}
//        
//        guard let lastCell = visibleCells.last, let lastIndex = indexPaths.last else {return}
//        checkVisibilityOfCell(cell: lastCell, indexPath: lastIndex)
    }
    
    func checkVisibilityOfCell(cell: MediaCell, indexPath: IndexPath) {
        if let cellRect = (collectionView.layoutAttributesForItem(at: indexPath)?.frame) {
            let completelyVisible = collectionView.bounds.contains(cellRect)
            if completelyVisible {cell.playVideo()} else {cell.stopVideo()}
        }
    }
    // when paging is enabled or user flicks, this delegate method will always be called
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       
        let indexPathToPlay = collectionView.indexPathsForVisibleItems.filter({ indexPath in
            let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)!.frame
            let isCellFullyVisible = collectionView.bounds.contains(cellFrame)
            return isCellFullyVisible
        }).sorted { $0.section < $1.section || $0.item < $1.item }
        
        if let toPlay = indexPathToPlay.first, let cell = collectionView.cellForItem(at: toPlay) as? MediaCell{
            cell.playVideo()
        }
    }
}

extension MediaDetailViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! MediaCell).stopVideo()
    }
}
