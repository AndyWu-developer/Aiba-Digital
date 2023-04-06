//
//  AnimatedButton.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/11.
//

import UIKit

class AnimatedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTargets()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTargets()
    }
    
    private func addTargets() {
        self.addTarget(self, action: #selector(scaleDownAnimated), for: .touchDown)
        self.addTarget(self, action: #selector(scaleBackToNormalAnimated), for: [.touchUpOutside, .touchCancel, .touchUpInside])
    }
    
    @objc func scaleDownAnimated() {
        let shrink = CABasicAnimation(keyPath: "transform")
        shrink.valueFunction = CAValueFunction(name: .scale)
        shrink.fromValue = [1, 1, 0]
        shrink.toValue = [0.92, 0.92, 0]
        
        let dim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        dim.fromValue = 1
        dim.toValue = 0.8
        
        let group = CAAnimationGroup()
        group.animations = [shrink,dim]
        group.duration = 0.1
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        layer.add(group,forKey: nil)
    }
    
    @objc func scaleBackToNormalAnimated() {
        let expand = CABasicAnimation(keyPath: "transform")
        expand.valueFunction = CAValueFunction(name: .scale)
        expand.fromValue = [0.92, 0.92, 0]
        expand.toValue = [1, 1, 0]
        
        let light = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        light.fromValue = 0.8
        light.toValue = 1
        
        let group = CAAnimationGroup()
        group.animations = [expand,light]
        group.duration = 0.1
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        layer.add(group,forKey: nil)
    }
}


class AnimationButton: UIButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            UIView.animate(withDuration: 0.3) {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.titleLabel?.alpha = 0.7
            }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)
            UIView.animate(withDuration: 0.3) {
                self.transform = .identity
                self.titleLabel?.alpha = 1
            }
        }
}


enum Animation {
    typealias Element = (
      duration: TimeInterval,
      delay: TimeInterval,
      options: UIView.AnimationOptions,
      scale: CGAffineTransform,
      alpha: CGFloat
    )
    
    case touchDown
    case touchUp
    
    var element: Element {
      switch self {
      case .touchDown:
        return Element(
            duration: 0,
          delay: 0,
          options: .curveEaseOut,
          scale: .init(scaleX: 0.95, y: 0.95),
          alpha: 0.85
        )
      case .touchUp:
        return Element(
            duration: 0.2,
          delay: 0,
          options: .curveEaseOut,
          scale: .identity,
          alpha: 1
        )
      }
    }
  }
