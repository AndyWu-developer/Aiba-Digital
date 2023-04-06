//
//  FlowController.swift
//  Elba Digital
//
//  Created by Andy on 2023/2/12.
//

import UIKit

class AppDependency: HasAuthManager & HasPostManager{
    let authManager: AuthManaging
    let postManager: PostManaging
    //static let shared: AppDependency = AppDependency()
    
    init(){
        authManager = AuthManager()
        postManager = PostManager()
    }

    deinit{
        print("AppDependency deinit")
    }
}

class AppFlowController: UIViewController {
    
    let appDependency = AppDependency()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLaunchFlow()
    }
    
    private func startLaunchFlow(){
        let launchVC = LaunchViewController()
        launchVC.delegate = self
        transition(to: launchVC)
    }
    
    private func startLoginFlow() {
        let loginFlowController = LoginFlowController(dependencies: appDependency)
        loginFlowController.flowDelegate = self
        transition(to: loginFlowController){ [unowned self] _ in
            setNeedsStatusBarAppearanceUpdate()
        }
        loginFlowController.start()
    }
    
    private func startMainFlow(){
        let mainFlowController = MainFlowController(dependencies: appDependency)
        mainFlowController.flowDelegate = self
        transition(to: mainFlowController){ [unowned self] _ in
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}


extension AppFlowController: LaunchViewControllerDelegate{
    func launchAnimationDidFinish() {
        if appDependency.authManager.isUserLoggedIn() {
            startMainFlow()
        }else{
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

