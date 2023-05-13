//
//  TestScrollView.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/13.
//

import UIKit

class TestScrollView: UIScrollView{
    
    override func layoutSubviews() {
        super.layoutSubviews()
       // configureZoomScale(for: self)
        guard let zoomedView = delegate?.viewForZooming?(in: self) else { return }
        let xOffset = max(0, (bounds.width - zoomedView.frame.width) / 2)
        let yOffset = max(0, (bounds.height - zoomedView.frame.height) / 2)
        zoomedView.frame.origin = CGPoint(x: xOffset, y: yOffset)
    }
    
//    func configureZoomScale(for scrollView: UIScrollView){
//        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else { return }
//        let widthScale = scrollView.bounds.width / zoomedView.bounds.width
//        let heightScale = scrollView.bounds.height / zoomedView.bounds.height
//        
//        let minScale = min(widthScale, heightScale)
//        print(minScale)
//        scrollView.minimumZoomScale = minScale
//        scrollView.maximumZoomScale = minScale * 4
//        scrollView.zoomScale = minScale
//        layoutIfNeeded()
//    }
}
