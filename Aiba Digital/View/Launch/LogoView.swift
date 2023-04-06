

import UIKit

protocol LogoAnimationDelegate: AnyObject{
    func LogoAnimationDidFinish()
}

class LogoView: UIView{

    override class var layerClass: AnyClass{
        return LogoViewLayer.self
    }

    func startAnimation(){
        (layer as! LogoViewLayer).startAnimation()
    }
    
    weak var delegate: LogoAnimationDelegate?
}

class LogoViewLayer: CALayer {

    private let mainTitleText: NSMutableAttributedString = {
        let text = "艾巴數位"
        let attributedString = NSMutableAttributedString(string: text,attributes: [.font : UIFont(name: "DFPZongYiW5-B5", size: 60)!])
        attributedString.addAttribute(.kern, value: 15, range: NSMakeRange(0, text.count-1))
        return attributedString
    }()

    private let subTitleText: NSMutableAttributedString = {
        let text = "SINCE 2013"
        let attributedString = NSMutableAttributedString(string: text,attributes: [.font :  UIFont(name: "HYwulM", size: 10)!])
        attributedString.addAttribute(.kern, value: 3, range: NSMakeRange(0, text.count-1))
        return attributedString
    }()

    private let mainTitle = CATextLayer()
    private let subTitle = CATextLayer()
    private let bottomLine = CALayer()

    override init(){
        super.init()

        mainTitle.contentsScale = UIScreen.main.scale
        mainTitle.string = mainTitleText
        mainTitle.alignmentMode = .center

        subTitle.contentsScale = UIScreen.main.scale
        subTitle.name = "subTitle"
        subTitle.string = subTitleText
        subTitle.alignmentMode = .center

        bottomLine.contentsScale = UIScreen.main.scale
        bottomLine.name = "bottomLine"
        bottomLine.contents = createLine()
        bottomLine.anchorPoint = CGPoint(x: 0, y: 0.5)

        addSublayer(mainTitle)
        addSublayer(subTitle)
        addSublayer(bottomLine)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any){
        super.init(layer: layer)
    }
    
    private func createLine() -> CGImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 204, height: 30))
        let line = renderer.image { _ in
            let context = UIGraphicsGetCurrentContext()!
            context.setLineWidth(15)

            context.move(to: CGPoint(x: 0,y: 0))
            context.addLine(to: CGPoint(x: 40, y: 0))
            context.setStrokeColor(UIColor.lightGreen.cgColor)
            context.strokePath()

            context.move(to: CGPoint(x: 40,y: 0))
            context.addLine(to: CGPoint(x: 104, y: 0))
            context.setStrokeColor(UIColor.darkGreen.cgColor)
            context.strokePath()

            context.move(to: CGPoint(x: 104,y: 0))
            context.addLine(to: CGPoint(x: 156, y: 0))
            context.setStrokeColor(UIColor.lightBlue.cgColor)
            context.strokePath()

            context.move(to: CGPoint(x: 156,y: 0))
            context.addLine(to: CGPoint(x: 204, y: 0))
            context.setStrokeColor(UIColor.lightGray.cgColor)
            context.strokePath()
        }
        return line.cgImage!
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        
        mainTitle.position = CGPoint(x: bounds.midX, y: 35)
        mainTitle.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: 70)

        subTitle.position = CGPoint(x: bounds.midX, y: 75)
        subTitle.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: 12)

        bottomLine.position = CGPoint(x: bounds.midX - (bounds.width*0.47/2), y: 92)
        bottomLine.bounds = CGRect(x: 0, y: 0, width: bounds.width*0.47, height: 20)
    }

    func startAnimation(){

        CATransaction.setDisableActions(true)
        subTitle.opacity = 1
        subTitle.transform =  CATransform3DMakeAffineTransform(CGAffineTransform.identity)
        bottomLine.transform = CATransform3DMakeAffineTransform(CGAffineTransform.identity)

        CATransaction.setCompletionBlock {
            (self.delegate as! LogoView).delegate?.LogoAnimationDidFinish()
        }
        let lineAnimation = CABasicAnimation(keyPath: "sublayers.bottomLine.transform")
        lineAnimation.fromValue = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 0, y: 1))
        lineAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        lineAnimation.duration = 0.7
        lineAnimation.beginTime = 0.6
        lineAnimation.fillMode = .both
        
        let textAnimation = CABasicAnimation(keyPath: "sublayers.subTitle.opacity")
        textAnimation.fromValue = 0
        textAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        textAnimation.duration = 0.7
        textAnimation.beginTime = 0.6
        textAnimation.fillMode = .both

        let textTransform = CABasicAnimation(keyPath:"sublayers.subTitle.transform")
        textTransform.fromValue = CATransform3DMakeAffineTransform(CGAffineTransform(translationX: -30, y: 0))
        textTransform.timingFunction = CAMediaTimingFunction(name: .default)
        textTransform.duration = 0.7
        textTransform.beginTime = 0.6
        textTransform.fillMode = .both
        
        let group = CAAnimationGroup()
        group.animations = [lineAnimation,textAnimation,textTransform]
        group.duration = 1.5
        add(group, forKey: nil)
    }

}
