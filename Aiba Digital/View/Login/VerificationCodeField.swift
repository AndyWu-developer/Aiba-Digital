

import UIKit

@IBDesignable class VerificationCodeField: UITextField {
    
    let sendButton = SendSMSButton()
    
    @IBInspectable var placeholderText: String = "" {
        didSet {
            placeholder = placeholderText
        }
    }
  
    @IBInspectable var leftImageColor : UIColor = UIColor() {
        didSet {
            (leftView as! UIImageView).tintColor = leftImageColor
        }
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        configure()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect = super.textRect(forBounds: bounds)
        return originalRect.offsetBy(dx: -10, dy: 0) //move 10 points left
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect = super.rightViewRect(forBounds: bounds)
        return originalRect.offsetBy(dx: -7, dy: 0) //move 7 points left
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect = super.editingRect(forBounds: bounds)
        return originalRect.offsetBy(dx: -10, dy: 0) //move 10 points left
    }
    
    func configure(){
        borderStyle = .roundedRect
        clipsToBounds = true
        layer.cornerRadius = 25
        font = font?.withSize(18)
        leftView = UIImageView(image: UIImage(named: "verification-code1")!)
        leftView?.contentMode = .scaleAspectFit
        leftView?.widthAnchor.constraint(equalToConstant: 45).isActive = true
        leftView?.heightAnchor.constraint(equalToConstant: 25).isActive = true
        leftViewMode = .always
        rightViewMode = .always
        rightView = sendButton
    }
}
