//
//  PhotoCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/15.
//

import UIKit
import Combine

protocol PhotoCellDelegate: AnyObject{
    func cellDidTap(_ cell: PhotoCell)
    func cellDidZoom(_ cell: PhotoCell)
    func cellDidEndZoom(_ cell: PhotoCell)
}

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: PhotoCellDelegate?
    
    private var hasZoomedIn = false
    private var imageProcessSubscription = Set<AnyCancellable>()
    private var subscriptions = Set<AnyCancellable>()
    
    private let singleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        return tap
    }()
    
    private let doubleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 2
        return tap
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureGestures()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = contentView.bounds
        configureZoomScale(for: scrollView)
        centerZoomedView(in: scrollView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageProcessSubscription.removeAll()
    }
    
    func configure(with viewModel: PhotoCellViewModel){
        // layoutIfNeeded() //Key!!! or roation would look weird
        imageProcessSubscription.removeAll()
        imageView.image = nil
        
        viewModel.output.imageDimensions
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] in
                guard let self else { return }
                imageView.bounds.size = $0
                scrollView.contentSize = imageView.bounds.size
                configureZoomScale(for: scrollView)
            }
            .store(in: &imageProcessSubscription)
        
        viewModel.output.imageData
            .receive(on: DispatchQueue.main)
            .map(UIImage.init(data:))
            .sink { [weak self] image in
                self?.imageView.image = image
            }.store(in: &imageProcessSubscription)
    }
    
    private func configureGestures(){
        contentView.addGestureRecognizer(singleTap)
        imageView.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
        
        singleTap.publisher()
            .sink { [weak self] _ in
                guard let self = self else { return }
                delegate?.cellDidTap(self)
            }.store(in: &subscriptions)
        
        doubleTap.publisher()
            .sink { [weak self] gestureRecognizer in
                guard let self = self else { return }
                let tappedView = gestureRecognizer.view!
                let pointInView = gestureRecognizer.location(in: tappedView)
                var newZoomScale = scrollView.minimumZoomScale + (scrollView.maximumZoomScale - scrollView.minimumZoomScale) / 2
                
                if scrollView.zoomScale >= newZoomScale || abs(scrollView.zoomScale - newZoomScale) <= 0.01 {
                    newZoomScale = scrollView.minimumZoomScale
                }
                
                let width = scrollView.bounds.width / newZoomScale
                let height = scrollView.bounds.height / newZoomScale
                let originX = pointInView.x - (width / 2.0)
                let originY = pointInView.y - (height / 2.0)
                
                let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)
                scrollView.zoom(to: rectToZoomTo, animated: true)
            }.store(in: &subscriptions)
    }
    
    //Key Function1
    private func configureZoomScale(for scrollView: UIScrollView){
        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else { return }
        let widthScale = scrollView.bounds.width / zoomedView.bounds.width
        let heightScale = scrollView.bounds.height / zoomedView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = minScale * 4
        scrollView.zoomScale = minScale
    }
    
    //Key Function2
    private func centerZoomedView(in scrollView: UIScrollView){
        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else { return }
        let xOffset = max(0, (scrollView.bounds.width - zoomedView.frame.width) / 2)
        let yOffset = max(0, (scrollView.bounds.height - zoomedView.frame.height) / 2)
        zoomedView.frame.origin = CGPoint(x: xOffset, y: yOffset)
    }
    
}


extension PhotoCell: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerZoomedView(in: scrollView)
        scrollView.isScrollEnabled = scrollView.zoomScale > scrollView.minimumZoomScale
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > scrollView.minimumZoomScale, !hasZoomedIn {
            hasZoomedIn = true
            delegate?.cellDidZoom(self)
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == scrollView.minimumZoomScale{
            hasZoomedIn = false
            delegate?.cellDidEndZoom(self)
        }
    }
    
}
