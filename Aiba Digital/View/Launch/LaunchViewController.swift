

import UIKit

protocol LaunchViewControllerDelegate: AnyObject {
    func launchAnimationDidFinish()
}

class LaunchViewController: UIViewController, LogoAnimationDelegate {
    
    @IBOutlet weak var logo: LogoView!
    weak var delegate: LaunchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.delegate = self
        logo.startAnimation()
    }
    
    func LogoAnimationDidFinish() {
        self.delegate?.launchAnimationDidFinish()
    }
}
