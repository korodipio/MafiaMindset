//
//  DayVoteVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 13.08.23.
//

import UIKit
import LTMorphingLabel

class DayVoteVC: UIViewController {

    var revoting = false
    private let onComplete: () -> Void
    private let model: SessionModel
    private let dayModel: DayModel
    private var players: [DayVoteModel] = []
    private var currentPlayerIndex = 0
    private let titleLabel = UILabel()
    private let numberLabel = LTMorphingLabel()
    private var buttonVC: ButtonVC!
    
    private var lastNightLoverSelection: Int? {
        return model.isAlive(role: .lover) ? model.nights.last?.lover : nil
    }
    
    init(model: SessionModel, dayModel: DayModel, onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        self.model = model
        self.dayModel = dayModel
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
        title = revoting ? "Переголосование" : "Голосование"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        players = dayModel.votedPlayers
        currentPlayerIndex = 0
        
        titleLabel.text = "Об исключении игрока под номером"
        titleLabel.textAlignment = .center
        titleLabel.font = .rounded(ofSize: 20, weight: .regular)
        numberLabel.morphingEffect = .evaporate
        numberLabel.font = .rounded(ofSize: 60, weight: .bold)
        view.addSubview(titleLabel)
        view.addSubview(numberLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            numberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: numberLabel.topAnchor),
        ])
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Проголосовать"
        
        if let lastNightLoverSelection {
            let vc = UIAlertController(title: "Игрок \(lastNightLoverSelection + 1) не голосует", message: nil, preferredStyle: .alert)
            vc.view.tintColor = .black
            vc.addAction(.init(title: "Ok", style: .cancel))
            present(vc, animated: true)
        }
        
        prepare()
    }
    
    private func prepare() {
        numberLabel.text = "\(players[currentPlayerIndex].to + 1)"
    }
    
    private func handle(complete: @escaping () -> Void) {
        let vc = UIAlertController(title: "Исключение", message: nil, preferredStyle: .alert)
        vc.view.tintColor = .black

        var tf: UITextField!
        vc.addTextField { textField in
            tf = textField
            textField.placeholder = "Введи кол-во голосов от 0 до \(self.availableVotesCount())"
        }
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            guard let value = tf?.text, !value.isEmpty else { return }
            guard let intValue = Int(value), intValue >= 0 && intValue <= self.availableVotesCount() else { return }
            self.players[self.currentPlayerIndex].voteCount = intValue
            complete()
        }
        vc.addAction(okAction)
        vc.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(vc, animated: true)
    }
    
    private func availableVotesCount() -> Int {
        let alivePlayersCount = model.alivePlayersCount - (lastNightLoverSelection != nil ? 1 : 0)
        let votedPlayersCount = dayModel.votedPlayerCount
        let nonVotedPlayersCount = alivePlayersCount - votedPlayersCount
        return nonVotedPlayersCount
    }
    
    private func finishVote() {
//        let alivePlayersCount = model.alivePlayersCount
//        let votedPlayersCount = dayModel.votedPlayerCount
        let nonVotedPlayersCount = availableVotesCount()
        
        let sorted = players.sorted { v1, v2 in
            v1.voteCount > v2.voteCount
        }
        
        if sorted.count >= 2 {
            let f = sorted[0]
            let maxVotes = f.voteCount
            if maxVotes > nonVotedPlayersCount {
                
                let mostVotedPlayers = players.compactMap { voteModel -> DayVoteModel? in
                    guard voteModel.voteCount == maxVotes else { return nil }
                    voteModel.voteCount = 0
                    return voteModel
                }
                if mostVotedPlayers.count >= 2 {
                    dayModel.votedPlayers = mostVotedPlayers
                    let vc = DayVoteVC(model: model, dayModel: dayModel) { [weak self] () in
                        guard let self else { return }
                        self.onComplete()
                    }
                    vc.navigationItem.leftBarButtonItem = navigationItem.leftBarButtonItem
                    vc.revoting = true
                    navigationController?.pushViewController(vc, animated: true)
                    return
                }
            }
        }
        
        players.forEach { m in
            print(m.by, m.to, m.voteCount)
        }
        
        let maxVotes = sorted.first?.voteCount ?? 0
        var mostVotedPlayer = 0
        if nonVotedPlayersCount > maxVotes {
            mostVotedPlayer = players.last!.to
        }

        dayModel.nonVotedPlayersCount = nonVotedPlayersCount
        dayModel.kickedPlayers.append(mostVotedPlayer)
        model.kickedPlayers.insert(contentsOf: dayModel.kickedPlayers, at: 0)
        onComplete()
    }
    
    @objc private func didTapDoneButton() {
        handle {
            self.currentPlayerIndex += 1
            guard self.currentPlayerIndex < self.players.count else {
                self.finishVote()
                return
            }
            self.prepare()
        }
    }
}
