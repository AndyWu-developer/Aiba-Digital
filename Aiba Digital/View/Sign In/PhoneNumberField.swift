//
//  PhoneNumberTextField.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/5.
//

import UIKit

@IBDesignable class PhoneNumberField: UITextField {
    
    var countryCode: String = ""{
        didSet{
            countrySelectionButton.setTitle(countryCode, for: .normal)
            countrySelectionButton.sizeToFit()
            setNeedsLayout()
        }
    }
    
    private let imageView = UIImageView()
    
    @IBInspectable var placeholderText: String = "" {
        didSet {
            placeholder = placeholderText
        }
    }
    
    @IBInspectable var leftImageColor: UIColor = UIColor(){
        didSet {
            imageView.tintColor = leftImageColor
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        configure()
    }
    
    let countrySelectionButton: UIButton = {
        let b = UIButton()
        b.clipsToBounds = true
        b.setTitleColor(.black, for: .normal)
        let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight:.bold, scale: .small)
        let image = UIImage(systemName: "chevron.down")!.withTintColor(.black, renderingMode: .alwaysOriginal).withConfiguration(configuration)
        b.setImage(image, for: .normal)
        b.imageEdgeInsets.left = 3
        b.contentEdgeInsets.right = 3
        b.contentHorizontalAlignment = .left
        b.semanticContentAttribute = .forceRightToLeft
        b.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return b
    }()

    
    func configure(){
        
        borderStyle = .roundedRect
        font = font?.withSize(18)
        clipsToBounds = true
        layer.cornerRadius = 25
        imageView.image = UIImage(systemName: "phone.fill")!
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
     
        let customLeftView: UIStackView =  {
            let sv = UIStackView(arrangedSubviews: [imageView, countrySelectionButton])
            sv.axis = .horizontal
            sv.distribution = .fill
            sv.alignment = .center
            sv.spacing = -5
            return sv
        }()
        
        leftView = customLeftView
        leftViewMode = .always
    }
}

