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
        players.forEach { voteModel in
            voteModel.voteCount = 0
        }
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
            vc.view.tintColor = .label
            vc.addAction(.init(title: "Ок", style: .cancel))
            present(vc, animated: true)
        }
        
        prepare()
    }
    
    private func prepare() {
        numberLabel.text = "\(players[currentPlayerIndex].to + 1)"
    }
    
    private func handle(complete: @escaping () -> Void) {
        let vc = UIAlertController(title: "Исключение", message: nil, preferredStyle: .alert)
        vc.view.tintColor = .label
        
        var textField: UITextField!
        vc.addTextField { tf in
            textField = tf
            tf.placeholder = "Введи кол-во голосов от 0 до \(self.availableVotesCount())"
            tf.keyboardType = .numberPad
        }
        let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
            guard let value = textField?.text, !value.isEmpty else { return }
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
    
    private func pushViewController(_ vc: UIViewController) {
        // Inherit left bar button
        vc.navigationItem.leftBarButtonItem = navigationItem.leftBarButtonItem
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func initiateRevoting() {
        let vc = VotedPlayersDiscussionVC(dayModel: dayModel) { [weak self] () in
            guard let self else { return }
            
            let vc = DayVoteVC(model: self.model, dayModel: self.dayModel) { [weak self] () in
                guard let self else { return }
                self.onComplete()
            }
            vc.revoting = true
            pushViewController(vc)
        }
        pushViewController(vc)
    }
    
    private func finishVote() {
        let nonVotedPlayersCount = availableVotesCount()
        
        if GlobalSettings.shared.unusedVotesToLastPlayer {
            players.last?.voteCount += nonVotedPlayersCount
        }
        
        dayModel.nonVotedPlayersCount = nonVotedPlayersCount
        
        let sorted = players.sorted { v1, v2 in
            v1.voteCount > v2.voteCount
        }
        
        if sorted.count >= 2 {
            let f = sorted[0]
            let maxVotes = f.voteCount
            let mostVotedPlayers = players.compactMap { voteModel -> DayVoteModel? in
                guard voteModel.voteCount == maxVotes else { return nil }
                return voteModel
            }
            if mostVotedPlayers.count >= 2 {
                let pl = mostVotedPlayers.compactMap { voteModel in
                    "\(voteModel.to + 1)"
                }.joined(separator: ", ")
                let vc = UIAlertController(title: "Что будем делать?", message: "Переголосование: " + pl, preferredStyle: .alert)
                vc.view.tintColor = .label
                
                let continueAction = UIAlertAction(title: "Переголосование", style: .default) { _ in
                    self.dayModel.votedPlayers = mostVotedPlayers
                    self.initiateRevoting()
                }
                let cancelAction = UIAlertAction(title: "Продолжаем без исключения", style: .default) { _ in
                    self.onComplete()
                }
                vc.addAction(continueAction)
                vc.addAction(cancelAction)
                
                present(vc, animated: true)
                return
            }
        }
        
        dayModel.kickedPlayers.append(sorted.first!.to)
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
