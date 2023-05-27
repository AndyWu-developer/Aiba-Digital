//
//  MainFlowController.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/15.
//

import UIKit

protocol MainFlowControllerDelegate: AnyObject {
    func userLoggedOut()
}

class MainFlowController: UIViewController {
    
    private var embeddedTabBarController = UITabBarController()
    weak var flowDelegate: MainFlowControllerDelegate?
    typealias Dependencies = HasAuthManager & HasPostManager
    private let dependencies: Dependencies
    
    //var interactionController: UIPercentDrivenInteractiveTransition?

    init(dependencies: Dependencies){
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
        embeddedTabBarController.tabBar.isTranslucent = false
        embeddedTabBarController.tabBar.barTintColor = .backgroundWhite
        embeddedTabBarController.tabBar.tintColor = .black
        embeddedTabBarController.tabBar.unselectedItemTintColor = .black
        
       // embeddedTabBarController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return children.first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settingFlowVC = SettingFlowController(dependencies: dependencies)
        settingFlowVC.flowDelegate = self
        settingFlowVC.tabBarItem = UITabBarItem(title: "我的會員", image: UIImage(named: "Profile")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                                                selectedImage:  UIImage(named: "Profile-1"))
        settingFlowVC.start()

        
        let vc1 = UIViewController()
        vc1.tabBarItem = UITabBarItem(title: "來去逛逛", image: UIImage(named: "Shop")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                                       selectedImage:  UIImage(named: "Shop-1"))
        
//        let postFlowController = PostFlowController(dependencies: dependencies)
//        //postFlowController.flowDelegate = self
//        postFlowController.tabBarItem = UITabBarItem(title: "店長動態", image: UIImage(named: "News")!.withTintColor(.black, renderingMode: .alwaysOriginal),selectedImage:  UIImage(named: "News-1"))
//        postFlowController.start()
        
        let vc3 = MediaDetailViewController(viewModel: MediaDetailViewModel())
        vc3.tabBarItem = UITabBarItem(title: "關於本店", image: UIImage(systemName: "info.circle")?.withTintColor(.black, renderingMode: .alwaysOriginal),selectedImage:  UIImage(systemName: "info.circle.fill")?.withTintColor(.lightYellow, renderingMode: .alwaysOriginal))

        embeddedTabBarController.setViewControllers([vc3,FeedListViewController(),settingFlowVC], animated: false)
        embeddedTabBarController.selectedIndex = 1
        
        addChild(embeddedTabBarController)
        view.addSubview(embeddedTabBarController.view)
        didMove(toParent: self)
       
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
//        pan.delegate = self
//        embeddedTabBarController.view.addGestureRecognizer(pan)
    }
    
    deinit{
        print("MainFlowController deinit")
    }
}

extension MainFlowController: SettingFlowControllerDelegate {
    
    func userLoggedOut() {
        flowDelegate?.userLoggedOut()
    }
}

//extension MainFlowController: UITabBarControllerDelegate {
//    
//    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return interactionController as? UIViewControllerAnimatedTransitioning
//    }
//    
//    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return interactionController
//    }
//    
//    @objc func didPan(_ gesture: UIPanGestureRecognizer) {
//      
//        let flickThreshold: CGFloat = 700.0 // minimum speed to make transition complete
//        let distanceThreshold: CGFloat = 0.3 // minimum distance to make transition complete
//        let percent = abs(gesture.translation(in: gesture.view!).x / gesture.view!.bounds.width)
//        
//        switch gesture.state {
//        case .began:
//            interactionController = MainViewAnimationController(tabBarController: embeddedTabBarController)
//            if gesture.velocity(in: gesture.view!).x > 0 {  //user swiped right
//                embeddedTabBarController.selectedIndex -= 1
//            }else{
//                embeddedTabBarController.selectedIndex += 1 // user swiped left
//            }
//            case .changed:
//                interactionController?.update(percent)
//            case .ended:
//                if abs(percent) > distanceThreshold || abs(gesture.velocity(in: gesture.view!).x) > flickThreshold {
//                    interactionController?.finish()
//                }else{
//                    interactionController?.pause()
//                    interactionController?.cancel()
//                }
//                interactionController = nil
//            case .cancelled:
//                interactionController?.cancel()
//                interactionController = nil
//            default:
//                break
//           }
//       }
//}
//
//
//extension MainFlowController: UIGestureRecognizerDelegate {
//    // prevent pan gesture from operating unless there is another child of the tab bar controller available on that side of the current child
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
//        print(panGesture.velocity(in: panGesture.view!))
//        let currentIndex = embeddedTabBarController.selectedIndex
//        return panGesture.velocity(in: panGesture.view!).x > 0 ? currentIndex > 0 : currentIndex < embeddedTabBarController.viewControllers!.count - 1
//    }
//    
//    func gesture() {
//        
//    }
//}
