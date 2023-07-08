//
//  MemberSignInViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/7/7.
//

import Foundation
import Combine

class MemberSignInViewModel {
 
    struct Input {
        let phoneNumber: AnySubscriber<String,Never>
        let verificationCode: AnySubscriber<String,Never>
        let sendSMS: AnySubscriber<Void,Never>
        let signIn: AnySubscriber<SignInMethod,Never>
        let debug: AnySubscriber<Void,Never>
    }
    
    struct Output {
        let countryCode: AnyPublisher<String, Never>
        let canSendSMS: AnyPublisher<Bool,Never>
        let canSignInWithPhone: AnyPublisher<Bool,Never>
        let signInSuccess: AnyPublisher<Void,Never>
        let sendSMSSuccess: AnyPublisher<Void,Never>
        let signInError: AnyPublisher<Error,Never>
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    enum SignInMethod{
        case phone
        case google
        case apple
    }
    
    private var subscriptions = Set<AnyCancellable>()
    private let signInRequestSubject = PassthroughSubject<SignInMethod,Never>()
    private let sendVerificationCodeRequestSubject = PassthroughSubject<Void,Never>()
    private var phoneNumberSubject = CurrentValueSubject<String,Never>("")
    private var verificationCodeSubject = CurrentValueSubject<String,Never>("")

    private let debug = PassthroughSubject<Void,Never>()
    private let accountManager: AccountManaging

    init(memberManager: AccountManaging){
        self.accountManager = memberManager
        configureInputs()
        configureOutputs()
    }
    
    deinit{
        print("MemberSignInViewModel deinit")
    }
 
    private func configureInputs(){
        
        debug.sink { [unowned self] _ in
            self.accountManager.debug()
        }.store(in: &subscriptions)
        
        input = Input(phoneNumber: phoneNumberSubject.eraseToAnySubscriber(),
                      verificationCode: verificationCodeSubject.eraseToAnySubscriber(),
                      sendSMS: sendVerificationCodeRequestSubject.eraseToAnySubscriber(),
                      signIn: signInRequestSubject.eraseToAnySubscriber(),
                      debug: debug.eraseToAnySubscriber())
    }
    
    private func configureOutputs(){
        
        let countryCodePublisher = UserDefaults.standard
            .publisher(for: \.countryCode)
            .replaceNil(with: "886")
            .compactMap{$0}
            .eraseToAnyPublisher()
        
        let canSendSMSPublisher = phoneNumberSubject
            .map{ (9...10).contains($0.count) }
            .eraseToAnyPublisher()
        
        let canSignInWithPhonePublisher = phoneNumberSubject
            .combineLatest(verificationCodeSubject)
            .map { !$0.0.isEmpty && !$0.1.isEmpty }
            .eraseToAnyPublisher()
        
        let successPublisher = PassthroughSubject<Void,Never>()
        let smsSuccessPublisher = PassthroughSubject<Void,Never>()
        let errorPublisher = PassthroughSubject<Error,Never>()
    
        sendVerificationCodeRequestSubject
            .flatMap(maxPublishers: .max(1)) { [unowned self] _ -> AnyPublisher<Result<Void,Error>, Never>in
                self.sendSMSFuture()
            }
            .sink { result in
                switch result{
                case .success:
                    smsSuccessPublisher.send(())
                case .failure(let error):
                    errorPublisher.send(error)
                }
            }
            .store(in: &subscriptions)
        
        signInRequestSubject
            .await { [unowned self] signInMethod -> Result<Member,Error> in
                switch signInMethod {
                case .phone:
                    let code = verificationCodeSubject.value
                    return await accountManager.signInWithPhone(verificationCode: code)
                case .google:
                    return await accountManager.signInWithGoogle()
                case .apple:
                    return await accountManager.signInWithApple()
                }
            }
            .sink { result in
                switch result{
                case .success(let member):
                    print(member)
                    successPublisher.send(())
                case .failure(let error):
                    errorPublisher.send(error)
                }
            }
            .store(in: &subscriptions)
        
        output = Output(countryCode: countryCodePublisher,
                        canSendSMS: canSendSMSPublisher,
                        canSignInWithPhone: canSignInWithPhonePublisher,
                        signInSuccess: successPublisher.eraseToAnyPublisher(),
                        sendSMSSuccess: smsSuccessPublisher.eraseToAnyPublisher(),
                        signInError: errorPublisher.eraseToAnyPublisher())
    }
    
    private func sendSMSFuture() -> AnyPublisher<Result<Void,Error>, Never> {
        Future{ promise in
            Task{
                do{
                    let phoneNumber = self.phoneNumberSubject.value
                    try await self.accountManager.sendSMS(phoneNumber: phoneNumber)
                    let result = Result<Void,Error>.success(())
                    promise(.success(result))
                }catch{
                    let result = Result<Void,Error>.failure(error)
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
}


//signInRequestSubject
//    .flatMap(maxPublishers: .max(1)) { [unowned self] signInMethod -> AnyPublisher<Result<Member,Error>, Never> in
//        switch signInMethod{
//        case .phone: return phoneSignInFuture()
//        case .google: return googleSignInFuture()
//        case .apple: return appleSignInFuture()
//        }
//    }
//    .sink { result in
//        switch result{
//        case .success(let member):
//            print("Sign In success")
//            print(member)
//            successPublisher.send(())
//        case .failure(let error):
//            errorPublisher.send(error)
//        }
//    }
//    .store(in: &subscriptions)

//private func phoneSignInFuture() -> AnyPublisher<Result<Member,Error>, Never> {
//    Future{ promise in
//        Task{
//            let code = self.verificationCodeSubject.value
//            let result = await self.accountManager.signInWithPhone(verificationCode: code)
//            promise(.success(result))
//        }
//    }
//    .eraseToAnyPublisher()
//}
//
//private func googleSignInFuture() -> AnyPublisher<Result<Member,Error>, Never> {
//    Future{ promise in
//        Task{
//            let result = await self.accountManager.signInWithGoogle()
//            promise(.success(result))
//        }
//    }
//    .eraseToAnyPublisher()
//}
//
//private func appleSignInFuture() -> AnyPublisher<Result<Member,Error>, Never> {
//    Future{ promise in
//        Task{
//            let result = await self.accountManager.signInWithApple()
//            promise(.success(result))
//        }
//    }
//    .eraseToAnyPublisher()
//}
