//
//  LoginFlowController.swift
//  Aiba Digital
//
//  Created by Andy on 2023/2/26.
//

import UIKit

protocol LoginFlowControllerDelegate: AnyObject {
    func userLoggedIn()
}

class LoginFlowController: UIViewController {
 
    weak var flowDelegate: LoginFlowControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }
    private let memberManager: AccountManaging
    
    init(memberManager: AccountManaging){
        self.memberManager = memberManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start(){
        let loginViewModel = MemberSignInViewModel(memberManager: memberManager)
        let loginVC = LoginViewController(viewModel: loginViewModel)
        loginVC.flowDelegate = self
        transition(to: loginVC, animation: .transitionCrossDissolve){ _ in
            loginVC.showAppearAnimation()
        }
    }
}

extension LoginFlowController: LoginViewControllerDelegate,UIPopoverPresentationControllerDelegate{
    
    func countrySelectionButtonTapped(_ signInVC: LoginViewController, button: UIView) {
        let countryPickerViewModel = CountryPickerViewModel()
        let countryPickerVC = CountryPickerViewController(viewModel: countryPickerViewModel)
        countryPickerVC.flowDelegate = self
        
        countryPickerVC.modalPresentationStyle = .popover
        countryPickerVC.popoverPresentationController!.delegate = self
        countryPickerVC.popoverPresentationController!.sourceView = view
        countryPickerVC.popoverPresentationController!.permittedArrowDirections =  UIPopoverArrowDirection(rawValue: 0)
        let x = view.bounds.midX - (view.bounds.width * 0.4)
        let y = button.convert(button.bounds, to: view).maxY
        let width = view.bounds.width * 0.8
        countryPickerVC.popoverPresentationController!.sourceRect = CGRect(x: x, y: y + 115 , width: width, height: 0)
        countryPickerVC.preferredContentSize = CGSize(width: width, height: 210)
        present(countryPickerVC, animated: true)
    }
  
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func loginDidSuccess(_ loginVC: LoginViewController) {
        flowDelegate?.userLoggedIn()
    }
    
}

extension LoginFlowController: CountryPickerViewControllerDelegate{
    func countrySelected(_ countryPickerVC: CountryPickerViewController) {
        countryPickerVC.dismiss(animated: false)
    }
}
