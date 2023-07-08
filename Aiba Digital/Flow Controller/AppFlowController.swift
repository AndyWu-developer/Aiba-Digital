//
//  FlowController.swift
//  Elba Digital
//
//  Created by Andy on 2023/2/12.
//

import UIKit
//
//class AppDependency {
//    let authManager: MemberManaging
//    let postManager: PostManaging
//
//    //static let shared: AppDependency = AppDependency()
//
//    init(){
//        authManager = MemberManager()
//        postManager = PostManager()
//    }
//
//    deinit{
//        print("AppDependency deinit")
//    }
//}

class AppFlowController: UIViewController {
    
    //let appDependency = AppDependency()
    let memberManager = AccountManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        showLaunchScreen()
    }
    
    private func showLaunchScreen(){
        let launchVC = LaunchViewController()
        launchVC.delegate = self
        transition(to: launchVC)
    }
    
    private func startLoginFlow() {
        
        let loginFlowController = LoginFlowController(memberManager: memberManager)
        loginFlowController.flowDelegate = self
        transition(to: loginFlowController){ [unowned self] _ in
            setNeedsStatusBarAppearanceUpdate()
        }

    }
    
    private func startMainFlow(){
        let mainFlowController = MainFlowController()
        mainFlowController.flowDelegate = self
        transition(to: mainFlowController){ [unowned self] _ in
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}


extension AppFlowController: LaunchViewControllerDelegate{
    func launchAnimationDidFinish() {
        if let member = memberManager.currentMember {
            print("會員 \(member.id) 已登入")
            startLoginFlow()
        }else{
            print("尚未登入")
            startLoginFlow()
        }
    }
}


extension AppFlowController: LoginFlowControllerDelegate{
    func userLoggedIn() {
        startMainFlow()
    }
}

extension AppFlowController: MainFlowControllerDelegate{
    func userLoggedOut(){
        startLoginFlow()
    }
}

