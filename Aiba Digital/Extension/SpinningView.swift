//
//  SpinningView.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/23.
//

import UIKit

class SpinningView: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
        isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isOpaque = false
    }
    
    
    override func draw(_ rect: CGRect) {
       
        let (width, height) = (bounds.width, bounds.height)
        let lineWidth: CGFloat = 3
        let radius = (min(width, height) - lineWidth) / 2
    
        var currentPoint = CGPoint(x: width / 2 + radius, y: height / 2)
        var priorAngle = CGFloat(360)
        
        for angle in stride(from: CGFloat(360), through: 0, by: -2) {
            let path = UIBezierPath()
            path.lineWidth = lineWidth

            path.move(to: currentPoint)
            currentPoint = CGPoint(x: width / 2 + radius * cos(angle * .pi / 180),
                                   y: height / 2 + radius * sin(angle * .pi / 180))
            path.addArc(withCenter: CGPoint(x: width  / 2, y: height / 2),
                        radius: radius,
                        startAngle: priorAngle * .pi / 180,
                        endAngle: angle * .pi / 180,
                        clockwise: false)
            priorAngle = angle
            UIColor.white.withAlphaComponent(angle/720).setStroke() //320
            path.lineCapStyle = .round
            path.stroke()
        }
    }
    
    func startSpinning(){
        let rotate = CABasicAnimation(keyPath: "transform")
        rotate.valueFunction = CAValueFunction(name: .rotateZ)
        rotate.fromValue = 0
        rotate.toValue = 2 * Double.pi
        rotate.duration = 0.6
        rotate.repeatCount = .greatestFiniteMagnitude
        rotate.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(rotate, forKey: nil)
    }
    
    func stopSpinning(){
        layer.removeAllAnimations()
    }
    
    
    

}
