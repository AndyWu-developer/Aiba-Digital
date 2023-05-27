//
//  PostTextCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/5.
//

import UIKit
import Combine

protocol PostTextCellDelegate: AnyObject{
    func updateHeight(_ cell: PostTextCell)
}

class PostTextCell: UICollectionViewCell {
  
    //https://stackoverflow.com/a/34284563/21419169
    // with "Content Mode" under "View" to "top" it will smoothly reveal the hidden lines.
    
    @IBOutlet weak var textLabel: UILabel!
    weak var delegate:PostTextCellDelegate?
    private var subscriptions = Set<AnyCancellable>()
    
    let singleTap = UITapGestureRecognizer()
    let t = "美國NOMAD iPhone 14 Pro\n真牛皮皮革背板殼！現貨供應中\n\n艾巴數位\n台中市南屯區大墩路894號\n04-23272366\n#NOMAD\n#牛皮手機殼"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel.contentMode = .top // Very important for animation!
        textLabel.addGestureRecognizer(singleTap)
        textLabel.text = t
     
        singleTap.publisher()
            .sink{ [weak self] _ in
                guard let self = self else {return}
                viewModel.isTextExpanded.toggle()
                self.textLabel.numberOfLines = self.viewModel.isTextExpanded ? 0 : 2
                self.textLabel.text = self.t
                
                UIView.animate(withDuration: 0.25) {
                    self.delegate?.updateHeight(self)
                }
            }.store(in: &subscriptions)
        
    }
    
    var viewModel: FeedTextViewModel!
    
    func configure(with viewModel: FeedTextViewModel){
        self.viewModel = viewModel
        textLabel.numberOfLines = viewModel.isTextExpanded ? 0 : 2
        textLabel.text = t
    }

}
