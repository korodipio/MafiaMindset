//
//  RotatingView.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 10.09.23.
//

import UIKit

class RotatingView: UIView {
    
    enum State {
        case vis
        case hid
    }
    private(set) var state: State = .hid {
        didSet {
            didChangeState()
        }
    }
    
    var willStateChange: (() -> Void)?
    var onStateChange: ((State) -> Void)?
    let frontView = UIView()
    let backView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUi() {
        clipsToBounds = false
        frontView.clipsToBounds = false
        backView.clipsToBounds = false
        
        addSubview(backView)
        backView.constraintToParent()
        
        addSubview(frontView)
        frontView.constraintToParent()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(gestureHandler))
        addGestureRecognizer(gesture)
        
        state = .hid
    }
    
    func setState(state: State, animated: Bool) {
        guard state != self.state else { return }
        
        if animated {
            self.willStateChange?()
            
            let transitionDuration: TimeInterval = 0.5
            UIView.transition(with: self, duration: transitionDuration, options: [.transitionFlipFromLeft, .showHideTransitionViews], animations: {
                self.state = state
            }) { _ in
                self.onStateChange?(state)
            }
        }
        else {
            self.willStateChange?()
            self.state = state
            self.onStateChange?(state)
        }
    }
    
    private func didChangeState() {
        switch state {
        case .hid:
            self.backView.isHidden = true
            self.frontView.isHidden = false
        case .vis:
            self.backView.isHidden = false
            self.frontView.isHidden = true
        }
    }
    
    @objc private func gestureHandler(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            setState(state: state == .hid ? .vis : .hid, animated: true)
        default:
            break
        }
    }
}
