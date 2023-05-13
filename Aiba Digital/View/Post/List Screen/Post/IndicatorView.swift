//
//  IndicatorView.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/10.
//

import UIKit

class IndicatorBarView: UIView {
    
    open lazy var selectedBar: UIView = { [unowned self] in
        let selectedBar = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        return selectedBar
    }()
    
    var optionsCount = 1 {
        willSet(newOptionsCount) {
            if newOptionsCount <= selectedIndex {
                selectedIndex = optionsCount - 1
            }
        }
    }
    var selectedIndex = 0
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        addSubview(selectedBar)
    }
   
    // MARK: - Helpers
    
    private func updateSelectedBarPosition(with animation: Bool) {
        var frame = selectedBar.frame
        frame.size.width = self.bounds.size.width / CGFloat(optionsCount)
        frame.origin.x = frame.size.width * CGFloat(selectedIndex)
        if animation {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.selectedBar.frame = frame
            })
        } else {
            selectedBar.frame = frame
        }
    }
    
    open func moveTo(index: Int, animated: Bool) {
        selectedIndex = index
        updateSelectedBarPosition(with: animated)
    }
    
    open func move(fromIndex: Int, toIndex: Int, progressPercentage: CGFloat) {
        selectedIndex = (progressPercentage > 0.5) ? toIndex : fromIndex
        
        var newFrame = selectedBar.frame
        newFrame.size.width = self.bounds.size.width / CGFloat(optionsCount)
        var fromFrame = newFrame
        fromFrame.origin.x = newFrame.size.width * CGFloat(fromIndex)
        var toFrame = newFrame
        toFrame.origin.x = toFrame.size.width * CGFloat(toIndex)
        var targetFrame = fromFrame
        targetFrame.origin.x += (toFrame.origin.x - targetFrame.origin.x) * CGFloat(progressPercentage)
        selectedBar.frame = targetFrame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSelectedBarPosition(with: false)
    }
}
