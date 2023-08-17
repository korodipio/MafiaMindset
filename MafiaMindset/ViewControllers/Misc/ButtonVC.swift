//
//  ButtonVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 14.08.23.
//

import UIKit

class ButtonVC: UIViewController {

    var isEnabled: Bool {
        get { button.isEnabled }
        set { button.isEnabled = newValue }
    }
    var inactiveTitleColor: UIColor? {
        get { button.titleColor(for: .disabled) }
        set { button.setTitleColor(newValue, for: .disabled) }
    }
    var buttonTitle: String? {
        get { button.title(for: .normal) }
        set { button.setTitle(newValue, for: .normal) }
    }
    private let gradientHeight: CGFloat = 75
    private let gradientLayer = CAGradientLayer()
    private let button = UIButton()
    private let didTap: () -> Void
    private var anim: UIViewPropertyAnimator?
    private var initialLocation: CGPoint?
    
    init(didTap: @escaping () -> Void) {
        self.didTap = didTap
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func loadView() {
        view = TouchTransparentVC()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        view.frame = parent!.view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = .init(origin: .init(x: 0, y: view.bounds.height - gradientHeight), size: .init(width: view.bounds.width, height: gradientHeight))
    }
    
    private func setupUi() {
        gradientLayer.colors = [UIColor.secondarySystemBackground.cgColor, UIColor.secondarySystemBackground.withAlphaComponent(0).cgColor]
        gradientLayer.startPoint = .init(x: 0, y: 1)
        gradientLayer.endPoint = .init(x: 0, y: 0)
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        
        button.titleLabel!.font = .rounded(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.primary?.cgColor
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.backgroundColor = .primary
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(gestureHandler))
        gesture.minimumPressDuration = 0
        button.addGestureRecognizer(gesture)
    }
    
    @objc private func gestureHandler(gesture: UILongPressGestureRecognizer) {
        let loc = gesture.location(in: nil)
        if initialLocation == nil {
            initialLocation = loc
        }
        var cancelGesture = false
        let delta: CGPoint = .init(x: abs(loc.x - initialLocation!.x), y: abs(loc.y - initialLocation!.y))
        if delta.y > 50 {
            cancelGesture = true
        }
        if (loc.x == 0 || loc.x == view.bounds.width) || (loc.y == 0 || loc.y == view.bounds.height) {
            cancelGesture = true
        }
        if cancelGesture {
            cancel(complete: false)
        }
        
        func cancel(complete: Bool) {
            if let anim {
                if complete {
                    anim.addCompletion { _ in
                        self.didTap()
                    }
                }
                if anim.isRunning {
                    anim.pauseAnimation()
                    anim.isReversed = true
                    anim.startAnimation()
                } else {
                    anim.addAnimations {
                        self.button.transform = .identity
                    }
                    anim.startAnimation()
                }
            }
            initialLocation = nil
            anim = nil
        }
        
        switch gesture.state {
        case .began:
            anim = UIViewPropertyAnimator(duration: 0.2, timingParameters: UISpringTimingParameters(dampingRatio: 0.7, initialVelocity: .zero))
            anim!.addAnimations {
                self.button.transform = .init(scaleX: 0.95, y: 0.95).translatedBy(x: 0, y: 5)
            }
            anim!.startAnimation()
            
        case .ended:
            cancel(complete: true)
            
        case .cancelled:
            cancel(complete: false)
            
        default:
            break
        }
    }
}
