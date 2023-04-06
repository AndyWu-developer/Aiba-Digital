//
//  PostCell.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/18.
//

import UIKit
import Combine
import AVFoundation

protocol PostCellDelegate: AnyObject{
    func update(_ cell:PostCell)
}

class PostCell: UICollectionViewCell {
static var count = 0
    static let reuseIdentifier = "post-cell-reuse-identifier"
    static let nibName = "PostCell"
    
    @IBOutlet private weak var pinButton: UIButton!
    @IBOutlet private weak var moreButton: UIButton!
    @IBOutlet private weak var profileButton: UIButton!
    @IBOutlet private weak var mediaGridView: GridView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var commentButton: UIButton!
    @IBOutlet private weak var shopButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
    weak var delegate: PostCellDelegate?
    weak var player: AVPlayer? {
        didSet{
            if oldValue != player{
                player?.replaceCurrentItem(with: nil)
                viewModel.sharedPlayer = player
            }
        }
    }
    
    var viewModel: PostCellViewModel! {
        didSet{
            bindViewModelInput()
            bindViewModelOutput()
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
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
    
    //You should put the code needed to style and configure a cell inside the actual cell. If it’s something that’s going to be there during the whole lifecycle of the cell, like a label’s font, put it in the awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        moreButton.menu = popUpMenu
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }
   
    private func bindViewModelInput(){
       
       shopButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }

                self.viewModel.isExpanded = true
                textLabel.numberOfLines = 0
                self.delegate?.update(self)
            }.store(in: &subscriptions)
        
//            .subscribe(viewModel.input.expand)
//
//        likeButton.publisher(for: .touchUpInside)
//            .map{_ in}
//            .subscribe(viewModel.input.like)
    }
    
    private func bindViewModelOutput(){
        self.textLabel.numberOfLines = viewModel.isExpanded ? 0 : 3
//        viewModel.output.isExpanded
//            .removeDuplicates()
//            .sink { isExpand in
//                self.textLabel.numberOfLines = isExpand ? 0 : 3
//            }.store(in: &subscriptions)
//        
        viewModel.output.mediaViewModels
            .map{ $0.map(MediaView.init) }
            .assign(to: \.items, on: mediaGridView)
            .store(in: &subscriptions)
        
//        viewModel.output.itemsInTopRow
//            .assign(to: \.numberOfItemsOnTop, on: mediaGridView)
//            .store(in: &subscriptions)
        
        viewModel.output.text
            .assign(to: \.text!, on: textLabel)
            .store(in: &subscriptions)
    }

}


