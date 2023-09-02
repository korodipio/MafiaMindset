//
//  WinnerVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 13.08.23.
//

import UIKit
import LTMorphingLabel
import Lottie

class WinnerVC: UIViewController {

    private let onComplete: () -> Void
    private let winner: SessionRoleId
    private let titleLabel = LTMorphingLabel()
    private let roleLabel = LTMorphingLabel()
    private var buttonVC: ButtonVC!
    private var lottieView: LottieAnimationView!
    
    init(winner: SessionRoleId, onComplete: @escaping () -> Void) {
        self.winner = winner
        self.onComplete = onComplete
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lottieView.play { [weak self] _ in
            self?.didCompleteLottie()
        }
    }
    
    private func didCompleteLottie() {
        UIView.animate(withDuration: 0.3) {
            self.titleLabel.text = "Победитель"
            self.roleLabel.text = self.winner.title
            self.view.layoutIfNeeded()
        }
    }

    private func setupUi() {
        title = "Финал"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        titleLabel.textAlignment = .center
        titleLabel.morphingEffect = .evaporate
        titleLabel.font = .rounded(ofSize: 20, weight: .regular)
        roleLabel.morphingEffect = .evaporate
        roleLabel.font = .rounded(ofSize: 60, weight: .bold)
        view.addSubview(titleLabel)
        view.addSubview(roleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            roleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: roleLabel.topAnchor),
        ])
        
        lottieView = .init(name: "lottie_win.json", configuration: .init(renderingEngine: .specific(.coreAnimation)))
        lottieView.animationSpeed = 1.2
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.contentMode = .scaleAspectFill
        view.addSubview(lottieView)
        NSLayoutConstraint.activate([
            lottieView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
            lottieView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lottieView.widthAnchor.constraint(equalToConstant: 200),
            lottieView.heightAnchor.constraint(equalToConstant: 200),
        ])
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Завершить игру"
    }
    
    @objc private func didTapDoneButton() {
        onComplete()
    }
}
