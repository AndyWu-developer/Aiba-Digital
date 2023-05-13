

import UIKit
import Combine

protocol ControlWithPublisher : UIControl {}
extension UIControl : ControlWithPublisher {}

extension ControlWithPublisher {
    func publisher(for event: UIControl.Event = .primaryActionTriggered) -> UIControlPublisher<Self> {
        UIControlPublisher(control: self, for: event)
    }
}

protocol GestureWithPublisher : UIGestureRecognizer {}
extension UIGestureRecognizer : GestureWithPublisher {}

extension GestureWithPublisher {
    func publisher() -> UIGestureRecognizerPublisher<Self> {
        UIGestureRecognizerPublisher(control: self)
    }
}

struct UIControlPublisher<T:UIControl> : Publisher {
    typealias Output = T
    typealias Failure = Never
    unowned let control : T
    let event : UIControl.Event
    init(control:T, for event:UIControl.Event = .primaryActionTriggered) {
        self.control = control
        self.event = event
    }
    func receive<S>(subscriber: S) where S : Subscriber, S.Input == Output, S.Failure == Failure {
        subscriber.receive(subscription: Inner(downstream: subscriber, sender: control, event: event))
    }
    class Inner <S:Subscriber>: NSObject, Subscription where S.Input == Output, S.Failure == Failure {
        weak var sender : T?
        let event : UIControl.Event
        var downstream : S?
        init(downstream: S, sender : T, event : UIControl.Event) {
            self.downstream = downstream
            self.sender = sender
            self.event = event
            super.init()
        }
        func request(_ demand: Subscribers.Demand) {
            self.sender?.addTarget(self, action: #selector(doAction), for: event)
        }
        @objc func doAction(_ sender:UIControl) {
            guard let sender = self.sender else {return}
            _ = self.downstream?.receive(sender)
        }
        private func finish() {
            self.sender?.removeTarget(self, action: #selector(doAction), for: event)
            self.sender = nil
            self.downstream = nil
        }
        func cancel() {
            self.finish()
        }
        deinit {
            self.finish()
        }
    }
}

struct UIGestureRecognizerPublisher<T: UIGestureRecognizer> : Publisher {
    typealias Output = T
    typealias Failure = Never
    unowned let control : T
    init(control:T) {
        self.control = control
    }
    func receive<S>(subscriber: S) where S : Subscriber, S.Input == Output, S.Failure == Failure {
        subscriber.receive(subscription: Inner(downstream: subscriber, sender: control))
    }
    class Inner <S:Subscriber>: NSObject, Subscription where S.Input == Output, S.Failure == Failure {
        weak var sender : T?
        var downstream : S?
        init(downstream: S, sender : T) {
            self.downstream = downstream
            self.sender = sender
            super.init()
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.sender?.addTarget(self, action: #selector(doAction))
        }
        @objc func doAction(_ sender: UIGestureRecognizer) {
            guard let sender = self.sender else {return}
            _ = self.downstream?.receive(sender)
        }
        private func finish() {
            self.sender?.removeTarget(self, action: #selector(doAction))
            self.sender = nil
            self.downstream = nil
        }
        func cancel() {
            self.finish()
        }
        deinit {
            self.finish()
        }
    }
}
