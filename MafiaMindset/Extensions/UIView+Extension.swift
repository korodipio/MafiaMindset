import UIKit

extension UIView {
    class func fromNib() -> Self? {
        Bundle(for: self).loadNibNamed(String(describing: self), owner: nil, options: nil)?.first as? Self
    }
    
    func constraintToParent() {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor),
            self.topAnchor.constraint(equalTo: self.superview!.topAnchor),
            self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor)
        ])
    }
    func constraintToParent(with inset: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor, constant: inset),
            self.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: inset),
            self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor, constant: -inset),
            self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor, constant: -inset)
        ])
    }
    func constraintToParentMargin() {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: self.superview!.layoutMarginsGuide.leadingAnchor),
            self.topAnchor.constraint(equalTo: self.superview!.layoutMarginsGuide.topAnchor),
            self.trailingAnchor.constraint(equalTo: self.superview!.layoutMarginsGuide.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: self.superview!.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    func addMotionEffect(with relativeValues: CGPoint, axis: [UIInterpolatingMotionEffect.EffectType]) {
        axis.forEach { axis in
            let effect: UIInterpolatingMotionEffect = .init(keyPath: axis == .tiltAlongVerticalAxis ? "center.y" : "center.x", type: axis)
            effect.minimumRelativeValue = relativeValues.x
            effect.maximumRelativeValue = relativeValues.y
            self.addMotionEffect(effect)
        }
    }
    
    @discardableResult
    func addTapGesture(target: Any?, action: Selector?) -> UITapGestureRecognizer {
        let gesture = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(gesture)
        return gesture
    }
    
    var presentedVC: UIViewController? {
        self.window?.rootViewController?.presentedViewController ?? self.window?.rootViewController
    }
    
    var image: UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { c in
            self.layer.render(in: c.cgContext)
        }
    }
}
