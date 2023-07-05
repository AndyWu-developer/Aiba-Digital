//
//import UIKit
//import Combine
//
//protocol UIBarItemWithPublisher : UIBarItem {}
//extension UIBarItem : UIBarItemWithPublisher {}
//
//extension UIBarItemWithPublisher {
//    func publisher() -> UIBarItemPublisher<Self> {
//        UIBarItemPublisher(control: self)
//    }
//}
//
//
//struct UIBarItemPublisher<T: UIBarItem> : Publisher {
//    typealias Output = T
//    typealias Failure = Never
//    unowned let control : T
//    init(control:T) {
//        self.control = control
//    }
//    func receive<S>(subscriber: S) where S : Subscriber, S.Input == Output, S.Failure == Failure {
//        subscriber.receive(subscription: Inner(downstream: subscriber, sender: control))
//    }
//    
//    class Inner <S:Subscriber>: NSObject, Subscription where S.Input == Output, S.Failure == Failure {
//        weak var sender : T?
//        var downstream : S?
//        init(downstream: S, sender : T) {
//            self.downstream = downstream
//            self.sender = sender
//            super.init()
//        }
//        
//        func request(_ demand: Subscribers.Demand) {
//            self.sender?.addTarget(self, action: #selector(doAction))
//        }
//        @objc func doAction(_ sender: UIGestureRecognizer) {
//            guard let sender = self.sender else {return}
//            _ = self.downstream?.receive(sender)
//        }
//        private func finish() {
//            self.sender?.removeTarget(self, action: #selector(doAction))
//            self.sender = nil
//            self.downstream = nil
//        }
//        func cancel() {
//            self.finish()
//        }
//        deinit {
//            self.finish()
//        }
//    }
//}
