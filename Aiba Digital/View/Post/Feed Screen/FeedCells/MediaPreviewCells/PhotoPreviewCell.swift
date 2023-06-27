//
//  ImageCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/23.
//

import UIKit
import Combine


class PhotoPreviewCell: UICollectionViewCell {
    private let maxRatio: CGFloat = 5/4
    private let minRatio: CGFloat = 1/3
    private var ratioConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    var viewModel: PhotoViewModel!{
        didSet{
            bindViewModelOutput()
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
  
    private func bindViewModelOutput(){
//        
        subscriptions.removeAll()
        imageView.image = nil
        
        ratioConstraint?.isActive = false
        var ratio = CGFloat(viewModel.contentPixelHeight) / CGFloat(viewModel.contentPixelWidth)
        ratio = max(minRatio, min(ratio, maxRatio))
        ratioConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio)
        ratioConstraint.priority = .init(999)
        ratioConstraint.isActive = true
        layoutIfNeeded()
        
        // assign to will cause memory leak!!!!
        viewModel.output.imageData
            .receive(on: DispatchQueue.main)
            .map(UIImage.init(data:))
            .sink{ [weak self] image in
                guard let self else { return }
                imageView.image = image
            }
            .store(in: &subscriptions)
    }

    
    
    
    
}
