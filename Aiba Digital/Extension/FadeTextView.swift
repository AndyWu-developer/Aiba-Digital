//
//  FadwTextView.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/18.
//

import UIKit

class FadeTextView: UITextView, UITextViewDelegate {

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        //delegate = self
    }
    
      let fadePoints: Float = 64.0
      let gradientLayer = CAGradientLayer()
      let transparentColor = UIColor.clear.cgColor
      let opaqueColor = UIColor.black.cgColor
      
      var topFadingOpacity: CGColor {
          
          let scrollOffset = contentOffset.y
          let alpha:CGFloat = ( scrollOffset <= 0) ? 1 : 0
          let color = UIColor(white: 0, alpha: alpha)
          return color.cgColor
      }
      
      var bottomFadingOpacity: CGColor {
          let scrollViewHeight = frame.size.height
          let scrollContentSizeHeight = contentSize.height
          let scrollOffset = contentOffset.y
          
          let alpha:CGFloat = (scrollOffset + scrollViewHeight >= scrollContentSizeHeight) ? 1 : 0
          let color = UIColor(white: 0, alpha: alpha)
          return color.cgColor
      }
      
      override func layoutSubviews() {
          super.layoutSubviews()
         
          let maskLayer = CALayer()
          maskLayer.frame = self.bounds
          
          let gradientLocation = fadePoints / Float(contentSize.height)
          gradientLayer.frame = CGRect(x: self.bounds.origin.x, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
          gradientLayer.colors = [topFadingOpacity, opaqueColor, opaqueColor, bottomFadingOpacity]
          gradientLayer.locations = [0, NSNumber(value: gradientLocation), NSNumber(value: 1 - gradientLocation), 1]
          maskLayer.addSublayer(gradientLayer)
          
          self.layer.mask = maskLayer
      }

      /// Update gradient depending on content offset of the scrollview
      /// Call this function in [scrollViewDidScroll] of UIScrollViewDelegate
      func updateGradient() {
          gradientLayer.colors = [topFadingOpacity, opaqueColor, opaqueColor, bottomFadingOpacity]
      }
    
    
      func scrollViewDidScroll(_ scrollView: UIScrollView) {
          updateGradient()
      }
}
