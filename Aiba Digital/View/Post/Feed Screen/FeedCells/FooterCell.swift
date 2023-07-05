//
//  LoadingCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/7/4.
//

import UIKit

protocol FooterCellDelegate: AnyObject{
    func refreshButtonTapped(_ footerCell: FooterCell)
}

class FooterCell: UICollectionViewCell {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var reachedBottomLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    enum State {
        case reachedBottom
        case loading
        case idle
        case error(message: String)
    }
    
    weak var delegate: FooterCellDelegate?

    func configure(with state: State){
        switch state{
        case .idle:
            hideAllViews()
        case .loading:
            spinner.startAnimating()
            hideAllViews(except: [spinner])
        case .reachedBottom:
            hideAllViews(except: [reachedBottomLabel])
        case .error(let message):
            errorLabel.text = message
            hideAllViews(except: [errorLabel, refreshButton])
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        delegate?.refreshButtonTapped(self)
    }
    
    private func hideAllViews(except views: [UIView] = []){
        let allViews: [UIView] = [refreshButton, reachedBottomLabel, spinner, errorLabel]
        allViews.forEach{ $0.isHidden = !views.contains($0)}
    }

}
