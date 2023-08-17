//
//  VotedPlayersDiscussionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 13.08.23.
//

import UIKit

class VotedPlayersDiscussionVC: UIViewController {

    private let onComplete: () -> Void
    private let dayModel: DayModel
    private let timerView = TimerView()
    private var currentPlayerIndex = 0
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
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        view.addSubview(timerView)
        timerView.constraintToParent()
        timerView.seconds = 60
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Далее"
        
        prepare()
    }
    
    private func prepare() {
        title = "Оправдание \((dayModel.votedPlayers.first?.to ?? 0) + 1)"
    }
    
    @objc private func didTapDoneButton() {
        currentPlayerIndex += 1
        guard currentPlayerIndex < dayModel.votedPlayers.count else {
            onComplete()
            return
        }
        
        timerView.reset(seconds: 60)
        title = "Оправдание \(dayModel.votedPlayers[currentPlayerIndex].to + 1)"
    }
}
