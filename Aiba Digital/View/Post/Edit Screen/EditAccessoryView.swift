//
//  EditPostAccessoryView.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/21.
//

import UIKit

class EditAccessoryView: UIView {
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var keyboardButton: UIButton!
    
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customInit(){
        translatesAutoresizingMaskIntoConstraints = false // required!
        let view = Bundle.main.loadNibNamed(String(describing: EditAccessoryView.self), owner : self)!.first as! UIView // owner has to be self or will error
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
  
}
