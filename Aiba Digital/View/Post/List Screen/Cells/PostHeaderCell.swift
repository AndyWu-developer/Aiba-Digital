//
//  PostHeaderCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/5.
//

import UIKit

class PostHeaderCell: UICollectionViewCell {
    
    static let reuseIdentifier = "post-header-cell-reuse-identifier"
    static let nibName = "PostHeaderCell"
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
