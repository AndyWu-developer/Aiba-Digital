//
//  TODO.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/19.
//

import UIKit

class TODO: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    let text: String
    
    init(_ title: String){
        text = title
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .formSheet
    }
    
    required init?(coder: NSCoder) { fatalError("create TODO with init(title:)") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = text
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

