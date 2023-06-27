//
//  MediaPickerCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/2.
//

import UIKit
import Combine

class MediaPickerCell: UICollectionViewCell {

    @IBOutlet weak var circle: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var selectedNumberLabel: UILabel!
    @IBOutlet weak var videoDurationLabel: UILabel!
    
    var viewModel: MediaPickerCellViewModel!{
        didSet{
            subscriptions.removeAll()
            bindViewModelOutput()
            bindViewModelInput()
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
 
    let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    lazy var sizeSubject = CurrentValueSubject<CGSize,Never>(targetSize)
    
    private func bindViewModelInput(){
        //sizeSubject.subscribe(viewModel.input.imageTargetSize)
        sizeSubject
            .bind(to: viewModel.input.imageTargetSize)
            .store(in: &subscriptions)
        selectButton.publisher(for: .touchUpInside)
            .map{ _ in }
            .bind(to: viewModel.input.toggleSelection)
            .store(in: &subscriptions)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        circle.layer.borderWidth = 1
        circle.layer.borderColor = UIColor.white.cgColor
    }
    
    private func bindViewModelOutput(){
        imageView.image = nil
        
        viewModel.output.thumbnailImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.imageView.image = $0
            }.store(in: &subscriptions)
        
        viewModel.output.videoDuration
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.videoDurationLabel.text = text
                self?.videoDurationLabel.isHidden = (text == nil)
            }.store(in: &subscriptions)
        
        viewModel.output.selectedNumber
            .receive(on: DispatchQueue.main)
            .sink { [weak self] number in
                let isSelected = (number != 0)
                self?.dimView.isHidden = !isSelected
                self?.selectedNumberLabel.isHidden = !isSelected
                self?.selectedNumberLabel.text = String(number)
            }.store(in: &subscriptions)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }

}
