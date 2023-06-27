////
////  TTViewController.swift
////  Aiba Digital
////
////  Created by Andy Wu on 2023/4/22.
////
//
//import UIKit
//
//
//protocol ImageViewerTransitionViewControllerConvertible {
//    // The source view
//    var sourceView: UIView? { get }
//    // The final view
//    var targetView: UIView? { get }
//}
//
//
//
//class TTViewController: UIViewController{
//    
//    var mediaView: MediaView!
//    let imageView = UIImageView()
//    
//   
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let url = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fbike%20(1).png?alt=media&token=743bbd8e-8fe9-4a1f-82ee-e351d580334a"
//        let ext = ".jpg"
//        let viewModel = MediaViewModel(url: url, fileExtension: ext)
//        mediaView = MediaView(viewModel: viewModel)
//        mediaView.translatesAutoresizingMaskIntoConstraints = false
//    
//        mediaView.playButton.isHidden = true
//        view.addSubview(mediaView)
//        let button = UIButton()
//        button.tintColor = .white
//        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        mediaView.addSubview(button)
//        
//        NSLayoutConstraint.activate([
//            mediaView.widthAnchor.constraint(equalToConstant: 150),
//            mediaView.heightAnchor.constraint(equalToConstant: 150),
//            mediaView.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: -100),
//            mediaView.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -200),
//            button.topAnchor.constraint(equalTo: mediaView.topAnchor),
//            button.rightAnchor.constraint(equalTo: mediaView.rightAnchor),
//            button.widthAnchor.constraint(equalToConstant: 30),
//            button.heightAnchor.constraint(equalToConstant: 30),
//        ])
//        
//        
//        
//        
//        
//        
//
//        view.backgroundColor = .darkGray
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showDetail))
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        mediaView.addGestureRecognizer(tapGestureRecognizer)
//   
//        //mediaView.layer.masksToBounds = false
//        
//    }
//    
//
//    @objc func showDetail(){
//    
//        let url = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2Fbike%20(1).png?alt=media&token=743bbd8e-8fe9-4a1f-82ee-e351d580334a"
//        let ext = ".jpg"
//        let viewModel = MediaViewModel(url: url, fileExtension: ext)
//        
//
//        let vc = UIViewController()
//        vc.transitioningDelegate = self
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
//    }
//}
//
//
//extension TTViewController: UIViewControllerTransitioningDelegate{
//    
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return self
//    }
//}
//
//extension TTViewController: UIViewControllerAnimatedTransitioning{
//    
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 10
//    }
//    
//  
//    
//    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
//
//        let containerView = ctx.containerView
//        let toVC = ctx.viewController(forKey:.to)!
//        let r2end = ctx.finalFrame(for:toVC)
//        let v2 = ctx.view(forKey:.to)!
//        let duration = transitionDuration(using: ctx)
//
//        containerView.addSubview(v2)
//
//        let sourceView = mediaView!
//        let targetView = UIView(frame: CGRect(x: 0, y: 374/3, width: 375, height: 1688/3))
//        containerView.addSubview(targetView)
//
//        let sourceViewSize = sourceView.bounds
//        let targetViewSize = targetView.bounds
//
//        let maskLayer = CALayer()
//        maskLayer.frame = r2end
//        maskLayer.backgroundColor = UIColor.black.cgColor
//        v2.layer.mask = maskLayer
//
//       // sourceView.alpha = 0
//
//        
//        CATransaction.setCompletionBlock {
//            targetView.removeFromSuperview()
//            v2.layer.mask = nil
//            ctx.completeTransition(true)
//        }
//
//        // calculate the unclipped bounds of the source view according to the target view and the imageView's contentMode (.aspectFill)
//        let unclippedBounds = {
//            let unclippedRatio = targetViewSize.width / targetViewSize.height
//            var unclippedWidth: CGFloat
//            var unclippedHeight: CGFloat
//
//            if unclippedRatio > 1 { //width > height
//                unclippedHeight = sourceViewSize.height
//                unclippedWidth = unclippedHeight * unclippedRatio
//            }else{
//                unclippedWidth = sourceViewSize.width
//                unclippedHeight = unclippedWidth / unclippedRatio
//            }
//
//            let dx = (unclippedWidth - sourceViewSize.width) / 2
//            let dy = (unclippedHeight - sourceViewSize.height) / 2
//            return sourceView.bounds.insetBy(dx: -dx, dy: -dy)
//        }()
//
//
//        let animation1 = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
//        animation1.toValue = unclippedBounds
//        animation1.duration = duration
//        sourceView.layer.add(animation1, forKey: nil)
//
//
//        // or targetViewSize.height / unclippedBounds.height, should be the same
//        let newScale = targetViewSize.width / unclippedBounds.width
//        let sourceViewScale = CATransform3DMakeScale(newScale, newScale, 1.0)
//
//        let sourceViewCenter = containerView.convert(sourceView.center, from: sourceView.superview)
//        let targetViewCenter = containerView.convert(targetView.center, from: targetView.superview)
//        let dx = targetViewCenter.x - sourceViewCenter.x
//        let dy = targetViewCenter.y - sourceViewCenter.y
//        let sourceViewTranslation = CATransform3DMakeTranslation(dx, dy, 0)
//
//        let sourceViewTransform = CATransform3DConcat(sourceViewScale, sourceViewTranslation)
//
//        let animation2 = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
//        animation2.toValue = sourceViewTransform
//        animation2.duration = duration
//        sourceView.layer.add(animation2, forKey: nil)
//
//        let animation3 = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
//        animation3.fromValue = 0
//        animation3.duration = duration
//        v2.layer.add(animation3, forKey: nil)
//
//        var adjustScale: CGFloat
//        if targetViewSize.width > targetViewSize.height {
//            adjustScale = sourceViewSize.height / targetViewSize.height
//        }else{
//            adjustScale = sourceViewSize.width / targetViewSize.width
//        }
//
//        let v2Scale = CATransform3DMakeScale(adjustScale, adjustScale, 1)
//        let v2Translation = CATransform3DMakeTranslation(-dx,-dy, 1)
//        let v2Transform = CATransform3DConcat(v2Scale,v2Translation)
//        let animation4 = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
//        animation4.fromValue = v2Transform
//        animation4.duration = duration
//        v2.layer.add(animation4, forKey: nil)
//        
//    
//
////        let maskScaleX = (sourceView.bounds.width / r2end.width) / adjustScale
////        let maskScaleY = (sourceView.bounds.height / r2end.height) / adjustScale
////        let animation5 = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
////        animation5.fromValue = CATransform3DMakeScale(maskScaleX, maskScaleY , 1)
////        animation5.duration = duration
////        maskLayer.add(animation5, forKey: nil)
//        
//       
//        let animation5 = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
//        var b = targetView.layer.frame
//        b.size.height = b.size.width
//        animation5.fromValue = b
//        animation5.toValue = r2end
//        animation5.duration = duration
//        maskLayer.add(animation5, forKey: nil)
//    }
//
////    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
////
////        let containerView = ctx.containerView
////        let toVC = ctx.viewController(forKey:.to)!
////        let r2end = ctx.finalFrame(for:toVC)
////        let v2 = ctx.view(forKey:.to)!
////        let duration = transitionDuration(using: ctx)
////
////        containerView.addSubview(v2)
////
////        guard let vc = toVC as? ImageViewerTransitionViewControllerConvertible else {
////            print("wrong type")
////            return
////        }
////
////        let sourceView = mediaView!
////        let targetView = UIView(frame: CGRect(x: 0, y: 124.66666666666667, width: 375, height: 562.6666666666666))
////        containerView.addSubview(targetView)
////
////        let sourceViewSize = sourceView.bounds
////        let targetViewSize = targetView.bounds
////
////        let maskLayer = CALayer()
////        maskLayer.frame = r2end
////        maskLayer.backgroundColor = UIColor.black.cgColor
////        v2.layer.mask = maskLayer
////
////
//////        let sourceMaskLayer = CALayer()
//////        sourceMaskLayer.backgroundColor = UIColor.black.cgColor
//////
//////        let frame = v2.convert(r2end, to: sourceView)
//////        var ob = sourceView.layer.bounds
//////        ob.size.width = frame.width
//////        ob.size.height = frame.height
//////        sourceMaskLayer.frame = sourceView.layer.bounds.insetBy(dx: -100, dy: -100)
//////        sourceView.layer.mask = sourceMaskLayer
//////        sourceView.layer.masksToBounds = false
////
////
////        CATransaction.setCompletionBlock {
////            targetView.removeFromSuperview()
////            v2.layer.mask = nil
////            ctx.completeTransition(true)
////        }
////
////        // calculate the unclipped bounds of the source view according to the target view and the imageView's contentMode (.aspectFill)
////        let unclippedBounds = {
////            let unclippedRatio = targetViewSize.width / targetViewSize.height
////            var unclippedWidth: CGFloat
////            var unclippedHeight: CGFloat
////
////            if unclippedRatio > 1 { //width > height
////                unclippedHeight = sourceViewSize.height
////                unclippedWidth = unclippedHeight * unclippedRatio
////            }else{
////                unclippedWidth = sourceViewSize.width
////                unclippedHeight = unclippedWidth / unclippedRatio
////            }
////
////            let xOffset = (unclippedWidth - sourceViewSize.width) / 2
////            let yOffset = (unclippedHeight - sourceViewSize.height) / 2
////
////            return CGRect(x: -xOffset, y: -yOffset, width: unclippedWidth, height: unclippedHeight)
////        }()
////
////
////
////        let animation1 = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
////        animation1.toValue = unclippedBounds
////        animation1.duration = 3
////        animation1.isRemovedOnCompletion = false
////        animation1.fillMode = .both
////        sourceView.layer.add(animation1, forKey: nil)
////
////
////
////        let animation7 = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
////        animation7.fromValue = sourceView.layer.bounds
////        animation7.duration = duration
////        //sourceMaskLayer.add(animation7, forKey: nil)
////
////
////        // or targetViewSize.height / unclippedBounds.height, should be the same
////        let newScale = targetViewSize.width / unclippedBounds.width
////        let sourceViewScale = CATransform3DMakeScale(newScale, newScale, 1.0)
////
////        let sourceViewCenter = containerView.convert(sourceView.center, from: sourceView.superview)
////        let targetViewCenter = containerView.convert(targetView.center, from: targetView.superview)
////        let dx = targetViewCenter.x - sourceViewCenter.x
////        let dy = targetViewCenter.y - sourceViewCenter.y
////        let sourceViewTranslation = CATransform3DMakeTranslation(dx, dy, 0)
////
////        let sourceViewTransform = CATransform3DConcat(sourceViewScale, sourceViewTranslation)
////
////        let animation2 = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
////        animation2.toValue = sourceViewTransform
////        animation2.duration = duration
////        sourceView.layer.add(animation2, forKey: nil)
////
////        let animation3 = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
////        animation3.fromValue = 0
////        animation3.duration = duration
////        v2.layer.add(animation3, forKey: nil)
////
////        var adjustScale: CGFloat
////        if targetViewSize.width > targetViewSize.height {
////            adjustScale = sourceViewSize.height / targetViewSize.height
////        }else{
////            adjustScale = sourceViewSize.width / targetViewSize.width
////        }
////
////        let v2Scale = CATransform3DMakeScale(adjustScale, adjustScale, 1)
////        let v2Translation = CATransform3DMakeTranslation(-dx,-dy, 1)
////        let v2Transform = CATransform3DConcat(v2Scale,v2Translation)
////        let animation4 = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
////        animation4.fromValue = v2Transform
////        animation4.duration = duration
////        v2.layer.add(animation4, forKey: nil)
////
////        let maskScaleX = (sourceView.bounds.width / r2end.width) / adjustScale
////        let maskScaleY = (sourceView.bounds.height / r2end.height) / adjustScale
////        let animation5 = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
////        animation5.fromValue = CATransform3DMakeScale(maskScaleX, maskScaleY , 1)
////        animation5.duration = duration
////        maskLayer.add(animation5, forKey: nil)
////    }
//
//    
//   
//        
//    
////    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
////
////        let containerView = ctx.containerView
////        let toVC = ctx.viewController(forKey:.to)!
////        let r2end = ctx.finalFrame(for:toVC)
////        let v2 = ctx.view(forKey:.to)!
////        let duration = transitionDuration(using: ctx)
////
////        containerView.addSubview(v2)
////
////        guard let vc = toVC as? ImageViewerTransitionViewControllerConvertible else {
////            print("wrong type")
////            return
////        }
////
////        let image = mediaView.imageView.image!
////        let imageRatio = image.size.width / image.size.height
////
////
////        let sourceView = mediaView!
////       // let targetView = UIView(frame: CGRect(x: 100, y: 200, width: <#T##Int#>, height: <#T##Int#>))
////
////
////        let beginFrame = mediaView.convert(mediaView.bounds, to: nil)
////        let adjustSnapFrame = containerView.convert(beginFrame, from: nil)
////
////
////
////        let width = sourceView.bounds.height * imageRatio
////        let height = sourceView.bounds.width / imageRatio
////        var adjustScale: CGFloat
////        if imageRatio >= 1{
////
////            adjustScale = width / r2end.width
////        }else{
////            adjustScale = height / r2end.height
////        }
////
////
////        let maskLayer = CALayer()
////        maskLayer.frame = r2end
////        maskLayer.backgroundColor = UIColor.black.cgColor
////        v2.layer.mask = maskLayer
////
////
////        let Width = mediaView.imageView.bounds.height * imageRatio
////        let Height = mediaView.imageView.bounds.width / imageRatio
////        let xOffset = mediaView.bounds.width - width / 2
////        let yOffset = mediaView.bounds.height - height / 2
////        let newBounds = CGRect(x: -xOffset, y: -yOffset, width: Height * imageRatio, height: Height)
////        let newWidthScale = view.layer.bounds.width / newBounds.width
////        let newHeightScale = view.layer.bounds.height / newBounds.height
////
////        CATransaction.setCompletionBlock {
////            v2.layer.mask = nil
////            ctx.completeTransition(true)
////        }
////
////        let animation1 = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
////        animation1.toValue = newBounds
////        animation1.duration = duration
////        mediaView.layer.add(animation1, forKey: nil)
////
////
////
////        let tscale = CATransform3DMakeScale(newWidthScale, newWidthScale, 1.0)
////        let frame = mediaView.superview!.convert(mediaView.center, to: containerView)
////        let ddeltaX = containerView.bounds.midX - frame.x
////        let ddeltaY = containerView.bounds.midY - frame.y
////        let Trans = CATransform3DMakeTranslation(ddeltaX , ddeltaY, 0)
////        let t = CATransform3DConcat(tscale,Trans)
////
////        let animation2 = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
////        animation2.toValue = t
////        animation2.duration = duration
////        mediaView.layer.add(animation2, forKey: nil)
////
////        let animation3 = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
////        animation3.fromValue = 0
////        animation3.duration = duration
////        v2.layer.add(animation3, forKey: nil)
////
////
////        let sourceViewCenter = containerView.convert(mediaView.center, from: mediaView.superview)
////        let deltaX = sourceViewCenter.x - containerView.bounds.midX
////        let deltaY = sourceViewCenter.y - containerView.bounds.midY
////        let v2Scale = CATransform3DMakeScale(adjustScale, adjustScale, 1)
////        let v2Translation = CATransform3DMakeTranslation(deltaX, deltaY, 1)
////        let animation4 = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
////        animation4.fromValue = CATransform3DConcat(v2Scale,v2Translation)
////        animation4.duration = duration
////        v2.layer.add(animation4, forKey: nil)
////
////        let maskScaleX = (sourceView.bounds.width / r2end.width) / adjustScale
////        let maskScaleY = (sourceView.bounds.height / r2end.height) / adjustScale
////        let animation5 = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
////        animation5.fromValue = CATransform3DMakeScale(maskScaleX, maskScaleY , 1)
////        animation5.duration = duration
////        maskLayer.add(animation5, forKey: nil)
////    }
//
//
//
//    
////    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
////
////        let con = ctx.containerView
////        let toVC = ctx.viewController(forKey:.to)!
////        let r2end = ctx.finalFrame(for:toVC)
////        let v2 = ctx.view(forKey:.to)!
////        let duration = transitionDuration(using: ctx)
////
////        guard let vc = toVC as? ImageViewerTransitionViewControllerConvertible else {
////            print("wrong type")
////            return
////        }
////
////        let sourceView = vc.sourceView!
////        let beginFrame = sourceView.convert(sourceView.bounds, to: nil)
////        let adjustSnapFrame = con.convert(beginFrame, from: nil)
////
////
////
//////        let coverImageView = UIImageView(frame: adjustSnapFrame)
//////        coverImageView.contentMode = .scaleAspectFill
//////        coverImageView.clipsToBounds = true
//////        coverImageView.image = mediaView.imageView.image
//////        let ratio = sourceView.image!.size.height / sourceView.image!.size.width
//////
////
////        let helperView = UIView(frame: r2end)
//////
//////        coverImageView.bounds = CGRect(x: 0, y: 0, width: helperView.bounds.width, height: helperView.bounds.width * ratio)
//////        coverImageView.center = CGPoint(x: helperView.bounds.midX,y: helperView.bounds.midY)
////
////
////
////
////        let imageRatio = sourceView.image!.size.width / sourceView.image!.size.height
////
////
////    //    helperView.addSubview(coverImageView)
////
////        helperView.addSubview(v2)
////
////        let maskView = UIView(frame: helperView.bounds)
////        maskView.backgroundColor = .black
////        helperView.mask = maskView
////
////        con.addSubview(helperView)
////
////
////
////        let deltaX = adjustSnapFrame.midX - con.bounds.midX
////        let deltaY = adjustSnapFrame.midY - con.bounds.midY
////        let translation = CGAffineTransform(translationX: deltaX, y: deltaY)
////
////
////        let width = adjustSnapFrame.height * imageRatio
////
////        let adjustScale = width / r2end.width
////        let scale = CGAffineTransform(scaleX: adjustScale, y: adjustScale)
////        helperView.transform = scale.concatenating(translation)
////        maskView.transform = CGAffineTransform(scaleX: adjustSnapFrame.width / helperView.frame.width ,y: adjustSnapFrame.height / helperView.frame.height)
////
////        sourceView.alpha = 0
////        v2.alpha = 0
////
////
////        UIView.animate(withDuration: duration, animations: {
////            v2.alpha = 1
////            maskView.layer.cornerRadius = 20
////            maskView.transform = .identity
////            helperView.transform = .identity
////        }) { _ in
////            sourceView.alpha = 1
////            con.addSubview(v2)
////            helperView.removeFromSuperview()
////            ctx.completeTransition(true)
////        }
////    }
//    
//    
//    
//    
//    
//}
//
//
