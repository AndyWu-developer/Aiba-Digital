//
//  SpinningLayer.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/13.
//

import UIKit

class SpinningLayer: CALayer{
    
    var color: UIColor = .white
    var lineWidth: CGFloat = 2
    
    override func draw(in ctx: CGContext) {
      
        let width = bounds.width
        let height = bounds.height
        let radius = (min(width, height) - lineWidth) / 2
    
        var currentPoint = CGPoint(x: width / 2 + radius, y: height / 2)
        var priorAngle = CGFloat(360)

        UIGraphicsPushContext(ctx)
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
            color.withAlphaComponent(angle/320).setStroke()
            path.lineCapStyle = (angle == 360) ? .round : .square
            path.stroke()
        }
        UIGraphicsPopContext()
    }
}
