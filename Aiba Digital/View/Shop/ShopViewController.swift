//
//  ShopViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/26.
//

import UIKit
import MobileBuySDK

class ShopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let shopDomain = "aibadt.myshopify.com"
        let storefrontToken = "e7583928b4a75ff52917288b7cf3e0b3"
      
        let client = Graph.Client(shopDomain: shopDomain, apiKey: storefrontToken)
        
        let query = Storefront.buildQuery { $0
            .shop { $0
                .name()
            }
        }

        let task = client.queryGraphWith(query) { response, error in
            if let response = response {
                let name = response.shop.name
                print(name)
            } else {
                print("Query failed: \(error)")
            }
        }
        
        task.resume()
    }

}
