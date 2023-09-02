//
//  CreateSessionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 09.08.23.
//

import UIKit

class CreateSessionVC: UIViewController {
    
    static var didShowReminder = false

    private let onComplete: (SessionModel) -> Void
    private var model = SessionModel()
    private let tableView = UITableView()
    private var isPresented = false

    private var cells: [EditableTableViewCell] = []
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPresented = true
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
        if !CreateSessionVC.didShowReminder {
            let vc = UIAlertController(title: "Ты не забыл настроить сессию?", message: nil, preferredStyle: .alert)
            vc.view.tintColor = .black
            
            vc.addAction(.init(title: "Не забыл, продолжаем", style: .default, handler: { _ in
                self.onComplete(self.model)
            }))
            vc.addAction(.init(title: "Забыл, зараза", style: .cancel, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(vc, animated: true)
            
            CreateSessionVC.didShowReminder = true
            return
        }
        
        onComplete(model)
    }

    private func setupCells() {
        let totalCell = IntTableViewCell()
        totalCell.title = "Кол-во игроков"
        totalCell.id = SessionCellId.total.rawValue
        totalCell.content = "0"
        cells.append(totalCell)
        
        let mafCell = IntTableViewCell()
        mafCell.id = SessionCellId.maf.rawValue
        mafCell.title = "Кол-во мафиози"
        mafCell.content = "0"
        cells.append(mafCell)
        
        let mafBossCell = BoolTableViewCell()
        mafBossCell.title = "Босс мафии"
        mafBossCell.id = SessionCellId.boss.rawValue
        mafBossCell.isChecked = false
        cells.append(mafBossCell)
        
        let wolfCell = BoolTableViewCell()
        wolfCell.title = "Оборотень"
        wolfCell.id = SessionCellId.wolf.rawValue
        wolfCell.isChecked = false
        cells.append(wolfCell)
        
        let medCell = BoolTableViewCell()
        medCell.title = "Доктор"
        medCell.id = SessionCellId.medic.rawValue
        medCell.isChecked = false
        cells.append(medCell)
        
        let commissarCell = BoolTableViewCell()
        commissarCell.title = "Комиссар"
        commissarCell.id = SessionCellId.commissar.rawValue
        commissarCell.isChecked = false
        cells.append(commissarCell)
        
        let patrolCell = BoolTableViewCell()
        patrolCell.title = "Патрульный (замена комиссара)"
        patrolCell.id = SessionCellId.patrol.rawValue
        patrolCell.isChecked = false
        cells.append(patrolCell)
     
        let maniacCell = BoolTableViewCell()
        maniacCell.title = "Маньяк"
        maniacCell.id = SessionCellId.maniac.rawValue
        maniacCell.isChecked = false
        cells.append(maniacCell)
        
        let bloodhoundCell = BoolTableViewCell()
        bloodhoundCell.title = "Ищейка"
        bloodhoundCell.id = SessionCellId.bloodhound.rawValue
        bloodhoundCell.isChecked = false
        cells.append(bloodhoundCell)
        
        let loverCell = BoolTableViewCell()
        loverCell.title = "Любовница"
        loverCell.id = SessionCellId.lover.rawValue
        loverCell.isChecked = false
        cells.append(loverCell)
        
        // installing callback
        cells.forEach { cell in
            cell.onUpdate = { [weak self] roleCell in
                self?.didUpdateCell(roleCell)
            }
        }
    }
    
    private func cellBy(id: SessionCellId) -> EditableTableViewCell? {
        cells.first { cell in
            cell.id == id.rawValue
        }
    }
    
    private func didUpdateCell(_ cell: EditableTableViewCell) {
        guard let id = cell.id, let cellId = SessionCellId(rawValue: id) else { return }
        var isValid = false
        switch cellId {
        case .total:
            break
        case .maf:
            guard let cell = cell as? IntTableViewCell else { return }
            model.mafCount = cell.intValue ?? 0
        case .boss:
            guard let cell = cell as? BoolTableViewCell else { return }
            model.isBossExists = cell.isChecked
        case .wolf:
            guard let cell = cell as? BoolTableViewCell else { return }
            model.isWolfExists = cell.isChecked
        case .medic:
            guard let cell = cell as? BoolTableViewCell else { return }
            model.isMedicExists = cell.isChecked
        case .commissar:
            guard let cell = cell as? BoolTableViewCell else { return }
            model.isCommisarExists = cell.isChecked
        case .patrol:
            guard let cell = cell as? BoolTableViewCell else { return }
            model.isPatrolExists = cell.isChecked
        case .maniac:
            guard let cell = cell as? BoolTableViewCell else { return }
            model.isManiacExists = cell.isChecked
        case .bloodhound:
            guard let cell = cell as? BoolTableViewCell else { return }
            model.isBloodhoundExists = cell.isChecked
        case .lover:
            guard let cell = cell as? BoolTableViewCell else { return }
            model.isLoverExists = cell.isChecked
        }
        let totalCell = cellBy(id: .total) as! IntTableViewCell
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
