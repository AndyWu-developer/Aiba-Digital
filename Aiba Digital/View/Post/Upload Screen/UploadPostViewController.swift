//
//  UploadPostViewController.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/24.
//

import UIKit
import Combine

class UploadPostViewController: UIViewController {

    @IBOutlet weak var uploadStatusLabel: UILabel!
    private let viewModel: UploadPostViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: UploadPostViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Just(()).bind(to: viewModel.input.startUpload).store(in: &subscriptions)
        
        viewModel.output.uploadSuccess
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.uploadStatusLabel.text = "上傳成功！"
            }.store(in: &subscriptions)
    }
}
