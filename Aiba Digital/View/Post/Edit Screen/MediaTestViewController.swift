//
//  MediaTestViewController.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/26.
//

import UIKit
import Combine

class MediaTestViewController: UIViewController {

    @IBOutlet weak var mediaGridView: GridView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var oneButton: UIButton!
    private var subscriptions = Set<AnyCancellable>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setup()
//        let imageURL1 = Bundle.main.url(forResource: "image1", withExtension: ".jpg")!
//        let imageURL2 = Bundle.main.url(forResource: "image2", withExtension: ".jpg")!
//        let imageURL3 = Bundle.main.url(forResource: "image3", withExtension: ".jpg")!
//        let imageURL4 = Bundle.main.url(forResource: "image4", withExtension: ".jpg")!
//        let imageURL5 = Bundle.main.url(forResource: "image5", withExtension: ".jpg")!
//
//        let q = "https://testPullZone20230325.b-cdn.net/360.mp4"
//        let o = "https://testPullZone20230325.b-cdn.net/OtterBox.mp4"
//        let s = "https://firebasestorage.googleapis.com/v0/b/stock-check-e7b95.appspot.com/o/media%2Fdemo.mp4?alt=media&token=37a2bf32-1788-4686-9a23-be572f1154d7"
//        let videoURL1 = URL(string: q)!
//        let videoURL2 = URL(string: o)!
//
//        let urls = [videoURL1, videoURL2, imageURL1, imageURL5]
//        let types = [".mp4", ".mp4", ".jpg", ".jpg"]
//
//        zip(urls,types).forEach { url, type in
//            let viewModel = MediaViewModel(url: url, fileExtension: type)
//            let mediaView = MediaView(viewModel: viewModel)
//            mediaGridView.add(mediaView)
//        }
//        mediaGridView.numberOfItemsOnTop = 2
    }

    func setup(){
        addButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                let image = UIImage(named: "image2")
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFill
                imageView.isUserInteractionEnabled = true
                //self?.mediaGridView.add(imageView)
            }.store(in: &subscriptions)
        
        removeButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                print("remove")
                
            }.store(in: &subscriptions)
        
        oneButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.mediaGridView.numberOfItemsOnTop = 1
            }.store(in: &subscriptions)
        
        twoButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.mediaGridView.numberOfItemsOnTop = 2
            }.store(in: &subscriptions)
        
        threeButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.mediaGridView.numberOfItemsOnTop = 3
            }.store(in: &subscriptions)
        
        allButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.mediaGridView.numberOfItemsOnTop = 10
            }.store(in: &subscriptions)
    }

}
