//
//  ImageCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/23.
//

import UIKit
import Combine

protocol ZoomDelegate: AnyObject {
    func zooming(started: Bool)
}

class PhotoPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: ZoomDelegate?
   
    let maxOverlayAlpha: CGFloat = 0.8
    let minOverlayAlpha: CGFloat = 0.2
    
    var overlayView: UIView!
    var windowImageView: UIImageView?
    var initialGestureInView: CGPoint!
    
    var viewModel: PhotoViewModel!{
        didSet{
            bindViewModelOutput()
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    private var ratioConstraint: NSLayoutConstraint!
    private let maxContentRatio: CGFloat = 5/4
    private let minContentRatio: CGFloat = 1/3
   
    override func awakeFromNib() {
        super.awakeFromNib()
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch))
        pinch.delegate = self
        imageView.addGestureRecognizer(pinch)
        imageView.isUserInteractionEnabled = true
    }
    
    private func bindViewModelOutput(){
       
        subscriptions.removeAll()
        imageView.image = nil
     
        updateFrameRatio()
        
        // assign to will cause memory leak!!!!
        viewModel.output.imageData
            .receive(on: DispatchQueue.main)
            .map(UIImage.init(data:))
            .sink{ [weak self] image in
                guard let self else { return }
                imageView.image = image
            }
            .store(in: &subscriptions)
    }
    
    
    private func updateFrameRatio(){
        ratioConstraint?.isActive = false
        var ratio = CGFloat(viewModel.contentPixelHeight) / CGFloat(viewModel.contentPixelWidth)
        ratio = max(minContentRatio, min(ratio, maxContentRatio))
        ratioConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio)
        ratioConstraint.priority = .init(999)
        ratioConstraint.isActive = true
        layoutIfNeeded()
    }
    
}


extension PhotoPreviewCell: UIGestureRecognizerDelegate {
    
    @objc private func pinch(sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            let currentScale = imageView.frame.size.width / imageView.bounds.size.width
            let newScale = currentScale * sender.scale
            if newScale > 1 {
                guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
                self.delegate?.zooming(started: true)

                overlayView = UIView(frame: currentWindow.bounds)
                overlayView.backgroundColor = .black
                overlayView.alpha = 0
                currentWindow.addSubview(overlayView)

                windowImageView = UIImageView(image: imageView.image)
                windowImageView?.frame = imageView.convert(imageView.bounds, to: currentWindow)
                windowImageView?.contentMode = .scaleAspectFill
                windowImageView?.clipsToBounds = true
                windowImageView?.accessibilityIgnoresInvertColors = true
                currentWindow.addSubview(windowImageView!)

                imageView.alpha = 0
                initialGestureInView = sender.location(in: sender.view)
            }
          
        } else if sender.state == .changed {

            if sender.numberOfTouches < 2 {
                return
            }

            let shift = CGPoint(x: initialGestureInView.x - imageView!.bounds.midX,
                               y: initialGestureInView.y - imageView!.bounds.midY)

            let delta = CGPoint(x: sender.location(in: sender.view).x - initialGestureInView.x,
                               y: sender.location(in: sender.view).y - initialGestureInView.y)

            let currentScale = windowImageView!.frame.width / windowImageView!.bounds.width

            let senderScale = (currentScale > 4) ? (sender.scale > 1) ? 1 : sender.scale : sender.scale
            let newScale = currentScale * senderScale
            overlayView.alpha = minOverlayAlpha + (newScale - 1) < maxOverlayAlpha ? minOverlayAlpha + (newScale - 1) : maxOverlayAlpha

            let zoomScale = (newScale * windowImageView!.frame.width >= imageView.frame.width) ? newScale : currentScale

            let transform = CGAffineTransform.identity
                .translatedBy(x: delta.x, y: delta.y)
                .translatedBy(x: shift.x , y: shift.y )
                .scaledBy(x: zoomScale, y: zoomScale)
                .translatedBy(x: -shift.x , y: -shift.y)
            //.translatedBy(x: centerXDif / zoomScale, y: centerYDif / zoomScale)
              
            windowImageView?.transform = transform
            
           
            sender.scale = 1

        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
                guard let windowImageView = self.windowImageView else { return }
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: .curveEaseInOut) {
                    windowImageView.transform = CGAffineTransform.identity
                    self.overlayView.alpha = 0
                } completion: { _ in
                    windowImageView.removeFromSuperview()
                    self.overlayView.removeFromSuperview()
                    self.imageView.alpha = 1
                    self.delegate?.zooming(started: false)
                }
            }
        }

}
