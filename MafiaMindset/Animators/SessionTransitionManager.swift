//
//  SessionTransitionManager.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 18.08.23.
//

import UIKit

class SessionTransitionManager: NSObject {
    enum AnimationDirection {
        case present
        case dismiss
        
        var next: AnimationDirection { return self == .present ? .dismiss : .present }
        var animationBlurViewAlpha: CGFloat { return self == .present ? 0.8 : 0 }
        var animationDimmingViewAlpha: CGFloat { return self == .present ? 0.5 : 0 }
    }
    
    private var animationDirection: AnimationDirection = .present
    private(set) var animationDuration: TimeInterval = 0.6
    private weak var placeholderView: SessionView!
    weak var presentingFromVC: UIViewController?
    
    private let animationBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let animationDimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
}

extension SessionTransitionManager: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationDirection = .present
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationDirection = .dismiss
        return self
    }
}

extension SessionTransitionManager: UIViewControllerAnimatedTransitioning {
    private func animationAddDimmingView(to view: UIView) {
        view.addSubview(animationDimmingView)
        animationDimmingView.alpha = animationDirection.next.animationDimmingViewAlpha
        animationDimmingView.frame = view.bounds
    }
    
    private func animationAddBlurView(to view: UIView) {
        view.addSubview(animationBlurView)
        animationBlurView.alpha = animationDirection.next.animationBlurViewAlpha
        animationBlurView.frame = view.bounds
    }
    
    private func createPlaceholder(from view: SessionView) -> SessionView {
        let placeholder = SessionView()
        placeholder.model = view.model
        placeholder.type = view.type
        return placeholder
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animationDuration
    }
    
    func animateTransition(using ctx: UIViewControllerContextTransitioning) {

        let containerView = ctx.containerView

        switch animationDirection {
        case .present:
            let fromVC = presentingFromVC as! RootVC
            let fromCell = fromVC.selectedViewCell()!
            
            let toVC = ctx.viewController(forKey: .to) as! SessionVC
            let toView = ctx.view(forKey: .to)!

            toVC.sessionView.model = fromCell.model
            toVC.sessionView.type = .full
            toVC.sessionView.isHidden = true
            
            let placeholderView = createPlaceholder(from: fromCell.sessionView)
            self.placeholderView = placeholderView

            animationAddDimmingView(to: containerView)
            animationAddBlurView(to: containerView)
            containerView.addSubview(toView)
            toView.frame = ctx.finalFrame(for: toVC)
            toView.alpha = 0
            toView.layoutIfNeeded()
            
            fromCell.sessionView.isHidden = true
            containerView.addSubview(placeholderView)
            placeholderView.translatesAutoresizingMaskIntoConstraints = true
            placeholderView.frame = fromCell.sessionView.convert(fromCell.sessionView.bounds, to: nil)
            placeholderView.layoutIfNeeded()
            
            let finalFrameForGoalView = toVC.sessionView.convert(toVC.sessionView.bounds, to: nil)

            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {

                placeholderView.type = toVC.sessionView.type
                placeholderView.frame = finalFrameForGoalView
                placeholderView.layoutIfNeeded()

                self.animationDimmingView.alpha = self.animationDirection.animationDimmingViewAlpha
                self.animationBlurView.alpha = self.animationDirection.animationBlurViewAlpha

                toView.alpha = 1
                toView.transform = .identity
                
            } completion: { _ in

                toVC.sessionView.setNeedsLayout()
                toVC.sessionView.isHidden = false
                placeholderView.isHidden = true
                ctx.completeTransition(true)

            }

        case .dismiss:
            let fromVC = ctx.viewController(forKey: .from) as! SessionVC
            let fromView = ctx.view(forKey: .from)!
            
            let toVC = presentingFromVC as! RootVC
            let toCell = toVC.selectedViewCell()!

            placeholderView.isHidden = false
            fromVC.sessionView.isHidden = true
            
            placeholderView.frame = fromVC.sessionView.convert(fromVC.sessionView.bounds, to: nil)
            placeholderView.layoutIfNeeded()
            
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
                
                self.placeholderView.type = toCell.sessionView.type
                self.placeholderView.frame = toCell.sessionView.convert(toCell.sessionView.bounds, to: nil)
                self.placeholderView.setNeedsLayout()
                self.placeholderView.layoutIfNeeded()
                
                self.animationDimmingView.alpha = self.animationDirection.animationDimmingViewAlpha
                self.animationBlurView.alpha = self.animationDirection.animationBlurViewAlpha

                fromView.alpha = 0

            } completion: { _ in
                
                fromVC.sessionView.isHidden = false
                toCell.sessionView.isHidden = false
                self.placeholderView.removeFromSuperview()
                self.placeholderView = nil
                self.animationDimmingView.removeFromSuperview()
                self.animationBlurView.removeFromSuperview()
                ctx.completeTransition(true)
            }
        }
    }
}

