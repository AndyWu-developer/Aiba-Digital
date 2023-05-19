//
//  GalleryViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/9.
//

import UIKit
import Combine

class MediaDetailViewController: UIViewController {
    
 
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var scrollIndicator: ScrollIndicator!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var postInfoView: UIStackView!
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
    @IBOutlet var showTextSingleTap: UITapGestureRecognizer!
    @IBOutlet var hideTextSingleTap: UITapGestureRecognizer!
    
    let text = "美國NOMAD iPhone 14 Pro\n\n真牛皮皮革背板殼！現貨供應中\n\n艾巴數位\n台中市南屯區大墩路894號\n04-23272366\n#NOMAD\n#牛皮手機殼"
    
    private var compressHeight: CGFloat!
    private var pageBeforeRotate: Int?
    private var dataSource: UICollectionViewDiffableDataSource<Int,MediaCellViewModel>!
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: MediaDetailViewModel
    
    init(viewModel: MediaDetailViewModel = MediaDetailViewModel()){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        configureCollectionViewLayout()
        configureDataSource()
        bindViewModelInput()
        bindViewModelOutput()
        configureButtonActions()
        configureGestureActions()
        addGradientLayer()
        textView.textContainer.lineFragmentPadding = .zero
        textView.textContainerInset = .zero
        textView.layoutManager.usesFontLeading = false
        compressHeight = textViewHeightConstraint.constant
        
    }

//    viewDidLayoutSubviews get's called every time when the layout is changing
//    viewDidLayoutSubviews get's called when the direct subviews of my view did layout, but the subviews of that subviews did not layout at that moment, so you can't get the size of them.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //handle screen rotation
        if let pageBeforeRotate {
            let offset = (collectionView.bounds.width) * CGFloat(pageBeforeRotate)
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        }
        scrollIndicator.updatePosition(for: collectionView)
        updatePageNumber(for: collectionView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autoPlayVisibleCell()
        scrollIndicator.updatePosition(for: collectionView)
        updatePageNumber(for: collectionView)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let isLandscape = size.width > size.height
        pageBeforeRotate = Int(collectionView.contentOffset.x / (collectionView.frame.width))
        
        coordinator.animate(alongsideTransition: { context in
            self.dismissButton.alpha = isLandscape ? 0 : 1
            self.scrollIndicator.alpha = isLandscape ? 0 : 1
            self.postInfoView.alpha = isLandscape ? 0 : 1
        }){ _ in
            self.postInfoView.isHidden = isLandscape
        }
    }
    
    private func configureCollectionViewLayout(){
        
       let pageStyleLayout: UICollectionViewCompositionalLayout = {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
            let section = NSCollectionLayoutSection(group: group)
            
            let config = UICollectionViewCompositionalLayoutConfiguration()
            config.scrollDirection = .horizontal
            config.contentInsetsReference = .none //Key! https://stackoverflow.com/a/68475321/21419169
            let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
            return layout
        }()
        collectionView.collectionViewLayout = pageStyleLayout
    }
    
    private func configureDataSource(){
        
        let photoCellRegistration = UICollectionView.CellRegistration<PhotoCell,PhotoCellViewModel>(cellNib: UINib(nibName: String(describing: PhotoCell.self), bundle: nil)) { cell, indexPath, viewModel in
            cell.configure(with: viewModel)
            cell.delegate = self
        }
        
        let videoCellRegistration = UICollectionView.CellRegistration<VideoCell,VideoCellViewModel>(cellNib: UINib(nibName: String(describing: VideoCell.self), bundle: nil)) { cell, indexPath, viewModel in
            cell.configure(with: viewModel,index: indexPath.row)
        }
     
        dataSource = UICollectionViewDiffableDataSource<Int,MediaCellViewModel>(collectionView: collectionView){ collectionView, indexPath, item in
            switch item {
            case let viewModel as PhotoCellViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: photoCellRegistration, for: indexPath, item: viewModel)
            case let viewModel as VideoCellViewModel:
                return collectionView.dequeueConfiguredReusableCell(using: videoCellRegistration, for: indexPath, item: viewModel)
            default: fatalError("Unknown cell view model type")
            }
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int,MediaCellViewModel>()
        snapshot.appendSections([0])
        dataSource.apply(snapshot,animatingDifferences: false)
    }
    
    private func bindViewModelInput(){
        let textViewAttributes = textView.attributedText.attributes(at: 0, effectiveRange: nil)
        let textViewAttributedText = NSAttributedString(string: text, attributes: textViewAttributes)
        textView.attributedText = textViewAttributedText
        textPreviewLabel.text = text
        textContainerView.isHidden = text.isEmpty
    }
    
    private func bindViewModelOutput(){
        
        viewModel.output.mediaViewModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cellViewModels in
                guard let self = self else { return }
                var snapshot = dataSource.snapshot()
                snapshot.appendItems(cellViewModels, toSection: 0)
                dataSource.apply(snapshot,animatingDifferences: false)
            }.store(in: &subscriptions)
    }
    
    private func autoPlayVisibleCell(){
        let indexPathToPlay = collectionView.indexPathsForVisibleItems.filter({ indexPath in
            let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)!.frame
            let isCellFullyVisible = collectionView.bounds.contains(cellFrame)
            return isCellFullyVisible
        }).sorted { $0.section < $1.section || $0.item < $1.item }
        if let toPlay = indexPathToPlay.first, let cell = collectionView.cellForItem(at: toPlay) as? VideoCell{
            cell.playVideo()
        }
    }
    
    private func configureButtonActions(){
        
        dismissButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let itemsToDelete = dataSource.itemIdentifier(for: IndexPath(item: 0, section: 0))!
                var snapshot = dataSource.snapshot()
                snapshot.deleteItems([itemsToDelete])
                dataSource.apply(snapshot,animatingDifferences: true)
                autoPlayVisibleCell()
            }.store(in: &subscriptions)
    }
    
    private func configureGestureActions(){
    
        textContainerView.addGestureRecognizer(showTextSingleTap)
   
        showTextSingleTap.publisher()
            .sink { [weak self] _ in
                guard let self = self else { return }
                textView.isTextTruncated ? expandText() : shrinkText()
            }.store(in: &subscriptions)
    }
    
    private func expandText(){
        
        let contentSize = textView.sizeThatFits(textView.bounds.size)
        let newHeight = contentSize.height
        let maxHeight = view.bounds.size.height * 0.3
        
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
    
    private func addGradientLayer(){
        
    }
}


extension MediaDetailViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollIndicator.updatePosition(for: scrollView)
        updatePageNumber(for: scrollView)
        let minContentOffsetX = CGFloat(0)
        let maxContentOffsetX = max(0, scrollView.contentSize.width - scrollView.bounds.width)
        if scrollView.contentOffset.x < minContentOffsetX || scrollView.contentOffset.x > maxContentOffsetX{
            dismissButton.alpha = 1
            postInfoView.alpha = 1
            scrollIndicator.alpha = 1
        }
    }
    
    // this method will always be called when paging is enabled or user flicks
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        autoPlayVisibleCell()
    }
    
    private func updatePageNumber(for scrollView: UIScrollView){
        let pageWidth = scrollView.bounds.width
        let totalPages = Int(max(1, scrollView.contentSize.width / pageWidth))
        let currentPage = Int(scrollView.contentOffset.x / pageWidth + 1)
        pageNumberLabel.text = "\(currentPage) / \(totalPages)"
    }
}

extension MediaDetailViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? VideoCell)?.stopVideo()
//        if let cell = cell as? PhotoCell{
//            cell.scrollView.zoomScale = cell.scrollView.minimumZoomScale
//        }
    }
}

extension MediaDetailViewController: PhotoCellDelegate{
    
    func cellDidTap(_ cell: PhotoCell) {
        
        if !textView.isTextTruncated{
            shrinkText()
        }else{
            UIView.animate(withDuration: 0.15){
                self.dismissButton.alpha = self.dismissButton.alpha == 0 ? 1 : 0
                self.postInfoView.alpha = self.postInfoView.alpha == 0 ? 1 : 0
                self.scrollIndicator.alpha = self.scrollIndicator.alpha == 0 ? 1 : 0
            }
        }
    }
    
    func cellDidZoom(_ cell: PhotoCell) {
        UIView.animate(withDuration: 0.2) {
            self.dismissButton.alpha = 0
            self.postInfoView.alpha = 0
            self.scrollIndicator.alpha = 0
        }
    }
    
    func cellDidEndZoom(_ cell: PhotoCell) {}
}
