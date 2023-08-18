//
//  CreateSessionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 09.08.23.
//

import UIKit

class CreateSessionVC: UIViewController {

    private let onComplete: (SessionModel) -> Void
    private var model = SessionModel()
    private let tableView = UITableView()
    
    private var cells: [RoleTableViewCell] = []
    private var buttonVC: ButtonVC!
    
    init(onComplete: @escaping (SessionModel) -> Void) {
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
        title = "Роли"
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
        tableView.insetsLayoutMarginsFromSafeArea = false
        tableView.preservesSuperviewLayoutMargins = false
        
        setupCells()
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Начать игру"
        buttonVC.inactiveTitleColor = .lightGray
        buttonVC.isEnabled = false
    }
    
    @objc private func didTapDoneButton() {
        onComplete(model)
    }

    private func setupCells() {
        let totalCell = IntRoleTableViewCell()
        totalCell.title = "Кол-во игроков"
        totalCell.id = SessionCellId.total
        totalCell.content = "0"
        cells.append(totalCell)
        
        let mafCell = IntRoleTableViewCell()
        mafCell.id = SessionCellId.maf
        mafCell.title = "Кол-во мафиози"
        mafCell.content = "0"
        cells.append(mafCell)
        
        let mafBossCell = BoolRoleTableViewCell()
        mafBossCell.title = "Босс мафии"
        mafBossCell.id = SessionCellId.boss
        mafBossCell.isChecked = false
        cells.append(mafBossCell)
        
        let wolfCell = BoolRoleTableViewCell()
        wolfCell.title = "Оборотень"
        wolfCell.id = SessionCellId.wolf
        wolfCell.isChecked = false
        cells.append(wolfCell)
        
        let medCell = BoolRoleTableViewCell()
        medCell.title = "Доктор"
        medCell.id = SessionCellId.medic
        medCell.isChecked = false
        cells.append(medCell)
        
        let commissarCell = BoolRoleTableViewCell()
        commissarCell.title = "Комиссар"
        commissarCell.id = SessionCellId.commissar
        commissarCell.isChecked = false
        cells.append(commissarCell)
        
        let patrolCell = BoolRoleTableViewCell()
        patrolCell.title = "Патрульный (замена комиссара)"
        patrolCell.id = SessionCellId.patrol
        patrolCell.isChecked = false
        cells.append(patrolCell)
     
        let maniacCell = BoolRoleTableViewCell()
        maniacCell.title = "Маньяк"
        maniacCell.id = SessionCellId.maniac
        maniacCell.isChecked = false
        cells.append(maniacCell)
        
        let bloodhoundCell = BoolRoleTableViewCell()
        bloodhoundCell.title = "Ищейка"
        bloodhoundCell.id = SessionCellId.bloodhound
        bloodhoundCell.isChecked = false
        cells.append(bloodhoundCell)
        
        // installing callback
        cells.forEach { cell in
            cell.onUpdate = { [weak self] roleCell in
                self?.didUpdateCell(roleCell)
            }
        }
    }
    
    private func cellBy(id: SessionCellId) -> RoleTableViewCell? {
        cells.first { cell in
            cell.id == id
        }
    }
    
    private func didUpdateCell(_ cell: RoleTableViewCell) {
        guard let id = cell.id else { return }
        var isValid = false
        switch id {
        case .total:
            break
        case .maf:
            guard let cell = cell as? IntRoleTableViewCell else { return }
            model.mafCount = cell.intValue ?? 0
        case .boss:
            guard let cell = cell as? BoolRoleTableViewCell else { return }
            model.isBossExists = cell.isChecked
        case .wolf:
            guard let cell = cell as? BoolRoleTableViewCell else { return }
            model.isWolfExists = cell.isChecked
        case .medic:
            guard let cell = cell as? BoolRoleTableViewCell else { return }
            model.isMedicExists = cell.isChecked
        case .commissar:
            guard let cell = cell as? BoolRoleTableViewCell else { return }
            model.isCommisarExists = cell.isChecked
        case .patrol:
            guard let cell = cell as? BoolRoleTableViewCell else { return }
            model.isPatrolExists = cell.isChecked
        case .maniac:
            guard let cell = cell as? BoolRoleTableViewCell else { return }
            model.isManiacExists = cell.isChecked
        case .bloodhound:
            guard let cell = cell as? BoolRoleTableViewCell else { return }
            model.isBloodhoundExists = cell.isChecked
        }
        let totalCell = cellBy(id: .total) as! IntRoleTableViewCell
        let totalCount = totalCell.intValue ?? 0
        let negativeCount = model.mafCount + model.wolfCount + model.bossCount
        if totalCount - negativeCount > negativeCount && totalCount >= model.activeCount {
            isValid = true
            model.civCount = totalCount - model.activeCount
        }
        totalCell.isError = !isValid
        
        buttonVC.isEnabled = isValid
    }
}

extension CreateSessionVC: UITableViewDelegate, UITableViewDataSource {
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
        cells[indexPath.section]
    }
}
