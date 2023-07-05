//
//  PostHeaderCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/5.
//

import UIKit
import Combine

protocol PostHeaderCellDelegate: AnyObject {
    func delete(_ cell: PostHeaderCell)
}

class PostHeaderCell: UICollectionViewCell {
    
    deinit {
        print("PostHeaderCell deinit")
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    weak var viewModel: PostHeaderViewModel!{
        didSet{
            bindViewModelOutput()
        }
    }
    
    weak var delegate: PostHeaderCellDelegate?
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var popUpMenu: UIMenu = { [weak self] in // need weak self or we will have a retatin cycle!
        let delete = UIAction(title: "刪除貼文", image: UIImage(systemName: "trash"), attributes: .destructive){ _ in
            let alert = UIAlertController(title: "確定刪除？", message: "貼文刪除後便無法復原", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(UIAlertAction(title: "刪除", style: .destructive, handler: { [weak self] _ in
                guard let self = self else {return}
                delegate?.delete(self)
            }))
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
        userImageButton.setImage(UIImage(named: "userIcon")!, for: .normal)
    }
    
    func bindViewModelOutput(){
        
        subscriptions.removeAll()
        userNameButton.setTitle(viewModel.output.title, for: .normal)
        dateLabel.text = viewModel.output.date
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
