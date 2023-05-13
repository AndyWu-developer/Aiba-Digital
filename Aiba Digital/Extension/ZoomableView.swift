//
//  ZoomableMediaView.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/21.
//

import UIKit

class ZoomableView: UIScrollView {
    
    var index: Int!
    // scrollView's contentView, it must have some internal constraint (ratio constraint or intrinsic size)
    var contentView: UIView? {
        didSet{
            oldValue?.removeFromSuperview()
            guard let contentView else { return }
            contentView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(contentView)
            let v = UILabel()
            v.text = "Serial 1 - MOSH/CTY"
            v.sizeToFit()
            v.font = .systemFont(ofSize: 25, weight: .heavy)
            v.backgroundColor = .white
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
        
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
                contentView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
                contentView.heightAnchor.constraint(lessThanOrEqualTo: frameLayoutGuide.heightAnchor),
                contentView.widthAnchor.constraint(lessThanOrEqualTo: frameLayoutGuide.widthAnchor),
                v.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant:  10),
                v.centerXAnchor.constraint(equalTo: frameLayoutGuide.centerXAnchor)
            ])
            
    
        }
    }
    
    init(){
        super.init(frame: .zero)
        maximumZoomScale = 4
        delegate = self
        bouncesZoom = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let contentView else { return }
        let scrollViewSize = bounds.size
        let verticalPadding = contentView.frame.height < scrollViewSize.height ? (scrollViewSize.height - contentView.frame.height) / 2 : 0
        let horizontalPadding = contentView.frame.width < scrollViewSize.width ? (scrollViewSize.width - contentView.frame.width) / 2 : 0
        contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding , right: horizontalPadding)
    }
   
}

extension ZoomableView: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}
