//
//  SignInViewModel.swift
//  Aiba Digital
//
//  Created by Andy on 2023/2/16.
//

import Foundation
import Combine
/*
 the ViewModel should depend on the abstract protocol for the service, only the coordinator which is responsible for setting up dependencies knows about the concrete implementation.
*/
protocol HasAuthManager{
    var authManager: AuthManaging { get }
}

class SignInViewModel {
 
    struct Input {
        let phoneNumber: AnySubscriber<String,Never>
        let verificationCode: AnySubscriber<String,Never>
        let sendSMS: AnySubscriber<Void,Never>
        let phoneSignIn: AnySubscriber<Void,Never>
        let googleSignIn: AnySubscriber<Void,Never>
        let appleSignIn: AnySubscriber<Void,Never>
    }
    
    struct Output {
        let countryCode: AnyPublisher<String, Never>
        let sendSMSEnable: AnyPublisher<Bool,Never>
        let sendSMSButtonText: AnyPublisher<String,Never>
        let phoneSignInEnable: AnyPublisher<Bool,Never>
        let signInSuccess: AnyPublisher<Bool,Never>
        let signInErrorMessage: AnyPublisher<String,Never>
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    private let countryCodeSubject = CurrentValueSubject<String,Never>("")
    private let phoneNumberSubject = CurrentValueSubject<String,Never>("")
    private let verificationCodeSubject = CurrentValueSubject<String,Never>("")
    private let signInSuccessSubject = PassthroughSubject<Bool,Never>()
    private let errorMessagePublisher = PassthroughSubject<String,Never>()
    private let buttonTextPublisher = CurrentValueSubject<String,Never>("發送驗證碼")
    private var subscriptions = Set<AnyCancellable>()
    lazy var sendSMSEnablepublisher = phoneNumberSubject
        .map { (9...10).contains($0.count) }
    private let dependencies: HasAuthManager
  
    private var limit = 3
    //a publisher produced by .flatMap has its .finished completion "swallowed" so that it doesn't pass downstream. This makes sense because it's not the job of the produced publisher to termination the operation of the pipeline by finishing. — On the other hand, if a produced publisher throws an error, the pipeline does terminate.
    init(dependencies: HasAuthManager){
        self.dependencies = dependencies
        configureInputs()
        configureOutputs()
    }
    //User can send SMS
    //1.
    //2.
    
    private func handleSignInResult(_ result: Result<Bool,AuthError>){
        switch result {
        case .success :
            signInSuccessSubject.send(true)
        case .failure(let error):
            if error != .userCanceledSignIn {
                errorMessagePublisher.send(error.localizedDescription)
            }
            signInSuccessSubject.send(false)
        }
    }
    private let sendSMSSuccessSubject = PassthroughSubject<Bool,Never>()
    
    private func handleResult(_ result: Result<Bool,AuthError>){
        switch result {
        case .failure(let error):
            sendSMSSuccessSubject.send(false)
            errorMessagePublisher.send(error.localizedDescription)
            signInSuccessSubject.send(false)
        default: break
        }
    }
    
    private func configureInputs(){
      
        let sendVerificationCodeSubject = PassthroughSubject<Void,Never>()
        let phoneSignInSubject = PassthroughSubject<Void,Never>()
        let googleSigninSubject = PassthroughSubject<Void,Never>()
        let appleSigninSubject = PassthroughSubject<Void,Never>()
        
        sendVerificationCodeSubject
            .flatMap{ [unowned self] _ in
                dependencies.authManager.sendVerificationCode(phoneNumber: countryCodeSubject.value + phoneNumberSubject.value)
                    .map { Result<Bool,AuthError>.success($0) }
                    .catch { Just(Result<Bool,AuthError>.failure($0))}
            }
            .sink{ [unowned self] in
                handleResult($0)
            }.store(in: &subscriptions)
        
        sendSMSSuccessSubject.flatMap { [unowned self] _ in
                startCountDownTimer(30)
            }.sink{ [unowned self] remainSeconds in
                if remainSeconds > 0 {
                    buttonTextPublisher.send("重新發送\(remainSeconds)")
                }else{
                    buttonTextPublisher.send("發送驗證碼")
                }
            }.store(in: &subscriptions)
            
        phoneSignInSubject
            .flatMap { [unowned self] _ in
                dependencies.authManager.signInWithPhone(verificationCode: verificationCodeSubject.value)
                    .map { Result<Bool,AuthError>.success($0) }
                    .catch { Just(Result<Bool,AuthError>.failure($0))}
            }
            .sink{ [unowned self] in
                handleSignInResult($0)
            }.store(in: &subscriptions)
        
        googleSigninSubject
            .flatMap { [dependencies] _ in
                dependencies.authManager.signInWithGoogle()
                    .map { Result<Bool,AuthError>.success($0) }
                    .catch { Just(Result<Bool,AuthError>.failure($0))}
            }
            .sink{ [unowned self] in
                handleSignInResult($0)
            }.store(in: &subscriptions)
        
        appleSigninSubject
            .flatMap { [unowned self] _ in
                dependencies.authManager.signInWithApple()
                    .map { Result<Bool,AuthError>.success($0) }
                    .catch { Just(Result<Bool,AuthError>.failure($0))}
            }
            .sink{ [unowned self] in
                handleSignInResult($0)
            }.store(in: &subscriptions)
        
        let correctPhoneFormat = phoneNumberSubject.map{ (9...10).contains($0.count) }.eraseToAnyPublisher()
        let quota = CurrentValueSubject<Int,Never>(3)
        
//        let canLogin = correctPhoneFormat
//                        .combineLatest(quotaNotExceeded,correctPhoneFormat)
//                        .map { $0.0 && $0.1 && $0.2 }
        
        
        input = Input(phoneNumber: phoneNumberSubject.eraseToAnySubscriber(),
                      verificationCode: verificationCodeSubject.eraseToAnySubscriber(),
                      sendSMS: sendVerificationCodeSubject.eraseToAnySubscriber(),
                      phoneSignIn: phoneSignInSubject.eraseToAnySubscriber(),
                      googleSignIn: googleSigninSubject.eraseToAnySubscriber(),
                      appleSignIn: appleSigninSubject.eraseToAnySubscriber())
    }
    
    private func configureOutputs(){
        
        UserDefaults.standard.publisher(for: \.countryCode)
            .replaceNil(with: "886")
            .compactMap{$0}
            .sink { [unowned self] code in
                countryCodeSubject.send(code)
            }.store(in: &subscriptions)
      
       
        let loginEnablePublisher = phoneNumberSubject
            .combineLatest(verificationCodeSubject)
            .map { !$0.0.isEmpty && !$0.1.isEmpty }
       
        output = Output(countryCode: countryCodeSubject.eraseToAnyPublisher(),
                        sendSMSEnable: sendSMSEnablepublisher.eraseToAnyPublisher(),
                        sendSMSButtonText: buttonTextPublisher.eraseToAnyPublisher(),
                        phoneSignInEnable: loginEnablePublisher.eraseToAnyPublisher(),
                        signInSuccess: signInSuccessSubject.eraseToAnyPublisher(),
                        signInErrorMessage: errorMessagePublisher.eraseToAnyPublisher())
    }
    
    
    private func startCountDownTimer(_ totalTime: Int) -> AnyPublisher<Int,Never> {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .scan(totalTime) { count, _ in count - 1 }
            .prefix(totalTime)
            .eraseToAnyPublisher()
    }
    
    
    deinit{
        print("SignInViewModel deinit")
    }
}
