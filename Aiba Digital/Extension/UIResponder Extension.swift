

import UIKit

extension UIResponder {

    private struct Static {
        static weak var responder: UIResponder?
    }

    static func currentFirst() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(_trap), to: nil, from: nil, for: nil)
        return Static.responder
    }

    @objc private func _trap() {
        Static.responder = self
    }
    
    func next<T: UIResponder>(ofType: T.Type) -> T? {
        let r = self.next
        if let r = r as? T ?? r?.next(ofType: T.self){
            return r
        }else{
            return nil
        }
    }
    
}
