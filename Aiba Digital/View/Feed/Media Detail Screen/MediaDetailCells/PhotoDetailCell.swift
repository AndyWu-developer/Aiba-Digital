//
//  PhotoCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/15.
//

import UIKit
import Combine

protocol PhotoDetailCellDelegate: AnyObject{
    func cellDidTap(_ cell: PhotoDetailCell)
    func cellDidZoom(_ cell: PhotoDetailCell)
    func cellDidEndZoom(_ cell: PhotoDetailCell)
}

class PhotoDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollView: AutoCenterScrollView!
    @IBOutlet weak var imageView: UIImageView!
    private var ratioConstraint: NSLayoutConstraint!
    weak var delegate: PhotoDetailCellDelegate?
    
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
        scrollView.maximumZoomScale = 5
        scrollView.decelerationRate = .fast
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageProcessSubscription.removeAll()
    }
    
    func configure(with viewModel: PhotoCellViewModel){
      
        imageProcessSubscription.removeAll()
        imageView.image = nil
        
        viewModel.output.imageDimensions
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] size in
                guard let self else { return }
                ratioConstraint?.isActive = false
                ratioConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: CGFloat(size.width) / CGFloat(size.height))
                ratioConstraint.isActive = true
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
        
//        doubleTap.publisher()
//            .sink { [weak self] gestureRecognizer in
//                guard let self = self else { return }
//                let tappedView = gestureRecognizer.view!
//                let pointInView = gestureRecognizer.location(in: tappedView)
//                var newZoomScale = scrollView.minimumZoomScale + (scrollView.maximumZoomScale - scrollView.minimumZoomScale) / 2
//
//                if scrollView.zoomScale >= newZoomScale || abs(scrollView.zoomScale - newZoomScale) <= 0.01 {
//                    newZoomScale = scrollView.minimumZoomScale
//                }
//
//                let width = scrollView.bounds.width / newZoomScale
//                let height = scrollView.bounds.height / newZoomScale
//                let originX = pointInView.x - (width / 2.0)
//                let originY = pointInView.y - (height / 2.0)
//
//                let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)
//                scrollView.zoom(to: rectToZoomTo, animated: true)
//            }.store(in: &subscriptions)
    }
}


extension PhotoDetailCell: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
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
