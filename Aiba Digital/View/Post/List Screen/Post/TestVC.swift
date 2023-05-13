//
//  TestVC.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/8.
//

import UIKit

class TestVC: UIViewController{
   
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        
        let scrollView = MediaScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    
        let image = UIImage(named: "image2")!
        let contentLayer = CALayer()
        contentLayer.contentsScale = UIScreen.main.scale
        contentLayer.frame = CGRect(origin: .zero, size: image.size)
        contentLayer.contents = image.cgImage!
        scrollView.display(contentLayer: contentLayer)
    }
}
