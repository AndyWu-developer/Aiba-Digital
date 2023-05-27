//
//  SendCodeButton.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/14.
//

import UIKit

class SendSMSButton: AnimatedButton{
    
    override func willMove(toSuperview newSuperview: UIView?) {
        configure()
    }
    
    func configure(){
        backgroundColor = .lightOrange
        setTitleColor(.black, for: .normal)
        setTitleColor(.black.withAlphaComponent(0.3), for: .disabled)
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 36).isActive = true
        widthAnchor.constraint(equalToConstant: 105).isActive = true
        layer.cornerRadius = 18
        clipsToBounds = true
        contentHorizontalAlignment = .leading
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    func startAnimating(){
        isEnabled = false
        setTitle("\t• • •", for: .normal)
        return
        let loadingLayer = CAReplicatorLayer()
        loadingLayer.contentsScale = UIScreen.main.scale
        loadingLayer.frame = CGRect(x: 0, y: 0, width: 70, height: 10)
        let circle = CALayer()
        circle.contentsScale = UIScreen.main.scale
        circle.backgroundColor = UIColor.black.cgColor
        circle.frame = CGRect(x: 0, y: 0, width: 6, height: 6)
        circle.cornerRadius = circle.bounds.width / 2
        loadingLayer.addSublayer(circle)
        loadingLayer.instanceCount = 3
        loadingLayer.instanceTransform = CATransform3DMakeTranslation(20, 0, 0)
        
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        animation.valueFunction = CAValueFunction(name: .scale)
        animation.fromValue = [1, 1, 0]
        animation.toValue = [1.2, 1.2, 0]
        animation.duration = 0.8
        animation.repeatCount = .infinity
        circle.add(animation, forKey: nil)
        
        loadingLayer.instanceDelay = animation.duration / Double(loadingLayer.instanceCount)
        layer.addSublayer(loadingLayer)
        loadingLayer.frame = layer.bounds
    }
    
    
    func stopAnimating(completion: (() -> Void)? = nil){
        layer.removeAllAnimations()
        isEnabled = true
    }
}
