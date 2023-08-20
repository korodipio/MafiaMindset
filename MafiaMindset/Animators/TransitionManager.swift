//
//  TransitionManager.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 20.08.23.
//

import UIKit

class TransitionManager: NSObject {
    enum AnimationDirection {
        case present
        case dismiss
        
        var next: AnimationDirection { return self == .present ? .dismiss : .present }
        var animationBlurViewAlpha: CGFloat { return self == .present ? 1 : 0 }
        var animationDimmingViewAlpha: CGFloat { return self == .present ? 0.4 : 0 }
    }
    var animationDirection: AnimationDirection = .present
    private(set) var animationDuration: TimeInterval = 0.6
    private let vibro = UIImpactFeedbackGenerator(style: .soft)
    
    convenience init(direction: AnimationDirection) {
        self.init()
        self.animationDirection = direction
    }
    
    private let animationBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let animationDimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
}

extension TransitionManager: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationDirection = .present
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationDirection = .dismiss
        return self
    }
}

extension TransitionManager: UIViewControllerAnimatedTransitioning {
    func animationAddDimmingView(to view: UIView) {
        view.addSubview(animationDimmingView)
        animationDimmingView.alpha = animationDirection.next.animationDimmingViewAlpha
        animationDimmingView.frame = view.bounds
    }
    
    func animationAddBlurView(to view: UIView) {
        view.addSubview(animationBlurView)
        animationBlurView.alpha = animationDirection.next.animationBlurViewAlpha
        animationBlurView.frame = view.bounds
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animationDuration
    }
    
    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        let containerView = ctx.containerView
        containerView.backgroundColor = .clear
        
        switch animationDirection {
        case .present:
            vibro.prepare()
            
            let toVC = ctx.viewController(forKey: .to)!
            let toView = ctx.view(forKey: .to)!
            
            toVC.navigationController?.navigationBar.prefersLargeTitles = false
            
            animationAddBlurView(to: containerView)
            animationAddDimmingView(to: containerView)
            containerView.addSubview(toView)

            toView.frame = ctx.finalFrame(for: toVC)
            toView.transform = .init(translationX: 0, y: toView.bounds.height / 2).scaledBy(x: 0.8, y: 0.8)
            toView.alpha = 0
            toView.layer.cornerRadius = 64
            
            toView.layer.shadowColor = UIColor.black.cgColor
            toView.layer.shadowOffset = .init(width: 0, height: -2)
            toView.layer.shadowOpacity = 0.3

            toView.layoutIfNeeded()
        
            vibro.impactOccurred()
            
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0) {
                toVC.navigationController?.navigationBar.prefersLargeTitles = true
                toView.transform = .identity
                toView.alpha = 1
                toView.layer.cornerRadius = UIScreen.main.displayCornerRadius
                self.animationBlurView.alpha = self.animationDirection.animationBlurViewAlpha
                self.animationDimmingView.alpha = self.animationDirection.animationDimmingViewAlpha
            } completion: { _ in
                toView.layer.cornerRadius = 0
                toView.layer.shadowOpacity = 0
                self.animationDimmingView.removeFromSuperview()
                self.animationBlurView.removeFromSuperview()
                ctx.completeTransition(!ctx.transitionWasCancelled)
            }
            
        case .dismiss:
            let toVC = ctx.viewController(forKey: .to)!
            
            let fromView = ctx.view(forKey: .from)!
            containerView.insertSubview(toVC.view, belowSubview: fromView)
            containerView.insertSubview(animationBlurView, belowSubview: fromView)
            containerView.insertSubview(animationDimmingView, belowSubview: fromView)
            animationDimmingView.frame = containerView.bounds
            animationBlurView.frame = containerView.bounds
            animationDimmingView.alpha = animationDirection.next.animationDimmingViewAlpha
            animationBlurView.alpha = animationDirection.next.animationBlurViewAlpha
            
            fromView.layer.shadowColor = UIColor.black.cgColor
            fromView.layer.shadowOffset = .init(width: 0, height: -2)
            fromView.layer.shadowOpacity = 0.3
            fromView.alpha = 1
            fromView.layer.cornerRadius = UIScreen.main.displayCornerRadius
            
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0) {
                fromView.transform = .init(translationX: 0, y: fromView.bounds.height / 2).scaledBy(x: 0.8, y: 0.8)
                fromView.layer.cornerRadius = 64
                fromView.alpha = 0
                self.animationBlurView.alpha = self.animationDirection.animationBlurViewAlpha
                self.animationDimmingView.alpha = self.animationDirection.animationDimmingViewAlpha
            } completion: { _ in
                fromView.layer.cornerRadius = 0
                fromView.layer.shadowOpacity = 0
                self.animationDimmingView.removeFromSuperview()
                self.animationBlurView.removeFromSuperview()
                ctx.completeTransition(!ctx.transitionWasCancelled)
            }
        }
    }
}

