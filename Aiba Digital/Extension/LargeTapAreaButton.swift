//
//  LargeTapAreaButton.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/20.
//

import UIKit

class LargeTapAreaButton: UIButton {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let biggerFrame = bounds.insetBy(dx: 0, dy: -15)

        return biggerFrame.contains(point)
    }

}


