//
//  GlobalSettingsVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 27.08.23.
//

import UIKit

class GlobalSettingsVC: UIViewController {
    
    private let tableView = UITableView()
    private var isPresented = false
    private var cells: [EditableTableViewCell] = []
    private var buttonVC: ButtonVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPresented = true
    }
    
    private func setupUi() {
        title = "Настройки"
        view.backgroundColor = .secondarySystemBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.constraintToParent()
        tableView.contentInset.bottom = 80
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Применить"
        
        handleData()
    }
    
    private func handleData() {
        let discussionOrderCell = VariantsTableViewCell(variants: [
            .init(id: DiscussionOrder.globalDiscussionThenPlayer.rawValue, title: DiscussionOrder.globalDiscussionThenPlayer.title),
            .init(id: DiscussionOrder.playersDiscussionThenGlobal.rawValue, title: DiscussionOrder.playersDiscussionThenGlobal.title)
        ], defaultVariantIndex: GlobalSettings.shared.discussionOrder == .globalDiscussionThenPlayer ? 0 : 1 , onComplete: { variant in
            guard let order = DiscussionOrder(rawValue: variant.id) else { return }
            GlobalSettings.shared.discussionOrder = order
        })
        discussionOrderCell.title = "Порядок дискуссий"
        discussionOrderCell.helpDescription = """
            \n
            В какой порядке происходит дискуссия\n
            Общая дискуссия: Сперва общая, а потом каждого игрока\n
            Дискуссия игроков: Сперва каждого игрока, а потом общая\n
            """
        cells.append(discussionOrderCell)
        
        let globalDiscussionSecondsCell = IntTableViewCell()
        globalDiscussionSecondsCell.title = "Минут общей дискуссии"
        globalDiscussionSecondsCell.onUpdate = { [weak globalDiscussionSecondsCell] _ in
            guard let globalDiscussionSecondsCell else { return }
            GlobalSettings.shared.globalDiscussionSeconds = TimeInterval(globalDiscussionSecondsCell.intValue ?? 2) * 60.0
        }
        globalDiscussionSecondsCell.maxValue = 5
        globalDiscussionSecondsCell.intValue = Int(GlobalSettings.shared.globalDiscussionSeconds) / 60
        cells.append(globalDiscussionSecondsCell)
     
        let playerDiscussionSecondsCell = IntTableViewCell()
        playerDiscussionSecondsCell.title = "Секунд дискуссии игрока"
        playerDiscussionSecondsCell.onUpdate = { [weak playerDiscussionSecondsCell] _ in
            guard let playerDiscussionSecondsCell else { return }
            GlobalSettings.shared.playerDiscussionSeconds = TimeInterval(playerDiscussionSecondsCell.intValue ?? 60)
        }
        playerDiscussionSecondsCell.maxValue = 120
        playerDiscussionSecondsCell.intValue = Int(GlobalSettings.shared.playerDiscussionSeconds)
        cells.append(playerDiscussionSecondsCell)

        let votedPlayerDiscussionSecondsCell = IntTableViewCell()
        votedPlayerDiscussionSecondsCell.title = "Секунд оправдания игрока"
        votedPlayerDiscussionSecondsCell.onUpdate = { [weak votedPlayerDiscussionSecondsCell] _ in
            guard let votedPlayerDiscussionSecondsCell else { return }
            GlobalSettings.shared.votedPlayerDiscussionSeconds = TimeInterval(votedPlayerDiscussionSecondsCell.intValue ?? 30)
        }
        votedPlayerDiscussionSecondsCell.maxValue = 120
        votedPlayerDiscussionSecondsCell.intValue = Int(GlobalSettings.shared.votedPlayerDiscussionSeconds)
        cells.append(votedPlayerDiscussionSecondsCell)
        
        let unusedVotesCell = BoolTableViewCell()
        unusedVotesCell.title = "Сброс голосов в последнего"
        unusedVotesCell.helpDescription = "Если включено: Голоса не проголосовавших игроков идут в последнего выдвинутого игрока"
        unusedVotesCell.isChecked = GlobalSettings.shared.unusedVotesToLastPlayer
        unusedVotesCell.onUpdate = { [weak unusedVotesCell] _ in
            guard let unusedVotesCell else { return }
            GlobalSettings.shared.unusedVotesToLastPlayer = unusedVotesCell.isChecked
        }
        cells.append(unusedVotesCell)
        
        let disableVibrationCell = BoolTableViewCell()
        disableVibrationCell.title = "Отключить вибрацию"
        disableVibrationCell.helpDescription = "Если включено: Вибрация не будет использоваться приложением"
        disableVibrationCell.isChecked = GlobalSettings.shared.disableVibration
        disableVibrationCell.onUpdate = { [weak disableVibrationCell] _ in
            guard let disableVibrationCell else { return }
            GlobalSettings.shared.disableVibration = disableVibrationCell.isChecked
        }
        cells.append(disableVibrationCell)
    }
    
    private func didTapDoneButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension GlobalSettingsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        12
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        cells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cells[indexPath.section]
        
        if !isPresented {
            cell.alpha = 0
            cell.transform = .init(translationX: 0, y: 20)
            let duration = 0.25
            UIView.animate(withDuration: duration, delay: duration * Double(indexPath.section) * 0.2, options: .curveEaseInOut) {
                cell.alpha = 1
                cell.transform = .identity
            }
        }
        
        return cell
    }
}
