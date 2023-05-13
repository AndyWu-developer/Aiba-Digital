
import UIKit

extension UIViewController {
    
    func transition(to child: UIViewController,animation: UIView.AnimationOptions = .transitionCrossDissolve ,completion: ((Bool) -> Void)? = nil) {
        let duration = 0.3
        let current = children.last
  
        if let existing = current {
            addChild(child)
            existing.willMove(toParent: nil)

            transition(from: existing, to: child, duration: duration, options: animation, animations: {
                child.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    child.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                    child.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                    child.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                    child.view.leftAnchor.constraint(equalTo: self.view.leftAnchor)
                ])
            }, completion: { done in
                child.didMove(toParent: self)
                existing.removeFromParent()
                completion?(done)
            })
            
        }else {
//            addChild(child)
//            view.addSubview(child.view)
//            UIView.animate(withDuration: duration, delay: 0, options: animation, animations: {
//                child.view.translatesAutoresizingMaskIntoConstraints = false
//                NSLayoutConstraint.activate([
//                    child.view.topAnchor.constraint(equalTo: self.view.topAnchor),
//                    child.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
//                    child.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//                    child.view.leftAnchor.constraint(equalTo: self.view.leftAnchor)
//                ])
//            }, completion: { done in
//                child.didMove(toParent: self)
//                completion?(done)
//            })
            
            addChild(child)
            view.addSubview(child.view)
            child.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                child.view.topAnchor.constraint(equalTo: view.topAnchor),
                child.view.rightAnchor.constraint(equalTo: view.rightAnchor),
                child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                child.view.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
            child.didMove(toParent: self)
        }
    }
}

