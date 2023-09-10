//
//  CardAssignmentVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 10.08.23.
//

import UIKit
import LTMorphingLabel

class CardAssignmentVC: UIViewController {
    
    private let onComplete: (SessionModel) -> Void
    private let model: SessionModel
    private let selectedRolesModel: SessionModel?
    private var currentPlayerIndex: Int = 0 {
        didSet {
            prepare(forPlayerWith: currentPlayerIndex)
        }
    }
    private let titleLabel = UILabel()
    private let numberLabel = LTMorphingLabel()
    private var buttonVC: ButtonVC!
    
    init(model: SessionModel, onComplete: @escaping (SessionModel) -> Void) {
        self.onComplete = onComplete
        self.model = model
        self.selectedRolesModel = model.copy()
        self.currentPlayerIndex = 0
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
        title = "Раздача карт"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        titleLabel.text = "Игрок под номером"
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
            self?.didTapAssignButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Задать роль"
        
        currentPlayerIndex = Int.random(in: 0..<model.totalCount)
    }
    
    private func prepare(forPlayerWith index: Int) {
        numberLabel.text = "\(index + 1)"
    }
    
    private func availableRoles() -> [SessionRoleId: Int] {
        guard let model = selectedRolesModel else { return [:] }
        
        var roles: [SessionRoleId: Int] = [:]
        
        if model.isMafExists {
            roles[.maf] = model.mafCount
        }
        if model.isBossExists {
            roles[.boss] = model.bossCount
        }
        if model.isWolfExists {
            roles[.wolf] = model.wolfCount
        }
        if model.isMedicExists {
            roles[.medic] = model.medicCount
        }
        if model.isCommisarExists {
            roles[.commissar] = model.commissarCount
        }
        if model.isPatrolExists {
            roles[.patrol] = model.patrolCount
        }
        if model.isManiacExists {
            roles[.maniac] = model.maniacCount
        }
        if model.isBloodhoundExists {
            roles[.bloodhound] = model.bloodhoundCount
        }
        if model.isCivExists {
            roles[.civ] = model.civCount
        }
        if model.isLoverExists {
            roles[.lover] = model.loverCount
        }
        
        return roles
    }
    
    private func showConfirmation(player: Int, role: SessionRoleId, _ confirmed: @escaping () -> Void) {
        let vc = UIAlertController(title: "Игрок \(player + 1) - \(role.title)", message: "Подтверди свой выбор", preferredStyle: .alert)
        vc.view.tintColor = .label
        
        let roleAction = UIAlertAction(title: "Подтверждаю", style: .default) { _ in
            confirmed()
        }
        vc.addAction(roleAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        vc.addAction(cancelAction)
        
        present(vc, animated: true)
    }
    
    private func presentAlert(title: String?, message: String?, _ buttons: [UIAlertAction]) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.view.tintColor = .label
        buttons.forEach { button in
            vc.addAction(button)
        }
        present(vc, animated: true)
    }
    
    @objc private func didTapAssignButton() {
        func cardSelection() {
            let cardSelectionVC = CardSelectionVC(roles: availableRoles().flatMap { (role: SessionRoleId, count: Int) in
                return Array(repeating: role, count: count)
            }.shuffled())  { [weak self] role in
                guard let self else { return }
                assignRoleToPlayer(with: currentPlayerIndex, role: role)
            }
            navigationController?.pushViewController(cardSelectionVC, animated: true)
        }
        func cardAssignment() {
            var buttons = availableRoles().sorted { v1, v2 in
                v1.key.title < v2.key.title
            }.compactMap { (role: SessionRoleId, count: Int) in
                let roleAction = UIAlertAction(title: "\(role.title) - \(count)", style: .default) { _ in
                    self.showConfirmation(player: self.currentPlayerIndex, role: role) {
                        self.assignRoleToPlayer(with: self.currentPlayerIndex, role: role)
                    }
                }
                return roleAction
            }
            buttons.append(UIAlertAction(title: "Отмена", style: .cancel))
            presentAlert(title: "Выбери нужную роль", message: nil, buttons)
        }
        
        switch GlobalSettings.shared.roleSelectionType {
        case .playerSelection:
            cardSelection()
        case .masterSelection:
            cardAssignment()
        case .ask:
            presentAlert(title: "Позволить игроку выбрать или задать роль?", message: nil, [
                .init(title: "Игрок выберет карту", style: .default, handler: { _ in
                    cardSelection()
                }),
                .init(title: "Задать роль", style: .default, handler: { _ in
                    cardAssignment()
                })
            ])
        }
    }
    
    // Decreases role count and returns total count of roles
    private func decreaseRoleCount(_ role: SessionRoleId) -> Int {
        guard let model = selectedRolesModel else { return 0 }
        
        switch role {
        case .civ:
            model.civCount -= 1
        case .maf:
            model.mafCount -= 1
        case .wolf:
            model.wolfCount -= 1
        case .boss:
            model.bossCount -= 1
        case .medic:
            model.medicCount -= 1
        case .commissar:
            model.commissarCount -= 1
        case .patrol:
            model.patrolCount -= 1
        case .maniac:
            model.maniacCount -= 1
        case .bloodhound:
            model.bloodhoundCount -= 1
        case .lover:
            model.loverCount -= 1
        }
        
        return model.totalCount
    }
    
    private func finishAssignment() {
        onComplete(model)
    }
    
    private func assignRoleToPlayer(with index: Int, role: SessionRoleId) {
        model.players[index] = role
        let rolesCount = decreaseRoleCount(role)
        if rolesCount == 0 {
            finishAssignment()
        }
        else {
            currentPlayerIndex = (currentPlayerIndex + 1) % model.totalCount
        }
    }
    
}
