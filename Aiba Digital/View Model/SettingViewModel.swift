//
//  SettingViewModel.swift
//  Aiba Digital
//
//  Created by Andy on 2023/2/27.
//

import Foundation
import Combine
import FirebaseAuth
/*
 the ViewModel should depend on the abstract protocol for the service, only the coordinator which is responsible for setting up dependencies knows about the concrete implementation.
*/

class SettingViewModel {
 
    struct Input {
        let signOut: AnySubscriber<Void,Never>
    }
    
    struct Output {
        let signOutSuccess: AnyPublisher<Void,Never>
        let welcomeMessage: AnyPublisher<String,Never>
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    private let signOutSubject = PassthroughSubject<Void,Never>()

    private var subscriptions = Set<AnyCancellable>()
    
    typealias Dependencies = HasAuthManager
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies){
        self.dependencies = dependencies
        configureInputs()
        configureOutputs()
    }
    
    private func configureInputs(){
        input = Input(signOut: signOutSubject.eraseToAnySubscriber())
    }
    
    private func configureOutputs(){
        
        let welcomeMessagePublisher = CurrentValueSubject<String,Never>(Auth.auth().currentUser!.email ?? Auth.auth().currentUser!.phoneNumber ?? "unkown user")
        
        let signOutSuccess = signOutSubject.flatMap { [unowned self] _ in
                dependencies.authManager.signOut()
                .catch { (error) -> Empty in
                    print("haha")
                   // errorMessagePublisher.send(error.errorDescription)
                    return Empty(completeImmediately: false)
                }
            }

        output = Output(signOutSuccess: signOutSuccess.eraseToAnyPublisher(),
                        welcomeMessage: welcomeMessagePublisher.eraseToAnyPublisher())
    }
    
    deinit{
        print("SettingViewModel deinit")
    }
}



