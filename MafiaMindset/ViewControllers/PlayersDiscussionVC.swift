//
//  PlayersDiscussionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 13.08.23.
//

import UIKit

class PlayersDiscussionVC: UIViewController {
    
    let canInitiateVote: Bool
    private let model: SessionModel
    private let dayModel: DayModel!
    private let onComplete: () -> Void
    private let timerView = TimerView()
    private var players: [Int] = []
    private var currentPlayerIndex = 0
    private var buttonVC: ButtonVC!
    
    private var lastNightLoverSelection: Int? {
        return model.isAlive(role: .lover) ? model.nights.last?.lover : nil
    }
    
    init(canInitiateVote: Bool, model: SessionModel, dayModel: DayModel? = nil, onComplete: @escaping () -> Void) {
        assert(!canInitiateVote || (canInitiateVote && dayModel != nil), "dayModel must be initiated if vote initiation is allowed")
        self.canInitiateVote = canInitiateVote
        self.model = model
        self.dayModel = canInitiateVote ? dayModel! : nil
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
            var v = v1.value
            if let lastNightLoverSelection {
                v.removeAll { ind in
                    ind == lastNightLoverSelection
                }
            }
            return v
        }.sorted().shifted(by: model.days.count)
        prepare()
        
        view.addSubview(timerView)
        timerView.constraintToParent()
        timerView.seconds = GlobalSettings.shared.playerDiscussionSeconds
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Далее"
        
        if let lastNightLoverSelection {
            let vc = UIAlertController(title: "Игрок \(lastNightLoverSelection + 1) не учавствует и не голосует из-за любовницы", message: nil, preferredStyle: .alert)
            vc.view.tintColor = .label
            vc.addAction(.init(title: "Ок", style: .cancel))
            present(vc, animated: true)
        }
    }
    
    @objc private func didTapDoneButton() {
        func next() {
            guard currentPlayerIndex < players.count - 1 else {
                onComplete()
                return
            }
            
            currentPlayerIndex += 1
            prepare()
        }
        
        if canInitiateVote {
            handle {
                next()
            }
        }
        else {
            next()
        }
    }
    
    private func prepare() {
        timerView.reset(seconds: GlobalSettings.shared.playerDiscussionSeconds)
        if canInitiateVote {
            title = "Выдвижение. Игрок \(self.players[self.currentPlayerIndex] + 1)"
        }
        else {
            title = "Обсуждение. Игрок \(self.players[self.currentPlayerIndex] + 1)"
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
        vc.view.tintColor = .label
        
        let players = kickablePlayers().sorted()
        guard !players.isEmpty else { complete(); return }
        
        players.forEach { ind in
            let action = UIAlertAction(title: "\(ind + 1)", style: .default) { _ in
                self.initVoteKick(by: self.players[self.currentPlayerIndex], to: ind)
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
