//
//  CheckmarkLayer.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/13.
//

import UIKit

class CheckmarkLayer: CAShapeLayer{
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(){
        super.init()
        fillColor = nil
        lineWidth = 3
        lineCap = .round
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
    
        let size = min(bounds.width, bounds.height)
        let cgPath = CGMutablePath()
        cgPath.move(to: CGPoint(x: size*0.2, y: size * 4/7))
        cgPath.addLine(to: CGPoint(x: size*0.4, y: size*3/4))
        cgPath.addLine(to: CGPoint(x: size*3/4, y: size*0.3))
        path = cgPath
    }
}
