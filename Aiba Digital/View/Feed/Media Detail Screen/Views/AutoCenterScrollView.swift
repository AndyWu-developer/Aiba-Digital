//
//  AutoCenterScrollView.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/21.
//

import UIKit

class AutoCenterScrollView: UIScrollView {

    override func layoutSubviews() {
        super.layoutSubviews()
        // or the contentView, if zoom not enabled?
        guard let zoomedView = delegate?.viewForZooming?(in: self) else { return }
        let xOffset = max(0, (bounds.width - zoomedView.frame.width) / 2)
        let yOffset = max(0, (bounds.height - zoomedView.frame.height) / 2)
       // zoomedView.frame.origin = CGPoint(x: xOffset, y: yOffset)
        contentInset = .init(top: yOffset, left: xOffset, bottom: yOffset, right: xOffset)
        //when using autolayout & bounce on zoom enabled, the frame method will cause the release bounce animation start at the top left, while contentInset wont
    }

}
