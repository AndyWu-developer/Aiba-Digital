//
//  VideoSlider.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/20.
//

import UIKit

@IBDesignable class VideoSlider: UISlider {

    @IBInspectable var trackHeight: CGFloat = 3

    @IBInspectable var roundImage: UIImage? {
        didSet{
            setThumbImage(roundImage, for: .normal)
        }
    }
    
    @IBInspectable var roundHighlightedImage: UIImage? {
        didSet{
            setThumbImage(roundHighlightedImage, for: .highlighted)
        }
    }
    //the origin of the track rect must be offset to account for the change in height of the track, otherwise it will show up off-center
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        //    let originalRect = super.trackRect(forBounds: bounds)
        var customBounds = super.trackRect(forBounds: bounds)
        customBounds.size.height = trackHeight
        return customBounds
    }
    

}
