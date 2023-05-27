//
//  ScrollIndicator.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/16.
//

import UIKit

class ScrollIndicator: UIView {

    private let indicatorBar = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    func updatePosition(for scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let totalPages = Int(max(1, scrollView.contentSize.width / pageWidth))
        let maxContentOffsetX = max(0, scrollView.contentSize.width - pageWidth)

        let percentage = scrollView.contentOffset.x / maxContentOffsetX
        let startPoint = indicatorBar.bounds.minX + (indicatorBar.bounds.width / CGFloat(totalPages)) / 2 - (indicatorBar.bounds.midX)
        let endPoint = indicatorBar.bounds.maxX - (indicatorBar.bounds.width / CGFloat(totalPages)) / 2 - (indicatorBar.bounds.midX)
        let range = endPoint - startPoint
      
        let scale = CGAffineTransform(scaleX: 1 / CGFloat(totalPages), y: 1)
        let translation = CGAffineTransform(translationX: startPoint + (range * percentage), y: 0)
        
        UIView.animate(withDuration: 0.05) {
            self.indicatorBar.transform = scale.concatenating(translation)
        }
        
    }
    
    private func customInit(){
        clipsToBounds = true
        indicatorBar.backgroundColor = .systemYellow//.white.withAlphaComponent(0.8)
        indicatorBar.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(indicatorBar)
        NSLayoutConstraint.activate([
            indicatorBar.topAnchor.constraint(equalTo: topAnchor),
            indicatorBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            indicatorBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            indicatorBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }


//    override func layoutSubviews() {
//        super.layoutSubviews()
//        indicatorBar.frame = self.bounds
//    }

}
