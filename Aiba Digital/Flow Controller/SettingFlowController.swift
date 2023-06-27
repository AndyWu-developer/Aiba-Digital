//
//  SettingsViewController.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/15.
//

import UIKit

protocol SettingFlowControllerDelegate: AnyObject {
    func userLoggedOut()
}

class SettingFlowController: UIViewController {

    typealias Dependencies = HasAuthManager
    private let dependencies: Dependencies
    weak var flowDelegate: SettingFlowControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    
    init(dependencies: Dependencies){
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func start(){
        let settingViewModel = SettingViewModel(dependencies: dependencies)
        let settingVC = SettingViewController(viewModel: settingViewModel)
        settingVC.flowDelegate = self
        transition(to: settingVC)
    }
}

extension SettingFlowController: SettingViewControllerDelegate{
    func userLoggedOut(_ sender: SettingViewController) {
        flowDelegate?.userLoggedOut()
    }
}
