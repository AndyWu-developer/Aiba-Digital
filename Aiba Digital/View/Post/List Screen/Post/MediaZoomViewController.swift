//
//  MediaZoomViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/6.
//

import UIKit
import Combine

protocol MediaZoomViewControllerDelegate: AnyObject{
    func zoomViewTapped(_ vc: MediaZoomViewController)
    func zoomViewZoomed(_ vc: MediaZoomViewController)
}

class MediaZoomViewController: UIViewController {
    //The zoomView is the scrollView's contentView, it is pinned to the fourEdges of the contentLayoutGuide, and it should have some internal constraints or intrinsic size so that it can be centered in scroll view
    
    //https://stackoverflow.com/a/31620601
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var zoomView: UIImageView!
    @IBOutlet var singleTap: UITapGestureRecognizer!
    @IBOutlet var doubleTap: UITapGestureRecognizer!
    @IBOutlet var pinch: UIPinchGestureRecognizer!
    
    var pageIndex: Int = 0
    private var subscriptions = Set<AnyCancellable>()
    private var inFullScreen = false
    weak var delegate: MediaZoomViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.decelerationRate = .fast
        configureGestures()
        zoomView.sizeToFit()
        //let ratio = zoomView.image!.size.width / zoomView.image!.size.height
        // we dont have to add this internal constraint to keep the aspect ratio since UIImageView has its intrinsic Size, this is for views that dont have intrinsic size
        //zoomView.widthAnchor.constraint(equalTo: zoomView.heightAnchor, multiplier: ratio).isActive = true
    }
    
    var zoomScaleBeforeRotate: CGFloat?
    var centerBeforeRotate: CGPoint? // scrollview's center in the zoomed view's coordinate space
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = zoomView.bounds.size
        configureZoomScale(for: scrollView) //setting zoomScale will invoke scrollViewDidZoom
    }
    
    override func viewWillTransition(to size: CGSize,with coordinator:UIViewControllerTransitionCoordinator){
        super.viewWillTransition(to:size, with: coordinator)
        if size != view.bounds.size {
            centerBeforeRotate = zoomView.convert(scrollView.center, from: scrollView.superview)
            if scrollView.zoomScale <= scrollView.minimumZoomScale + CGFloat.ulpOfOne {
                zoomScaleBeforeRotate = 0
            }else{
                zoomScaleBeforeRotate = scrollView.zoomScale
            }
        }
    }

    private func configureGestures(){
        //the scrollview's pinchGesture is added only if its maximumZoomScale or min is set to values other than 1
        scrollView.maximumZoomScale = 2
        singleTap.require(toFail: doubleTap)
        scrollView.pinchGestureRecognizer!.require(toFail: pinch)
        
        singleTap.publisher().sink{ [unowned self] _ in
            self.delegate?.zoomViewTapped(self)
        }.store(in: &subscriptions)
        
        doubleTap.publisher().sink { [unowned self] gestureRecognizer in
            let pointInView = gestureRecognizer.location(in: zoomView)
            var newZoomScale = scrollView.maximumZoomScale
            
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
        
        pinch.publisher().sink { [unowned self] _ in
            print("can pich")
        }.store(in: &subscriptions)
    }
    
    //Key Function1 :)
    private func configureZoomScale(for scrollView: UIScrollView){
        let zoomedView = scrollView.delegate!.viewForZooming!(in: scrollView)!
        let widthScale = scrollView.bounds.width / zoomedView.bounds.width
        let heightScale = scrollView.bounds.height / zoomedView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = minScale * 4
        
        if let oldScale = zoomScaleBeforeRotate {
            scrollView.zoomScale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, oldScale))
            zoomScaleBeforeRotate = nil
        }else{
            scrollView.zoomScale = minScale
        }
    }
    
    //Key Function2 :)
    private func centerZoomedView(in scrollView: UIScrollView){
        let zoomedView = scrollView.delegate!.viewForZooming!(in: scrollView)!
        let xOffset = max(0, (scrollView.bounds.width - zoomedView.frame.width) / 2)
        let yOffset = max(0, (scrollView.bounds.height - zoomedView.frame.height) / 2)
        zoomedView.frame.origin = CGPoint(x: xOffset, y: yOffset)
        // scrollView.contentInset = UIEdgeInsets(top: yOffset, left: xOffset, bottom: yOffset, right: xOffset)
        
        if let oldCenter = centerBeforeRotate{
            centerBeforeRotate = nil
            // Step 2: restore center point, first making sure it is within the allowable range.
            // 2a: convert our desired center point back to our own coordinate space
            let boundsCenter = scrollView.convert(oldCenter, from: zoomView)
    //        // 2b: calculate the content offset that would yield that center point
            var xOffset = boundsCenter.x - scrollView.bounds.width / 2
            var yOffset = boundsCenter.y - scrollView.bounds.height / 2
    //        // 2c: restore offset, adjusted to be within the allowable range
            let maxOffset = maximumContentOffset()
            let minOffset: CGPoint = .zero
            xOffset = max(minOffset.x, min(maxOffset.x, xOffset))
            yOffset = max(minOffset.y, min(maxOffset.y, yOffset))
            scrollView.contentOffset = CGPoint(x: xOffset , y: yOffset)
           
        }
    }
    
    //MARK: - Methods called during rotation to preserve the zoomScale and the visible portion of the image
    
    func maximumContentOffset() -> CGPoint {
        let contentSize = scrollView.contentSize
        let boundSize = scrollView.bounds.size
        return CGPoint(x: contentSize.width - boundSize.width, y: contentSize.height - boundSize.height)
    }
    
}

extension MediaZoomViewController: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerZoomedView(in: scrollView)
        scrollView.isScrollEnabled = scrollView.zoomScale > scrollView.minimumZoomScale
        delegate?.zoomViewZoomed(self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.zoomScale > scrollView.minimumZoomScale, !inFullScreen {
            inFullScreen = true
            UIView.animate(withDuration: 0.2) {
                self.tabBarController?.tabBar.alpha = 0
            }
         
        }else if scrollView.zoomScale <= scrollView.minimumZoomScale, inFullScreen {
            inFullScreen = false
            UIView.animate(withDuration: 0.2) {
                self.tabBarController?.tabBar.alpha = 1
            }
        }
    }
    
}

extension MediaZoomViewController: UIGestureRecognizerDelegate{
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == pinch {
            if pinch.scale < 1, scrollView.zoomScale == scrollView.minimumZoomScale {
                return true
            }
            return false
        }
        fatalError("Code should not go here")
    }
  
}
