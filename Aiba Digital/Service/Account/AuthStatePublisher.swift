//
//  FirebaseAuthStatePublisher.swift
//  Aiba Digital
//
//  Created by Andy on 2023/2/25.
//

import Foundation
import Combine
import FirebaseAuth


struct AuthStateChangePublisher: Publisher{
    typealias Output = User?
    typealias Failure = Never
    
    func receive<S>(subscriber: S) where S:Subscriber, S.Input == Output, S.Failure == Failure {
        subscriber.receive(subscription: Inner(downstream: subscriber))
    }
    
    class Inner<S>: Subscription where S:Subscriber, S.Input == Output, S.Failure == Failure {
        private var downstream : S?
        var currentDemand = Subscribers.Demand.none
        var handle: AuthStateDidChangeListenerHandle?
        init(downstream:S) {
            self.downstream = downstream
            handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
                if let currentDemand = self?.currentDemand, currentDemand > 0, let newAdditionalDemand = self?.downstream?.receive(user){
                    self!.currentDemand -= 1
                    self!.currentDemand += newAdditionalDemand
                }
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            currentDemand += demand
        }
        
        func cancel() {
            downstream = nil
            if let handle = handle{
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }

}
