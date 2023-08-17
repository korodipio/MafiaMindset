import UIKit

extension UIViewController {
    
    static func instantiateFromStoryboard() -> Self? {
        let id = String(describing: self)
        let sb = UIStoryboard(name: id, bundle: nil)
        return sb.instantiateViewController(withIdentifier: id) as? Self
    }
    
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func add(_ child: UIViewController, to view: UIView) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        if parent == nil { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
