
import Foundation
import UIKit

extension UIImage {
    func scaledDown(into size : CGSize = CGSize(width: 200, height: 300)) -> UIImage{
        var (targetWidth, targetHeight) = (self.size.width, self.size.height)
        var (scaleW, scaleH) = (1 as CGFloat, 1 as CGFloat)
        if targetWidth > size.width{
            scaleW = size.width/targetWidth
        }
        if targetHeight > size.height{
            scaleH = size.height/targetHeight
        }
        let scale = min(scaleW, scaleH)
        targetWidth *= scale
        targetHeight *= scale
        let sz = CGSize(width: targetWidth, height: targetHeight)
        return UIGraphicsImageRenderer(size: sz).image{ _ in
            self.draw(in: CGRect(origin: .zero, size: sz))
        }
        
    }
    
    func downSize() -> UIImage{
        
        let newSize = size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5)) //2
        let renderer = UIGraphicsImageRenderer(size: newSize) //3
        let scaledImage = renderer.image { (context) in
          let rect = CGRect(origin: CGPoint.zero, size: newSize)
          self.draw(in: rect) //4
        }
        return scaledImage
    }
    @IBInspectable var tintColor: UIColor {
        set{
            self.tintColor = newValue
        }
        get{
            return self.tintColor
        }
    }
}

extension String {
    func image() -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: 50) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIColor.clear.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? UIImage()
    }
}

extension UIImage {
    func scaleTo(_ newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
//    func setupLayout() {
//
//        //print every name of the built-in font
////        UIFont.familyNames.forEach{
////            UIFont.fontNames(forFamilyName: $0).forEach{print($0)}
////        }

//        for letter in titleText{
//            Timer.scheduledTimer(withTimeInterval: 0.1 * Double(charIndex), repeats: false) { (timer) in
//                titleLabel.text?.append(letter)
//            }
//            charIndex += 1
//        }
//
//        Timer.scheduledTimer(withTimeInterval: 0.1 * Double(charIndex), repeats: false) { (timer) in
//            logoLabel.text = "🕶"
//        }
