//
//  TextViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/17.
//

import UIKit
import Combine

class TextViewController: UIViewController {
    var textViewHeightConstraint: NSLayoutConstraint!
    
    var subscriptions = Set<AnyCancellable>()
    let text = "哈雷腳踏車，帶你開啟一場極速之旅！以哈雷摩托車經典造型為藍本，融入最新科技，打造出極致速度和極致體驗的完美結合。搭配強大的中央驅動系統和智能電動技術，讓你輕鬆應對各種路況。無論是市區街道還是山路崎嶇，Serial one都能讓你快速穿越。現在就加入Serial one的行列，感受極速之美吧！"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(textView)
 
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemYellow
        view.addSubview(v)
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: textView.bottomAnchor),
            v.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            v.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            v.heightAnchor.constraint(equalToConstant: 200),
            v.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            v.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(label)
 
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: textView.topAnchor),
            label.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            label.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
        ])
        
        view.addSubview(seeMoreButton)
        seeMoreButton.trailingAnchor.constraint(equalTo: v.trailingAnchor).isActive = true
        seeMoreButton.bottomAnchor.constraint(equalTo: v.bottomAnchor).isActive = true
        seeMoreButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        textView.addGestureRecognizer(singleTap)
        
        
        singleTap.publisher()
            .sink { [unowned self] _ in
                print("back")
         
                textView.textContainer.maximumNumberOfLines = 1
                let contentSize = textView.sizeThatFits(textView.bounds.size)
                let newHeight = contentSize.height
                textView.textContainer.maximumNumberOfLines = 0
                textViewHeightConstraint.isActive = false
                textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: newHeight)
                textViewHeightConstraint.isActive = true
                textView.isScrollEnabled = false
                UIView.animate(withDuration: 2,animations: {self.view.layoutIfNeeded()}) { _ in
                    self.textView.textContainer.maximumNumberOfLines = 1
                    
                }
                    
            
            }.store(in: &subscriptions)
        
        
        let vv = UIView()
        vv.translatesAutoresizingMaskIntoConstraints = false
        vv.backgroundColor = .systemYellow
        view.addSubview(vv)
        
        NSLayoutConstraint.activate([
            vv.bottomAnchor.constraint(equalTo: textView.topAnchor),
            vv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vv.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    let singleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        return tap
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let isTextTruncated = textView.isTextTruncated
        //seeMoreButton.isHidden = !isTextTruncated
        print(textView.bounds.size.height)
    }
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = text
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .label
        textView.textAlignment = .left
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isSelectable = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byTruncatingTail
    //    textView.textContainer.maximumNumberOfLines = 1
       // textView.alpha = 0
        //textViewHeightConstraint = textView.heightAnchor.constraint(lessThanOrEqualToConstant: 20)
       // textViewHeightConstraint.isActive = true
        return textView
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
    //    label.numberOfLines = 1
        label.textColor = .blue
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        return label
    }()
    

    
    let seeMoreButtonGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.locations = [0.0, 0.4]
        let angle = (CGFloat.pi / 2) * 3
        gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        return gradientLayer
    }()
    
    lazy var seeMoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("more", for: .normal)
        button.addTarget(self, action: #selector(handleSeeMore), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        return button
    }()
    
    @objc fileprivate func handleSeeMore() {
        textView.textContainer.maximumNumberOfLines = 0
        let contentSize = textView.sizeThatFits(textView.bounds.size)
        let newHeight = contentSize.height
        print("new height \(newHeight)")
        
        let maxHeight = view.bounds.size.height / 4
        if newHeight > maxHeight{
            print("exceed")
            textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: maxHeight)
            
            textView.isScrollEnabled = true
            textViewHeightConstraint.isActive = true
        }else{
            textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: newHeight)
            textViewHeightConstraint.isActive = true
        }

        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
            self.textView.alpha = 1
          //  self.label.alpha = 0
            // if the textView is in a collectionView cell, here you need to call layoutIfNeeded() on the cell and then:
            
            // - if using regular collectionView:
            // collectionViewController.collectionView.collectionViewLayout.invalidateLayout()
            
            // - or if using compositional layout and diffable data source:
            // let snapshot = collectionViewController.diffableDataSource.snapshot()
            // collectionViewController.diffableDataSource.apply(snapshot, animatingDifferences: true)
        }
        seeMoreButton.isHidden = true
    }
}

extension UITextView {
    var isTextTruncated: Bool {
        var isTruncating = false
        
        // The truncatedGlyphRange(...) method will tell us if text has been truncated
        // based on the line break mode of the text container
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: Int.max)) { _, _, _, glyphRange, stop in
            let truncatedRange = self.layoutManager.truncatedGlyphRange(inLineFragmentForGlyphAt: glyphRange.lowerBound)
            if truncatedRange.location != NSNotFound {
                isTruncating = true
                stop.pointee = true
            }
        }
        
        // It's possible that the text is truncated not because of the line break mode,
        // but because the text is outside the drawable bounds
        if isTruncating == false {
            let glyphRange = layoutManager.glyphRange(for: textContainer)
            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            
            let totalTextCount = text.utf16.count
            isTruncating = characterRange.upperBound < totalTextCount
        }
        
        return isTruncating
    }
}
