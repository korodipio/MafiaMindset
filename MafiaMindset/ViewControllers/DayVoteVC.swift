//
//  DayVoteVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 13.08.23.
//

import UIKit
import LTMorphingLabel

class DayVoteVC: UIViewController {

    private let onComplete: () -> Void
    private let model: SessionModel
    private let dayModel: DayModel
    private var players: [DayVoteModel] = []
    private var currentPlayerIndex = 0
    private let titleLabel = UILabel()
    private let numberLabel = LTMorphingLabel()
    private var buttonVC: ButtonVC!
    
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
        title = "Голосование"
        view.backgroundColor = .secondarySystemBackground
        
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
            self.dayModel.numberOfVote[self.players[self.currentPlayerIndex].to] = intValue
            complete()
        }
        vc.addAction(okAction)
        vc.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(vc, animated: true)
    }
    
    private func availableVotesCount() -> Int {
        let alivePlayersCount = model.alivePlayersCount
        let votedPlayersCount = dayModel.votedPlayerCount
        let nonVotedPlayersCount = alivePlayersCount - votedPlayersCount
        return nonVotedPlayersCount
    }
    
    private func finishVote() {
        let alivePlayersCount = model.alivePlayersCount
        let votedPlayersCount = dayModel.votedPlayerCount
        let nonVotedPlayersCount = alivePlayersCount - votedPlayersCount
        
        var maxVotes = 0
        var mostVotedPlayer = 0
        dayModel.numberOfVote.forEach { v1 in
            if v1.value > maxVotes {
                mostVotedPlayer = v1.key
                maxVotes = v1.value
            }
        }
        if nonVotedPlayersCount > maxVotes {
            mostVotedPlayer = players.last!.to
        }
        
        dayModel.nonVotedPlayersCount = nonVotedPlayersCount
        dayModel.kickedPlayers.append(mostVotedPlayer)
        model.kickedPlayers.insert(contentsOf: dayModel.kickedPlayers, at: 0)
    }
    
    @objc private func didTapDoneButton() {
        handle {
            self.currentPlayerIndex += 1
            guard self.currentPlayerIndex < self.players.count else {
                self.finishVote()
                self.onComplete()
                return
            }
            self.prepare()
        }
    }
}
