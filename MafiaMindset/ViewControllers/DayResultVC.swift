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
        buttonVC.buttonTitle = "Ok"
        
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
        dayModel.numberOfVote.sorted(by: { v1, v2 in
            v1.key < v2.key
        }).forEach { (ind: Int, count: Int) in
            output.append("За исключение \(ind + 1): \(count)")
        }
        output.append("Воздержалось: \(dayModel.nonVotedPlayersCount)")
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
        
        cell.title = output[indexPath.section]
        
        return cell
    }
}
