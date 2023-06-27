//
//  PostFlowController.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import UIKit
import Photos

class PostFlowController: UIViewController {
    
    private let embeddedNavigationController: UINavigationController = {
        let navigationController = UINavigationController()
        // embeddedTabBarController.delegate = self
        return navigationController
    }()
    //private let dependencies: HasPostManager

    init(){
      //  self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   extendedLayoutIncludesOpaqueBars = true
     //   tabBarController?.tabBar.isTranslucent = true
        transition(to: embeddedNavigationController)
        startPostFlow()
    }
    
    private func startPostFlow(){
        showFeedScreen()
    }

    private func showFeedScreen(){
        let viewModel = PostFeedViewModel()
        
        viewModel.didSelectPost = { [unowned self] post, index in
            showDetailScreen(for: post, mediaIndex: index)
        }
        viewModel.didRequestCreateNewPost = { [unowned self] in
            showEditScreen()
        }
        
        let vc = PostFeedViewController(viewModel: viewModel)
        vc.navigationItem.title = "店長動態"
        embeddedNavigationController.pushViewController(vc, animated: false)
    }
    
    private func showEditScreen(){
        
        let viewModel = EditPostViewModel()
      
        viewModel.didCancelEditing = { [unowned self] in
            dismiss(animated: true)
        }
        
        viewModel.didFinishEditing = { [unowned self] assets, text in
            dismiss(animated: true)
            showUploadScreen(assets: assets, text: text)
        }
        
        let editViewController = EditPostViewController(viewModel: viewModel)

        editViewController.modalPresentationStyle = .fullScreen
        present(editViewController, animated: true)
    }
    
    private func showUploadScreen(assets: [PHAsset], text: String){
        let viewModel = UploadPostViewModel(assets: assets, text: text)
        let uploadViewController = UploadPostViewController(viewModel: viewModel)
        
        addChild(uploadViewController)
        let childView = uploadViewController.view!
        childView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childView)
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: view.topAnchor),
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.heightAnchor.constraint(equalToConstant: 80)
        ])
        uploadViewController.didMove(toParent: self)
    }
    
    private func showDetailScreen(for post: Post, mediaIndex: Int){
        let viewModel = MediaDetailViewModel(post: post)
        viewModel.dismiss = { [unowned self] in
            self.dismiss(animated: true)
        }
        let detailVC = MediaDetailViewController(viewModel: viewModel, startIndex: mediaIndex)
        detailVC.modalPresentationStyle = .fullScreen
        present(detailVC, animated: true)
    }
}

extension PostFlowController: UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        KeyboardSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}


class KeyboardSizePresentationController: UIPresentationController{
    
    override var frameOfPresentedViewInContainerView: CGRect{
        var rect = super.frameOfPresentedViewInContainerView
        rect.origin.y += rect.height - 400
        return rect
    }
    
    override func presentationTransitionWillBegin() {
        if let toVC = presentingViewController as? EditPostViewController{
            print("yes")
        }
    }
}
