//
//  ZoomScrollView.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/8.
//

import UIKit

protocol MediaScrollViewDelegate: AnyObject{
    func zoomIn(_ scrollView: UIScrollView)
    func zoomOut(_ scrollView: UIScrollView)
}

class MediaScrollView: UIScrollView {
    var inFullScreen = false
    private var zoomView: UIView!
    weak var scrollDelegate: MediaScrollViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = .fast
        bouncesZoom = false
        delegate = self
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerZoomedView(in: self)
    }
    
    func display(contentLayer: CALayer){
        layoutIfNeeded()
        zoomView?.removeFromSuperview()
        zoomView = nil
        zoomView = UIView(frame: CGRect(origin: .zero, size: contentLayer.bounds.size))
        zoomView.layer.cornerRadius = 20
        zoomView.layer.masksToBounds = true
        addSubview(zoomView)
        contentLayer.frame = zoomView.layer.bounds
        zoomView.layer.addSublayer(contentLayer)
        contentSize = zoomView.bounds.size
        configureZoomScale(for: self)
    }
    
    //Key Function1
    private func configureZoomScale(for scrollView: UIScrollView){
        let zoomedView = scrollView.delegate!.viewForZooming!(in: scrollView)!
        let widthScale = scrollView.bounds.width / zoomedView.bounds.width
        let heightScale = scrollView.bounds.height / zoomedView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = minScale * 4
        scrollView.zoomScale = minScale
    }
    
    //Key Function2
    private func centerZoomedView(in scrollView: UIScrollView){
        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else {return}
        let xOffset = max(0, (scrollView.bounds.width - zoomedView.frame.width) / 2)
        let yOffset = max(0, (scrollView.bounds.height - zoomedView.frame.height) / 2)
        zoomedView.frame.origin = CGPoint(x: xOffset, y: yOffset)
    }
}

extension MediaScrollView: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
   
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerZoomedView(in: scrollView)
        scrollView.isScrollEnabled = scrollView.zoomScale > scrollView.minimumZoomScale
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.zoomScale > scrollView.minimumZoomScale, !inFullScreen {
            inFullScreen = true
            scrollDelegate?.zoomIn(self)
         
        }else if scrollView.zoomScale <= scrollView.minimumZoomScale, inFullScreen {
            inFullScreen = false
            scrollDelegate?.zoomOut(self)
        }
    }
}
