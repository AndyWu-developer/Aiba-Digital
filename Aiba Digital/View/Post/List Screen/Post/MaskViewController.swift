//
//  MaskViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/24.
//

import UIKit

class MaskViewController: UIViewController {
    let v = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()

        v.backgroundColor = .darkGreen
        view.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            v.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            v.widthAnchor.constraint(equalToConstant: 300),
            v.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = v.layer.bounds
        //maskLayer.backgroundColor = UIColor.black.cgColor
        // Create the frame for the circle.
        let radius: CGFloat = 10.0
        // Rectangle in which circle will be drawn
        let rect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 2 * radius, height: 2 * radius)
        let circlePath = UIBezierPath(rect: view.bounds)
        // Create a path
        let path = UIBezierPath(rect: view.bounds)
        // Append additional path which will create a circle
        path.append(circlePath)
        // Setup the fill rule to EvenOdd to properly mask the specified area and make a crater
        //maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        print(maskLayer.frame.width)
        // Append the circle to the path so that it is subtracted.
      //  maskLayer.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        maskLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: maskLayer.frame.width, height:  maskLayer.frame.height)).cgPath
        maskLayer.fillColor = UIColor.orange.cgColor
        //maskLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        //v.layer.addSublayer(maskLayer)
        // Mask our view with Blue background so that portion of red background is visible
        //v.layer.mask = maskLayer
        
        
        let mask = CALayer()
        mask.backgroundColor = UIColor.red.cgColor
        mask.frame = v.layer.bounds.insetBy(dx: 30, dy: 30)
        v.layer.mask = mask
        let transformAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        transformAnimation.fromValue = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 0.5, y: 0.5))
      //  transformAnimation.toValue = CGAffineTransform.identity
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        transformAnimation.duration = 2
        maskLayer.add(transformAnimation, forKey: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
