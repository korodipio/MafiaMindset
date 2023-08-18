//
//  GlobalDiscussionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 13.08.23.
//

import UIKit

class GlobalDiscussionVC: UIViewController {
    
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
        title = "День. Общее обсуждение"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        view.addSubview(timerView)
        timerView.constraintToParent()
        timerView.seconds = 60 * 3

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
