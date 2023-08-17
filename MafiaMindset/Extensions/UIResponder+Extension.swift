import UIKit

extension UIResponder {
    var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
