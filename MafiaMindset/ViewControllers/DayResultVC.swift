//
//  DayResultVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 14.08.23.
//

import UIKit

class DayResultVC: UIViewController {
    
    private let onComplete: () -> Void
    private let dayModel: DayModel
    private let tableView = UITableView()
    private var isPresented = false
    private var output: [String] = []
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPresented = true
    }

    private func setupUi() {
        title = "День. Результаты"
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
        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: LabelTableViewCell.identifier)
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Ок"
        
        handleData()
    }
    
    private func handleData() {
        if !dayModel.kickedPlayers.isEmpty {
            var t: [String] = []
            dayModel.kickedPlayers.forEach { ind in
                t.append("\(ind + 1)")
            }
            output.append((t.count == 1 ? "Исключен: " : "Исключены: ") + t.joined(separator: ", "))
        }
        else {
            output.append("Никто не исключен")
            return
        }
        dayModel.votedPlayers.forEach { v1 in
            output.append("За исключение \(v1.to + 1): \(v1.voteCount)")
        }
        if GlobalSettings.shared.unusedVotesToLastPlayer {
            output.append("Воздержались и отправились\nв последнего: \(dayModel.nonVotedPlayersCount)")
        }
        else {
            output.append("Пропустили голосование: \(dayModel.nonVotedPlayersCount)")
        }
    }
    
    @objc private func didTapDoneButton() {
        onComplete()
    }
}

extension DayResultVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        12
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        output.count
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
        
        cell.title = output[indexPath.section]
        
        return cell
    }
}
