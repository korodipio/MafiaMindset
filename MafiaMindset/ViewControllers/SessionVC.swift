//
//  SessionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 18.08.23.
//

import UIKit

class SessionVC: UIViewController {

    private let continueSession: () -> Void
    private let model: SessionModel
    let sessionView = SessionView()
    
    init(model: SessionModel, continueSession: @escaping () -> Void) {
        self.model = model
        self.continueSession = continueSession
        super.init(nibName: nil, bundle: nil)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUi() {
        view.backgroundColor = .clear
        
        sessionView.model = model
        sessionView.continueSession = { [weak self] () in
            guard let self else { return }
            self.dismiss(animated: true) {
                self.continueSession()
            }
        }
        sessionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sessionView)
        
        NSLayoutConstraint.activate([
            sessionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            sessionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            sessionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(gestureHandler))
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func gestureHandler(gesture: UITapGestureRecognizer) {
        guard view.hitTest(gesture.location(in: view), with: nil) == view else { return }
        dismiss(animated: true)
    }
}
