//
//  ShowMoreLabel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/19.
//

// Adapted from https://gist.github.com/Catherine-K-George/3bffbf1433b34b630b7bc572d6af9f6d
import UIKit

class ShowMoreLabel: UILabel {

    var truncationToken = " ...顯示更多"
    //Make sure to set the correct the default font, seems weird with "." at the beginning, try PingFang TC Regular 17.0 which works
    private var originalText: String = ""
    
//    override var text: String? {
//        set {
//            originalText = newValue
//            super.text = newValue
//        }
//        get { return super.text }
//    }

    override func layoutSubviews() {
        super.layoutSubviews()
        truncateIfNeeded()
    }

    private func truncateIfNeeded(){
        if numberOfLines == 0 { return }
        let maxHeight = heightForText(String(repeating: "\n", count: numberOfLines))

        if heightForText(text!) > maxHeight {
            var count = 0
            var needTruncate = true
            while heightForText(String(text!.prefix(count)) + truncationToken) < maxHeight {
                if count == text!.count { needTruncate = false ; break }
                count += 1
            }
            if needTruncate{
                text = String(text!.prefix(count-1)) + truncationToken
            }
        }
    }
    
    private func heightForText(_ text: String) -> CGFloat {
        
        let size = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        
        let textContainer = NSTextContainer(size: size)
        textContainer.lineFragmentPadding = .zero
       // textContainer.lineBreakMode = .byWordWrapping
        
        let layoutManager = NSLayoutManager()
        layoutManager.usesFontLeading = false
        layoutManager.addTextContainer(textContainer)
        
        let textStorage = NSTextStorage(string: text)
        textStorage.addAttribute(NSAttributedString.Key.font, value: font!, range: NSRange(location: 0, length: textStorage.length))
        textStorage.addLayoutManager(layoutManager)
        
        layoutManager.glyphRange(for: textContainer) //force layout manager to layout the text
        return layoutManager.usedRect(for: textContainer).height
    }
    
}

//    private func addShowMoreIfNeeded(){
//        guard numberOfLines != 0 else { return }
//        let linesOfText = String(repeating: "\n", count: numberOfLines)
//        let maxHeight = heightForText(linesOfText)
//
//        var tempText = text!
//        var count = tempText.count
//        heightForText(tempText)
////
//        while heightForText(tempText) >= maxHeight {
//            if count == 0 { break }
//            count -= 1
//            tempText = tempText.prefix(count) + truncationToken
//        }
//        if text != "mfortmfoirmifmormfirfvrtf"{
//            text = "mfortmfoirmifmormfirfvrtf"
//            //setNeedsLayout()
//        }
//
//
//
//    }
