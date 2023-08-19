//
//  DayVoteStatisticVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 18.08.23.
//

import UIKit

class DayVoteStatisticVC: UIViewController {

    private let onComplete: () -> Void
    private var label: UILabel?
    private let dayModel: DayModel
    private let tableView = UITableView()
    private var buttonVC: ButtonVC!
    
    init(dayModel: DayModel, onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
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
        title = "Статистика дня"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        let label = UILabel()
        view.addSubview(label)
        label.constraintToParent()
        label.font = .rounded(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label.withAlphaComponent(0.5)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = "Тут будет статистика когда кто то будет выдвинут"
        self.label = label
        
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
        onComplete()
        navigationController?.popViewController(animated: true)
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
        if count > 0 {
            label?.removeFromSuperview()
            label = nil
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LabelTableViewCell.identifier, for: indexPath) as! LabelTableViewCell
        
        let votedPlayer = dayModel.votedPlayers[indexPath.section]
        cell.title = "Выдвинут: \(votedPlayer.to + 1) Игроком: \(votedPlayer.by + 1) Голосов: \(votedPlayer.voteCount)"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

