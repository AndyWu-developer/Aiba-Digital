//
//  ShowMoreLabel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/19.
//

import UIKit

class ShowMoreLabel: UILabel {

    var truncationToken = " ...顯示更多"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addShowMoreIfNeeded()
    }

    private func heightForText(_ text: String) -> CGFloat {
        let textStorage = NSTextStorage(string: text)
        let textContainer = NSTextContainer(size: CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = .zero
        let layoutManager = NSLayoutManager()
        layoutManager.usesFontLeading = false
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textStorage.addAttribute(NSAttributedString.Key.font, value: font!, range: NSRange(location: 0, length: textStorage.length))

        layoutManager.glyphRange(for: textContainer)
        return layoutManager.usedRect(for: textContainer).size.height
    }
  
    private func addShowMoreIfNeeded(){
        
        let linesOfText = String(repeating: "\n", count: numberOfLines)
        let sentenceText = NSString(string: text!)
        let sentenceRange = NSRange(location: 0, length: sentenceText.length)
        var endIndex = sentenceRange.upperBound
        var truncatedSentence = sentenceText
        
        while heightForText(truncatedSentence as String) >= heightForText(linesOfText){
            if endIndex == 0 { break }
            endIndex -= 1
            truncatedSentence = NSString(string: sentenceText.substring(with: NSRange(location: 0, length: endIndex)))
            truncatedSentence = (String(truncatedSentence) + truncationToken) as NSString
        }
        text = truncatedSentence as String
    }
  
}


//    func heightForText(text: NSString) -> CGFloat{
//      //  let string = text as NSString
//        let pargraph = NSMutableParagraphStyle()
//        pargraph.lineBreakMode = .byTruncatingTail
//        let attr: [NSAttributedString.Key: Any] = [.font: self.font!]
//        let size = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
//
//        return ceil(text.boundingRect(with: size,options: .usesLineFragmentOrigin, attributes: attr, context: nil).height)
//    }
