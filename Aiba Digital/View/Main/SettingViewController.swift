//
//  SettingViewController.swift
//  Aiba Digital
//
//  Created by Andy on 2023/2/27.
//

import UIKit
import Combine

protocol SettingViewControllerDelegate: AnyObject {
    func userLoggedOut(_ sender: SettingViewController)
}

class SettingViewController: UIViewController {

    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: SettingViewModel
    weak var flowDelegate: SettingViewControllerDelegate?
    
    init(viewModel: SettingViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelInput()
        bindViewModelOutput()
    }

    private func bindViewModelInput(){
        signOutButton.publisher(for: .touchUpInside)
            .map{ _ in }
            .subscribe(viewModel.input.signOut)
    }
    
    private func bindViewModelOutput(){
        viewModel.output.signOutSuccess.sink { [unowned self]_ in
            flowDelegate?.userLoggedOut(self)
        }.store(in: &subscriptions)
        
        viewModel.output.welcomeMessage.sink { [unowned self] in
            welcomeLabel.text = $0
        }.store(in: &subscriptions)
    }
    
    
}
