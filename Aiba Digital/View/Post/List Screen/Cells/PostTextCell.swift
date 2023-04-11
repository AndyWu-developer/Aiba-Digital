//
//  PostTextCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/5.
//

import UIKit

class PostTextCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    
    private var isExpanded = false {
        didSet{
            textLabel.numberOfLines = isExpanded ? 0 : 3
        }
    }
    
    func configure(with viewModel: PostTextViewModel){
        
        
    }
}
