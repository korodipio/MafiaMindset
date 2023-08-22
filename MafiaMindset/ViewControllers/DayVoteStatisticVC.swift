//
//  DayVoteStatisticVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 18.08.23.
//

import UIKit

class DayVoteStatisticVC: UIViewController {

    private let model: SessionModel
    private let dayModel: DayModel
    private let tableView = UITableView()
    private var isPresented = false
    private var buttonVC: ButtonVC!
    
    private var lastNightLoverSelection: Int? {
        return model.isAlive(role: .lover) ? model.nights.last?.lover : nil
    }
    
    init(model: SessionModel, dayModel: DayModel) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPresented = true
    }

    private func setupUi() {
        title = "Статистика дня"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.constraintToParent()
        tableView.contentInset.bottom = 80
        tableView.insetsLayoutMarginsFromSafeArea = false
        tableView.preservesSuperviewLayoutMargins = false
        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: LabelTableViewCell.identifier)
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Вернуться"
    }

    @objc private func didTapDoneButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func availableVotesCount() -> Int {
        let alivePlayersCount = model.alivePlayersCount - (lastNightLoverSelection != nil ? 1 : 0)
        let votedPlayersCount = dayModel.votedPlayerCount
        let nonVotedPlayersCount = alivePlayersCount - votedPlayersCount
        return max(0, nonVotedPlayersCount)
    }
}

extension DayVoteStatisticVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        12
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = dayModel.votedPlayers.count
        return count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LabelTableViewCell.identifier, for: indexPath) as! LabelTableViewCell
        
        if !isPresented {
            cell.alpha = 0
            cell.transform = .init(translationX: 0, y: 20)
            let duration = 0.25
            UIView.animate(withDuration: duration, delay: duration * Double(indexPath.section) * 0.2, options: .curveEaseInOut) {
                cell.alpha = 1
                cell.transform = .identity
            }
        }
        
        if indexPath.section == tableView.numberOfSections - 1 {
            cell.title = "Не проголосовало: \(availableVotesCount())"
        }
        else {
            let votedPlayer = dayModel.votedPlayers[indexPath.section]
            cell.title = "Выдвинут: \(votedPlayer.to + 1) Игроком: \(votedPlayer.by + 1) Голосов: \(votedPlayer.voteCount)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

