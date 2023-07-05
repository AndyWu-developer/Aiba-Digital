//
//  TestViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/29.
//

import UIKit
import AVFoundation

class TestViewController: UIViewController {

    @IBOutlet weak var videoView: VideoView!
  
    let player  = AVPlayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
     
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //videoView.shouldAutoPlay = true
    }

}
extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
