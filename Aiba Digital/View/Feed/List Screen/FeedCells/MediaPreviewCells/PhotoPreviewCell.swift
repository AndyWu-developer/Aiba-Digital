//
//  ImageCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/23.
//

import UIKit
import Combine

protocol PhotoPreviewCellDelegate: AnyObject{
    func updateHegiht()
}

class PhotoPreviewCell: UICollectionViewCell {
    
    private var ratioConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    weak var delegate: PhotoPreviewCellDelegate?
    var viewModel: PhotoCellViewModel!{
        didSet{
            bindViewModelOutput()
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
  
    private func bindViewModelOutput(){
//        
        subscriptions.removeAll()
        imageView.image = nil
        let size = CGSize(width: 1920, height: 1080)

        ratioConstraint?.isActive = false
        ratioConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: CGFloat(size.width) / CGFloat(size.height))
        ratioConstraint.priority = UILayoutPriority(999)
        ratioConstraint.isActive = true
       // delegate!.updateHegiht()
        
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
