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
    private let settings = GlobalSettings.shared.copy()
    
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
        ], defaultVariantIndex: GlobalSettings.shared.discussionOrder == .globalDiscussionThenPlayer ? 0 : 1 , onComplete: { [weak self] variant in
            guard let order = DiscussionOrder(rawValue: variant.id) else { return }
            guard let self else { return }
            self.settings.discussionOrder = order
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
        globalDiscussionSecondsCell.onUpdate = { [weak globalDiscussionSecondsCell, weak self] _ in
            guard let globalDiscussionSecondsCell else { return }
            guard let self else { return }
            self.settings.globalDiscussionSeconds = TimeInterval(globalDiscussionSecondsCell.intValue ?? 2) * 60.0
        }
        globalDiscussionSecondsCell.maxValue = 5
        globalDiscussionSecondsCell.intValue = Int(settings.globalDiscussionSeconds) / 60
        cells.append(globalDiscussionSecondsCell)
     
        let playerDiscussionSecondsCell = IntTableViewCell()
        playerDiscussionSecondsCell.title = "Секунд дискуссии игрока"
        playerDiscussionSecondsCell.onUpdate = { [weak playerDiscussionSecondsCell, weak self] _ in
            guard let playerDiscussionSecondsCell else { return }
            guard let self else { return }
            self.settings.playerDiscussionSeconds = TimeInterval(playerDiscussionSecondsCell.intValue ?? 60)
        }
        playerDiscussionSecondsCell.maxValue = 120
        playerDiscussionSecondsCell.intValue = Int(settings.playerDiscussionSeconds)
        cells.append(playerDiscussionSecondsCell)

        let votedPlayerDiscussionSecondsCell = IntTableViewCell()
        votedPlayerDiscussionSecondsCell.title = "Секунд оправдания игрока"
        votedPlayerDiscussionSecondsCell.onUpdate = { [weak votedPlayerDiscussionSecondsCell, weak self] _ in
            guard let votedPlayerDiscussionSecondsCell else { return }
            guard let self else { return }
            self.settings.votedPlayerDiscussionSeconds = TimeInterval(votedPlayerDiscussionSecondsCell.intValue ?? 30)
        }
        votedPlayerDiscussionSecondsCell.maxValue = 120
        votedPlayerDiscussionSecondsCell.intValue = Int(settings.votedPlayerDiscussionSeconds)
        cells.append(votedPlayerDiscussionSecondsCell)
        
        let kickedPlayerDiscussionSecondsCell = IntTableViewCell()
        kickedPlayerDiscussionSecondsCell.title = "Секунд покидающего игрока"
        kickedPlayerDiscussionSecondsCell.onUpdate = { [weak kickedPlayerDiscussionSecondsCell, weak self] _ in
            guard let kickedPlayerDiscussionSecondsCell else { return }
            guard let self else { return }
            self.settings.kickedPlayerDiscussionSeconds = TimeInterval(kickedPlayerDiscussionSecondsCell.intValue ?? 30)
        }
        kickedPlayerDiscussionSecondsCell.maxValue = 120
        kickedPlayerDiscussionSecondsCell.intValue = Int(settings.kickedPlayerDiscussionSeconds)
        cells.append(kickedPlayerDiscussionSecondsCell)
        
        let unusedVotesCell = BoolTableViewCell()
        unusedVotesCell.title = "Сброс голосов в последнего"
        unusedVotesCell.helpDescription = "Если включено: Голоса не проголосовавших игроков идут в последнего выдвинутого игрока"
        unusedVotesCell.isChecked = settings.unusedVotesToLastPlayer
        unusedVotesCell.onUpdate = { [weak unusedVotesCell, weak self] _ in
            guard let unusedVotesCell else { return }
            guard let self else { return }
            self.settings.unusedVotesToLastPlayer = unusedVotesCell.isChecked
        }
        cells.append(unusedVotesCell)
        
        let disableVibrationCell = BoolTableViewCell()
        disableVibrationCell.title = "Отключить вибрацию"
        disableVibrationCell.helpDescription = "Если включено: Вибрация не будет использоваться приложением"
        disableVibrationCell.isChecked = settings.disableVibration
        disableVibrationCell.onUpdate = { [weak disableVibrationCell, weak self] _ in
            guard let disableVibrationCell else { return }
            guard let self else { return }
            self.settings.disableVibration = disableVibrationCell.isChecked
        }
        cells.append(disableVibrationCell)
    }
    
    private func didTapDoneButton() {
        settings.save()
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
