//
//  PostHeaderCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/5.
//

import UIKit

class PostHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var tilteButton: UIButton!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    private lazy var popUpMenu: UIMenu = {
        let delete = UIAction(title: "刪除貼文", image: UIImage(systemName: "trash"), attributes: .destructive){ _ in
            let alert = UIAlertController(title: "確定刪除？", message: "貼文刪除後便無法復原", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(UIAlertAction(title: "刪除", style: .destructive))
            let rootVC = UIApplication.shared.windows.first!.rootViewController!
            rootVC.present(alert, animated: true)
        }
        let edit = UIAction(title: "編輯貼文", image: UIImage(systemName: "square.and.pencil")){ _ in}
        let menu = UIMenu(title: "", children: [delete, edit])
        return menu
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moreButton.menu = popUpMenu
    }
    
    func configure(with viewModel: PostHeaderViewModel){
        
    }

}
