//
//  GlobalDiscussionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 13.08.23.
//

import UIKit

class GlobalDiscussionVC: UIViewController {
    
    private let onComplete: () -> Void
    private let model: SessionModel
    private let timerView = TimerView()
    private var buttonVC: ButtonVC!
    
    private var lastNightLoverSelection: Int? {
        return model.isAlive(role: .lover) ? model.nights.last?.lover : nil
    }
    
    init(model: SessionModel, onComplete: @escaping () -> Void) {
        self.model = model
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
        timerView.seconds = GlobalSettings.shared.globalDiscussionSeconds

        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapSkipButton()
        })
        buttonVC.buttonTitle = "Пропустить"
        add(buttonVC)
        
        if let lastNightLoverSelection {
            let vc = UIAlertController(title: "Игрок \(lastNightLoverSelection + 1) не учавствует и не голосует из-за любовницы", message: nil, preferredStyle: .alert)
            vc.view.tintColor = .label
            vc.addAction(.init(title: "Ок", style: .cancel))
            present(vc, animated: true)
        }
    }
    
    @objc private func didTapSkipButton() {
        timerView.pause()
        onComplete()
    }
}
