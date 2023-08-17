//
//  PlayersDiscussionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 13.08.23.
//

import UIKit

class PlayersDiscussionVC: UIViewController {
    
    private let model: SessionModel
    private let dayModel: DayModel
    private let onComplete: () -> Void
    private let timerView = TimerView()
    private var players: [Int] = []
    private var currentPlayerIndex = 0
    private var buttonVC: ButtonVC!
    
    init(model: SessionModel, dayModel: DayModel, onComplete: @escaping () -> Void) {
        self.model = model
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
        
        players = model.aliveRolePlayers.flatMap { v1 in
            v1.value
        }.sorted().shifted(by: model.days.count)
        title = "Выдвижение. Игрок \((players.first ?? 0) + 1)"
        
        view.addSubview(timerView)
        timerView.constraintToParent()
        timerView.seconds = 60
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Далее"
    }
    
    @objc private func didTapDoneButton() {
        handle {
            guard self.currentPlayerIndex < self.players.count - 1 else {
                self.onComplete()
                return
            }
            
            self.currentPlayerIndex += 1
            self.timerView.reset(seconds: 60)
            self.title = "Выдвижение. Игрок \(self.players[self.currentPlayerIndex] + 1)"
        }
    }
    
    private func kickablePlayers() -> [Int] {
        var r = players
        r.remove(at: currentPlayerIndex)
        r = r.compactMap { ind in
            return self.dayModel.votedPlayers.contains(where: { model in
                model.to == ind
            }) ? nil : ind
        }
        return r
    }

    private func handle(complete: @escaping () -> Void) {
        let vc = UIAlertController(title: "Выдвижение", message: "Выбери игрока", preferredStyle: .alert)
        vc.view.tintColor = .black
        
        let players = kickablePlayers().sorted()
        guard !players.isEmpty else { complete(); return }
        
        players.forEach { ind in
            let action = UIAlertAction(title: "\(ind + 1)", style: .default) { _ in
                self.initVoteKick(by: self.currentPlayerIndex, to: ind)
                complete()
            }
            vc.addAction(action)
        }
        let ignoreAction = UIAlertAction(title: "Никого не выдвигает", style: .default) { _ in
            complete()
        }
        vc.addAction(ignoreAction)
        vc.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(vc, animated: true)
    }
    
    private func initVoteKick(by: Int, to: Int) {
        let d = DayVoteModel()
        d.by = by
        d.to = to
        dayModel.votedPlayers.append(d)
    }
}
