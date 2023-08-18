//
//  LastDiscussionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 18.08.23.
//

import UIKit

class LastDiscussionVC: UIViewController {
    
    private let onComplete: () -> Void
    private let dayModel: DayModel
    private let timerView = TimerView()
    private var buttonVC: ButtonVC!
    
    init(dayModel: DayModel, onComplete: @escaping () -> Void) {
        self.dayModel = dayModel
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
        let t = dayModel.kickedPlayers.compactMap { ind in
            "\(ind + 1)"
        }.joined(separator: ", ")
        title = "День. Последнее слово " + t
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        view.addSubview(timerView)
        timerView.constraintToParent()
        timerView.seconds = 60
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
