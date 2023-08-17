//
//  FirstDayVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 11.08.23.
//

import UIKit

class FirstDayVC: UIViewController {
    
    private let onComplete: () -> Void
    private let timerView = TimerView()
    private var buttonVC: ButtonVC!
    
    init(onComplete: @escaping () -> Void) {
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
    
    private func setupUi() {
        title = "Утро. Обсуждение"
        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(timerView)
        timerView.constraintToParent()
        timerView.seconds = 60 * 3
        timerView.onComplete = { [weak self] () in
            guard let self else { return }
            self.onComplete()
        }
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapSkipButton()
        })
        buttonVC.buttonTitle = "Пропустить"
        add(buttonVC)
    }
    
    @objc private func didTapSkipButton() {
        timerView.pause()
        onComplete()
    }
    
}
