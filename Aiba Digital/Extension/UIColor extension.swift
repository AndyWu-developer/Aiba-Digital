import UIKit

//MARK: - UIColor Extension
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
   
   static var lightGreen : UIColor {UIColor(red: 0, green: 173, blue: 22)}
   static var darkGreen : UIColor {UIColor(red: 0, green: 82, blue: 92)}
   static var lightBlue : UIColor {UIColor(red: 0, green: 175, blue: 193)}
   static var lightGray : UIColor {UIColor(red: 151, green: 184, blue: 186)}
   static var lightYellow : UIColor {UIColor(red: 255, green: 213, blue: 0)}
   static var darkBlue : UIColor {UIColor(rgb: 0x25346D)}
   static var loadingGray : UIColor {UIColor(red: 110/255, green: 110/255, blue: 110/255)}
   static var loadingBlue : UIColor {UIColor(red: 41, green: 45, blue: 110)}
   static var lightOrange : UIColor {UIColor(red: 255, green: 182, blue: 57)}
   static var lightgreen : UIColor {UIColor(rgb: 0xE3FDFD)}
   static var midGreen : UIColor {UIColor(rgb: 0xCBF1F5)}
   static var loadGray : UIColor {UIColor(rgb: 0xDEE2E6)}
   static var backgroundWhite : UIColor {UIColor(red: 254, green: 254, blue: 254)}
   static var gapGray : UIColor {UIColor(rgb: 0xF4F4F4)}
}
