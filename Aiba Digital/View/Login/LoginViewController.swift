
import UIKit
import Combine

protocol LoginViewControllerDelegate : AnyObject {
    func countrySelectionButtonTapped(_ signInVC: LoginViewController, button: UIView)
    func loginDidSuccess(_ loginVC: LoginViewController)
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var debugButton: UIButton!
    @IBOutlet weak var logo: LogoView!
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phoneNumberField: PhoneNumberField!
    @IBOutlet weak var verificationCodeField: VerificationCodeField!
    @IBOutlet weak var phoneSignInButton: SignInButton!
    @IBOutlet weak var googleSignInButton: SignInButton!
    @IBOutlet weak var appleSignInButton: SignInButton!
    
    private let viewModel: MemberSignInViewModel
    weak var flowDelegate: LoginViewControllerDelegate?
    
    private var subscriptions = Set<AnyCancellable>()
    private var pressedButtton: SignInButton?
  
    init(viewModel: MemberSignInViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelInput()
        bindViewModelOutput()
        setupNavigationFlow()
        configureButton()
        configureTextField()
        configureScrollView()
    }
    
    private func bindViewModelInput(){
        
        phoneNumberField.publisher(for: .editingChanged)
            .compactMap{ $0.text! }
            .prepend(phoneNumberField.text!)
            .bind(to: viewModel.input.phoneNumber)
            .store(in: &subscriptions)

        verificationCodeField.publisher(for: .editingChanged)
            .compactMap{ $0.text! }
            .prepend(verificationCodeField.text!)
            .bind(to: viewModel.input.verificationCode)
            .store(in: &subscriptions)

        verificationCodeField.sendButton.publisher(for: .touchUpInside)
            .map{_ in}
            .subscribe(viewModel.input.sendSMS)
        
       debugButton.publisher(for: .touchUpInside)
            .map{_ in}
            .subscribe(viewModel.input.debug)

        phoneSignInButton.publisher(for: .touchUpInside)
            .flatMap{ phoneButton in
                Future<Void,Never>{ promise in
                    phoneButton.startLoadingAnimation{ promise(.success(())) }
                }
            }
            .map{ MemberSignInViewModel.SignInMethod.phone }
            .bind(to: viewModel.input.signIn)
            .store(in: &subscriptions)

        appleSignInButton.publisher(for: .touchUpInside)
            .flatMap{ appleButton in
                Future<Void,Never>{ promise in
                    appleButton.startLoadingAnimation{ promise(.success(()))}
                }
            }
            .map{ MemberSignInViewModel.SignInMethod.apple }
            .bind(to: viewModel.input.signIn)
            .store(in: &subscriptions)
        
        googleSignInButton.publisher(for: .touchUpInside)
            .flatMap{ googleButton in
                Future<Void,Never>{ promise in
                    googleButton.startLoadingAnimation{ promise(.success(()))}
                }
            }
            .map{ MemberSignInViewModel.SignInMethod.google }
            .bind(to: viewModel.input.signIn)
            .store(in: &subscriptions)
    }
   
    private func bindViewModelOutput(){
        
        viewModel.output.countryCode
            .receive(on: DispatchQueue.main)
            .assign(to: \.countryCode, on: phoneNumberField)
            .store(in: &subscriptions)

        viewModel.output.canSendSMS
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: verificationCodeField.sendButton)
            .store(in: &subscriptions)
        
//        viewModel.output.sendSMSButtonText
//            .receive(on: DispatchQueue.main)
//            .sink { [unowned self] in
//                verificationCodeField.sendButton.setTitle($0, for: .normal)
//            }.store(in: &subscriptions)
        
        viewModel.output.canSignInWithPhone
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: phoneSignInButton)
            .store(in: &subscriptions)

//        viewModel.output.signInErrorMessage
//            .receive(on: DispatchQueue.main)
//            .sink(){ [unowned self] in
//                showMessageAlert($0)
//            }.store(in: &subscriptions)
//
//        viewModel.output.signInSuccess
//            .receive(on: DispatchQueue.main)
//            .sink { [unowned self] success in
//                if success {
//                    pressedButtton?.startSuccessAnimation{
//                        flowDelegate?.loginDidSuccess(self)
//                    }
//                }else{
//                    pressedButtton?.stopAnimating()
//                    view.isUserInteractionEnabled = true
//                }
//            }.store(in: &subscriptions)
    }
    
    private func setupNavigationFlow(){
        phoneNumberField.countrySelectionButton.publisher(for: .touchUpInside)
            .sink { [unowned self]_ in
                flowDelegate?.countrySelectionButtonTapped(self,button : phoneNumberField.countrySelectionButton)
            }.store(in: &subscriptions)
    }
    
    private func configureTextField() {
        let tapToDismissGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapToDismissGesture)
        
        phoneNumberField.publisher(for: .editingDidEndOnExit)
            .sink { [unowned self] _ in
                verificationCodeField.becomeFirstResponder()
            }.store(in: &subscriptions)
        
        verificationCodeField.publisher(for: .editingDidEndOnExit)
            .sink { [unowned self] _ in
                verificationCodeField.resignFirstResponder()
            }.store(in: &subscriptions)
    }
    
    private func configureButton(){
        phoneSignInButton.publisher()
            .merge(with: appleSignInButton.publisher(),googleSignInButton.publisher())
            .sink { [unowned self] button in
                pressedButtton = button
                view.isUserInteractionEnabled = false
                view.endEditing(true)
            }.store(in: &subscriptions)
    }
    
    private func configureScrollView() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .sink { [unowned self] in
                let keyboard = $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect

                if keyboard.origin.y < UIScreen.main.bounds.height {  //show
                    scrollView.contentInset.bottom = keyboard.size.height
                    var viewRect = view.frame
                    viewRect.size.height -= keyboard.size.height
                    let signInButtonRect = scrollView.convert(phoneSignInButton.bounds.insetBy(dx: 0, dy: -10), from: phoneSignInButton)
                    if !viewRect.contains(signInButtonRect){
                        scrollView.scrollRectToVisible(signInButtonRect, animated: true)
                    }
                }else{
                    scrollView.contentInset.bottom = 0
                }
            }.store(in: &subscriptions)
    }
    
    private func showMessageAlert(_ message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .cancel))
        present(alert, animated: true)
    }

    func showAppearAnimation(){
        signInView.isUserInteractionEnabled = false
        logo.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.midY * 0.35)
        signInView.alpha = 0
        var options = UIView.KeyframeAnimationOptions.calculationModeLinear
        let options2 = UIView.AnimationOptions.curveEaseIn
        options.insert(UIView.KeyframeAnimationOptions(rawValue: options2.rawValue))
        UIView.animateKeyframes(withDuration: 0.75, delay: 0.3,options: options) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3) {
                self.logo.transform = CGAffineTransform.identity
            }
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 2/3) {
                self.signInView.alpha = 1
            }
        } completion: { _ in
            self.signInView.isUserInteractionEnabled = true
        }
    }
    
    deinit{
        print("SignInViewController deinit")
    }
}
