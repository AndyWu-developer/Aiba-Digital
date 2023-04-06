//
//  SignInButton.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/11.
//

import UIKit

class SignInButton: AnimatedButton {
    
    private var spinningLayer = SpinningLayer()
    private var checkmarkLayer = CheckmarkLayer()
    private var originalTitle: String?
    private var originalImage: UIImage?
    
    override func willMove(toSuperview newSuperview: UIView?) {
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        spinningLayer.bounds = CGRect(x: 0, y: 0, width: bounds.height * 0.8, height: bounds.height * 0.8)
        spinningLayer.position = CGPoint(x: bounds.height / 2, y: bounds.height / 2)
        checkmarkLayer.bounds = CGRect(x: 0, y: 0, width: bounds.height * 0.75, height: bounds.height * 0.75)
        checkmarkLayer.position = CGPoint(x: bounds.height / 2, y: bounds.height / 2)
    }
    
    private func configure(){
        let normalStateColor = titleColor(for: .normal)!
        setTitleColor(normalStateColor.withAlphaComponent(0.5), for: .disabled)
        
        originalImage = image(for: .normal)
        originalTitle = title(for: .normal)
        
        spinningLayer.name = "spinningLayer"
        spinningLayer.contentsScale = UIScreen.main.scale
        spinningLayer.setNeedsDisplay()
        spinningLayer.opacity = 0
        spinningLayer.color = titleColor(for: .normal)!
       
        checkmarkLayer.name = "checkmarkLayer"
        checkmarkLayer.contentsScale = UIScreen.main.scale
        checkmarkLayer.strokeColor = titleColor(for: .normal)!.cgColor
        checkmarkLayer.strokeEnd = 0
        checkmarkLayer.opacity = 0
        
        layer.addSublayer(spinningLayer)
        layer.addSublayer(checkmarkLayer)
    }
    
    func startLoadingAnimation(completion: (() -> Void)? = nil){
        
        isUserInteractionEnabled = false
        setTitle("", for: .normal)
        setImage(nil, for: .normal)
      
        let rotate = CABasicAnimation(keyPath: "sublayers.spinningLayer.transform")
        rotate.valueFunction = CAValueFunction(name: .rotateZ)
        rotate.fromValue = 0
        rotate.toValue = 2 * Double.pi
        rotate.duration = 0.8
        rotate.repeatCount = .greatestFiniteMagnitude
        rotate.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(rotate, forKey: rotate.keyPath)
    
        CATransaction.setCompletionBlock {
            completion?()
        }
        
        let shrinkAnimation = CABasicAnimation(keyPath: "bounds.size.width")
        shrinkAnimation.toValue = bounds.height
        
        let translation = CABasicAnimation(keyPath: "sublayers.spinningLayer.position.x")
        translation.fromValue = bounds.midX
        
        let fadeInAnimation = CABasicAnimation(keyPath: "sublayers.spinningLayer.opacity")
        fadeInAnimation.toValue = 1
        
        let group = CAAnimationGroup()
        group.animations = [shrinkAnimation,translation,fadeInAnimation]
        group.duration = 0.2
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        layer.add(group, forKey: nil)
    }
    
    func startSuccessAnimation(completion: (() -> Void)? = nil){
        
        CATransaction.setCompletionBlock {
            completion?()
        }
       
        let fadeOutAnimation = CABasicAnimation(keyPath: "sublayers.spinningLayer.opacity")
        fadeOutAnimation.fromValue = 1
        fadeOutAnimation.duration = 0.1
        fadeOutAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        fadeOutAnimation.fillMode = .forwards
        
        let fadeInAnimation = CABasicAnimation(keyPath: "sublayers.checkmarkLayer.opacity")
        fadeInAnimation.fromValue = 0
        fadeInAnimation.toValue = 1
        fadeInAnimation.beginTime = 0.15
        fadeInAnimation.duration = 0.5
        fadeInAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        fadeInAnimation.fillMode = .forwards
        
        let strokeAnimation = CABasicAnimation(keyPath: "sublayers.checkmarkLayer.strokeEnd")
        strokeAnimation.toValue = 1
        strokeAnimation.beginTime = 0.15
        strokeAnimation.duration = 0.5
        strokeAnimation.fillMode = .forwards
        
        let group = CAAnimationGroup()
        group.animations = [fadeOutAnimation,fadeInAnimation,strokeAnimation]
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        group.duration = 1
        layer.add(group, forKey: nil)
    }
    
    func stopAnimating(){
        setTitle(originalTitle, for: .normal)
        setImage(originalImage, for: .normal)
        layer.removeAllAnimations()
        isUserInteractionEnabled = true
    }
}
