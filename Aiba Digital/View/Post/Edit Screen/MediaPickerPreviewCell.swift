//
//  MediaPickerPreviewCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/23.
//

import UIKit
import Combine

class MediaPickerPreviewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    var ratioConstraint: NSLayoutConstraint!
    
    private let maxRatio: CGFloat = 4/3
    private let minRatio: CGFloat = 1/3
    
    
    private var subscriptions = Set<AnyCancellable>()
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    var viewModel: MediaPickerCellViewModel! {
        didSet{
            bindViewModelOutput()
            bindViewModelInput()
        }
    }
    
    
    private func bindViewModelOutput(){
        subscriptions.removeAll()
        imageView.image = nil
        
        viewModel.output.thumbnailImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.imageView.image = $0
            }.store(in: &subscriptions)
        
        viewModel.output.videoDuration
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                
            }.store(in: &subscriptions)
    }
    
    lazy var sizeSubject = PassthroughSubject<CGSize,Never>()
    
    private func bindViewModelInput(){
        
        ratioConstraint?.isActive = false
        var ratio = CGFloat(viewModel.contentHeight) / CGFloat(viewModel.contentWidth)
        ratio = max(minRatio, min(ratio, maxRatio))
        ratioConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio)
        ratioConstraint.priority = .init(999)
        ratioConstraint.isActive = true
        layoutIfNeeded()
  
        sizeSubject
            .bind(to: viewModel.input.imageTargetSize)
            .store(in: &subscriptions)
        
        // when the scale is available , it also means the cell size is updated with the new constraints
        let scale = UIScreen.main.scale
        sizeSubject.send(CGSize(width: bounds.width * scale, height: bounds.height * scale))
    }
}
