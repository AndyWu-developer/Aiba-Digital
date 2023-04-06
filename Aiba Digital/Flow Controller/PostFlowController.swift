//
//  PostFlowController.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import UIKit

class PostFlowController: UIViewController {
    
    private let dependencies: HasPostManager

    init(dependencies: HasPostManager){
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start(){
        let postViewModel = PostViewModel(dependencies: dependencies)
        let postViewController = PostListViewController(viewModel: postViewModel)
        transition(to: postViewController)
    }


}
