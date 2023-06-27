//
//  ShopFlowController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/18.
//

import UIKit

class ShopFlowController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      
        let child = ShopViewController()
        transition(to: child )
    }

}
