//
//  MediaDetailViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/9.
//

import UIKit
import Combine
//For iOS 14 Apparently there is a new bug in UICollectionView that is causing scrollToItem to not work when paging is enabled. The work around is to disable paging before calling scrollToItem, then re-enabling it afterwards:
class MediaDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIStackView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var textPreviewLabel: ShowMoreLabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet var singleTap: UITapGestureRecognizer!
    
    private var compressHeight: CGFloat!
    private var pageBeforeRotate: Int?
    private var dataSource: UICollectionViewDiffableDataSource<Section,MediaViewModel>!
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: MediaDetailViewModel
    private let startIndex: Int
    
    enum Section: Int, CaseIterable {
        case main
    }
    
    init(viewModel: MediaDetailViewModel, startIndex: Int = 0){
        self.viewModel = viewModel
        self.startIndex = startIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder){fatalError("init(coder:) has not been implemented")}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = .pageCarouselLayout
        configureCollectionViewDataSource()
        bindViewModelInput()
        bindViewModelOutput()
        configureButtonActions()
        configureGestureActions()
        textView.textContainer.lineFragmentPadding = .zero
        textView.textContainerInset = .zero
        textView.layoutManager.usesFontLeading = false
        compressHeight = textViewHeightConstraint.constant
    }

    var appeared = false
    
//    viewDidLayoutSubviews get's called every time when the layout is changing
//    viewDidLayoutSubviews get's called when the direct subviews of my view did layout, but the subviews of that subviews did not layout at that moment, so you can't get the size of them.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //handle screen rotation
        if let pageBeforeRotate {
            let offset = (collectionView.bounds.width) * CGFloat(pageBeforeRotate)
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        }
        pageBeforeRotate = nil // key
        
        if !appeared{
            appeared = true
            collectionView.scrollToItem(at: IndexPath(item: startIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
        
        updatePageNumber(for: collectionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autoPlayVisibleCell()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard collectionView != nil else { return }
        let isLandscape = size.width > size.height
        pageBeforeRotate = Int(collectionView.contentOffset.x / (collectionView.frame.width))
        
        coordinator.animate(alongsideTransition: { context in
            self.topView.alpha = isLandscape ? 0 : 1
            self.bottomView.alpha = isLandscape ? 0 : 1
        }){ _ in
            self.bottomView.isHidden = isLandscape
        }
    }
    
    private func configureCollectionViewDataSource(){
        
        let photoCellRegistration = UICollectionView.CellRegistration<PhotoDetailCell,PhotoViewModel>(cellNib: UINib(nibName: String(describing: PhotoDetailCell.self), bundle: nil)) { cell, indexPath, viewModel in
            cell.configure(with: viewModel)
            cell.delegate = self
        }
        
        let videoCellRegistration = UICollectionView.CellRegistration<VideoDetailCell,VideoViewModel>(cellNib: UINib(nibName: String(describing: VideoDetailCell.self), bundle: nil)) { cell, indexPath, viewModel in
            cell.configure(with: viewModel,index: indexPath.row)
            cell.delegate = self
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section,MediaViewModel>(collectionView: collectionView){ collectionView, indexPath, item in
            switch item {
            case let viewModel as PhotoViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: photoCellRegistration, for: indexPath, item: viewModel)
            case let viewModel as VideoViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: videoCellRegistration, for: indexPath, item: viewModel)
            default: fatalError("Unknown cell view model type")
            }
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section,MediaViewModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot,animatingDifferences: false)
    }
    
    private func bindViewModelInput(){
        dismissButton.publisher(for: .touchUpInside)
            .map{_ in}
            .bind(to: viewModel.input.dismiss)
            .store(in: &subscriptions)
    }
    
    private func bindViewModelOutput(){
        
        viewModel.output.userName
            .assign(to: \.text!, on: userNameLabel)
            .store(in: &subscriptions)
        
        viewModel.output.userImageData
            .receive(on: DispatchQueue.main)
            .map(UIImage.init(data:))
            .assign(to: \.image, on: userImageView)
            .store(in: &subscriptions)
        
        viewModel.output.mediaViewModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cellViewModels in
                guard let self = self else { return }
                var snapshot = dataSource.snapshot()
                if snapshot.numberOfItems == 0{
                    snapshot.appendItems(cellViewModels, toSection: .main)
                    dataSource.apply(snapshot,animatingDifferences: false)
                }else{
                    snapshot.appendItems(cellViewModels, toSection: .main)
                    dataSource.apply(snapshot,animatingDifferences: false)
                }
            }.store(in: &subscriptions)
        
        viewModel.output.text
            .sink { [weak self] text in
                guard let self = self else { return }
                let textViewAttributes = textView.attributedText.attributes(at: 0, effectiveRange: nil)
                let textViewAttributedText = NSAttributedString(string: text, attributes: textViewAttributes)
                textView.attributedText = textViewAttributedText
                textPreviewLabel.text = text
                textContainerView.isHidden = text.isEmpty
            }.store(in: &subscriptions)
    }
    
    func scrollToIndex(index:Int) {
      let rect = self.collectionView.layoutAttributesForItem(at: IndexPath(row: index, section: 0))?.frame
      self.collectionView.scrollRectToVisible(rect!, animated: false)
    }

    
    private func configureButtonActions(){

        commentButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.present(TODO("留言區"), animated: true)
            }.store(in: &subscriptions)
        
        shopButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.present(TODO("商品頁面"), animated: true)
            }.store(in: &subscriptions)
    }
    
    private func configureGestureActions(){
    
        textContainerView.addGestureRecognizer(singleTap)
        singleTap.publisher()
            .sink { [weak self] _ in
                guard let self = self else { return }
                textView.isTextTruncated ? expandText() : shrinkText()
            }.store(in: &subscriptions)
    }
    
    private func autoPlayVisibleCell(){
        let indexPathToPlay = collectionView.indexPathsForVisibleItems.filter({ indexPath in
            let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)!.frame
            let isCellFullyVisible = collectionView.bounds.contains(cellFrame)
            return isCellFullyVisible
        }).sorted { $0.section < $1.section || $0.item < $1.item }
        if let toPlay = indexPathToPlay.first, let cell = collectionView.cellForItem(at: toPlay) as? VideoDetailCell{
            cell.playVideo()
        }
    }
    
    private func expandText(){
        
        let contentSize = textView.sizeThatFits(textView.bounds.size)
        let newHeight = contentSize.height
        let maxHeight = view.bounds.height * 0.3
        
        textViewHeightConstraint.constant = min(newHeight, maxHeight)
        textView.isScrollEnabled = newHeight > maxHeight
        
        UIView.animate(withDuration: 0.3, delay:0, animations: {
            self.textPreviewLabel.alpha = 0
            self.textView.alpha = 1
            self.maskView.alpha = 0.6
            self.view.layoutIfNeeded()
            // if the textView is in a collectionView cell, here you need to call layoutIfNeeded() on the cell and then:
            
            // - if using regular collectionView:
            // collectionViewController.collectionView.collectionViewLayout.invalidateLayout()
            
            // - or if using compositional layout and diffable data source:
            // let snapshot = collectionViewController.diffableDataSource.snapshot()
            // collectionViewController.diffableDataSource.apply(snapshot, animatingDifferences: true)
        }, completion: nil)
    }
    
    private func shrinkText(){
        textViewHeightConstraint.constant = compressHeight
        textView.isScrollEnabled = true //Key!

        UIView.animate(withDuration: 0.3, animations: {
            self.textPreviewLabel.alpha = 1
            self.textView.alpha = 0
            self.maskView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            self.textView.contentOffset.y = 0
            self.textView.isScrollEnabled = false
        }
    }

}

extension MediaDetailViewController: UICollectionViewDelegate, UIScrollViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if pageNumberLabel.alpha == 0{
            (cell as? VideoDetailCell)?.playbackControlView.alpha = 0
        }else{
            (cell as? VideoDetailCell)?.playbackControlView.alpha = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? VideoDetailCell)?.stopVideo()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePageNumber(for: scrollView)
        let minContentOffsetX = CGFloat(0)
        let maxContentOffsetX = max(0, scrollView.contentSize.width - scrollView.bounds.width)
        if scrollView.contentOffset.x < minContentOffsetX || scrollView.contentOffset.x > maxContentOffsetX{
            showAllViews()
            collectionView.visibleCells.forEach { cell in
                (cell as? VideoDetailCell)?.playbackControlView.alpha = 1
            }
        }
    }
    
    // this method will always be called when paging is enabled or user flicks
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        autoPlayVisibleCell()
    }
    
    private func updatePageNumber(for scrollView: UIScrollView){
        let pageWidth = scrollView.bounds.width
        let totalPages = Int(max(1, scrollView.contentSize.width / pageWidth))
        var currentPage = Int(round(scrollView.contentOffset.x / pageWidth)) + 1
        currentPage = max(1, min(totalPages,currentPage))
        DispatchQueue.main.async{
            self.pageNumberLabel.text = "\(currentPage) / \(totalPages)"
        }
    }
    
    private func hideAllViews(){
        UIView.animate(withDuration: 0.2) {
            self.topView.alpha = 0
            self.bottomView.alpha = 0
        }
    }
    
    private func showAllViews(){
        topView.alpha = 1
        bottomView.alpha = 1
    }
}

extension MediaDetailViewController: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        print("prefetch cell \(indexPaths.map{$0.row})")
      
        let snap = dataSource.snapshot()
        let total = snap.numberOfItems
        if let cell = indexPaths.first?.row{
            if cell == total - 2{
                print("reached cell \(cell)load more")
            }
        }
    }
}



extension MediaDetailViewController: PhotoDetailCellDelegate {
    
    func cellDidTap(_ cell: PhotoDetailCell) {
        
        if !textView.isTextTruncated{
            shrinkText()
        }else{
            UIView.animate(withDuration: 0.15){
                self.topView.alpha = self.topView.alpha == 0 ? 1 : 0
                self.bottomView.alpha = self.bottomView.alpha == 0 ? 1 : 0
            }
        }
    }
    
    func cellDidZoom(_ cell: PhotoDetailCell){
        hideAllViews()
    }
    
    func cellDidEndZoom(_ cell: PhotoDetailCell) {
        
    }
}


extension MediaDetailViewController: VideoCellDelegate{
 
    func cellDidTap(_ cell: VideoDetailCell) {
        if !textView.isTextTruncated{
            shrinkText()
        }else{
            UIView.animate(withDuration: 0.2){
                self.topView.alpha = self.topView.alpha == 0 ? 1 : 0
                self.bottomView.alpha = self.bottomView.alpha == 0 ? 1 : 0
            }
        }
    }
    
    func cellDidZoom(_ cell: VideoDetailCell){
        hideAllViews()
    }
    
    func cellDidEndZoom(_ cell: VideoDetailCell) {
        
    }
}
