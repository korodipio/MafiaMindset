//
//  NightView.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 11.08.23.
//

import UIKit
import LTMorphingLabel

class NightView: UIView {
    
    private let model: SessionModel
    private var rolesToWake: [RolePlayers] = []
    private var rolesToWakeIndex = 0
    
    private let lastNightModel: NightModel?
    private(set) var nightModel = NightModel()
    private let onComplete: (NightModel) -> Void
    var roleTitle: String? {
        get { roleLabel.text }
        set { roleLabel.text = newValue }
    }
    var playersTitle: String? {
        get { playersLabel.text }
        set { playersLabel.text = newValue }
    }
    private let titleLabel = UILabel()
    private let roleLabel = LTMorphingLabel()
    private let playersLabel = LTMorphingLabel()
    private var buttonVC: ButtonVC!
    
    private var lastNightMedicHeal: Int? {
        lastNightModel?.medic
    }
    
    init(model: SessionModel, onComplete: @escaping (NightModel) -> Void) {
        self.model = model
        self.onComplete = onComplete
        self.lastNightModel = model.nights.last
        super.init(frame: .zero)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUi() {
        titleLabel.text = "Просыпается"
        titleLabel.textAlignment = .center
        titleLabel.font = .rounded(ofSize: 20, weight: .regular)
        roleLabel.morphingEffect = .evaporate
        playersLabel.morphingEffect = .evaporate
        roleLabel.font = .rounded(ofSize: 56, weight: .bold)
        playersLabel.font = .rounded(ofSize: 20, weight: .medium)
        playersLabel.textAlignment = .center
        playersLabel.lineBreakMode = .byWordWrapping
        playersLabel.numberOfLines = 0
        addSubview(titleLabel)
        addSubview(roleLabel)
        addSubview(playersLabel)
        playersLabel.lineBreakMode = .byWordWrapping
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        playersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            roleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            roleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: roleLabel.topAnchor),
            
            playersLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 15),
            playersLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            playersLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
        ])
        layoutMargins = .zero
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        addSubview(buttonVC.view)
        buttonVC.view.constraintToParentMargin()
        buttonVC.buttonTitle = "Далее"
    }
    
    private func moveToNextPlayer() {
        handle {
            self.rolesToWakeIndex += 1
            
            // Civillians doesn't wakes up
            guard self.rolesToWakeIndex < self.rolesToWake.count - 1 else {
                self.finished()
                return
            }
            
            self.prepare()
        }
    }
    
    @objc private func didTapDoneButton() {
        moveToNextPlayer()
    }
    
    func start() {
        rolesToWake = model.roleAndPlayers.compactMap({ v1 in
            let alivePlayers = Array(Set(v1.value).subtracting(model.deadPlayers + model.kickedPlayers))
            guard !alivePlayers.isEmpty else { return RolePlayers(role: v1.key, players: []) }
            return RolePlayers(role: v1.key, players: alivePlayers.sorted())
        }).sorted(by: { v1, v2 in
            let i1 = SessionRoleId.roleWakeUpOrder.firstIndex(of: v1.role)!
            let i2 = SessionRoleId.roleWakeUpOrder.firstIndex(of: v2.role)!
            return i1 < i2
        })
        
        var messagesToShow: [String] = []
        if model.isWolfExists && model.isAlive(role: .wolf) && model.isAnyMafiaOrBossDeadOrKicked && !model.isWolfWakedUp {
            model.isWolfWakedUp = true
            messagesToShow.append("Разбуди оборотня!")
        }
        if model.isCommisarExists && model.isAlive(role: .patrol) && !model.isAlive(role: .commissar) && !model.isPatrolWakedUp {
            model.isPatrolWakedUp = true
            messagesToShow.append("Разбуди патрульного!")
        }
        if !messagesToShow.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: messagesToShow.joined(separator: "\n"))
            }
        }
        
        rolesToWakeIndex = 0
        prepare()
    }
    
    private func isDeadOrKicked(player id: Int) -> Bool {
        return (model.deadPlayers + model.kickedPlayers).contains(id)
    }
    
    private func playersWithAnother(roles: [SessionRoleId]) -> [Int] {
        return rolesToWake.flatMap { rolePlayers -> [Int] in
            guard !roles.contains(rolePlayers.role) else { return [] }
            return rolePlayers.players
        }
    }
    
    private func playersWith(roles: [SessionRoleId]) -> [Int] {
        return rolesToWake.flatMap { rolePlayers -> [Int] in
            guard roles.contains(rolePlayers.role) else { return [] }
            return rolePlayers.players
        }
    }
    
    private func alivePlayerWith(roles: [SessionRoleId]) -> [Int] {
        return rolesToWake.flatMap { rolePlayer in
            return roles.contains(rolePlayer.role) ? rolePlayer.players : []
        }
    }
    
    private func showAlert(title: String?, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.view.tintColor = .black
        vc.addAction(.init(title: "Ok", style: .cancel))
        presentedVC?.present(vc, animated: true)
    }
    
    // Handles each role unique action
    private func handle(complete: @escaping () -> Void) {
        let rolePlayers = rolesToWake[rolesToWakeIndex]
        let role = rolePlayers.role
        let vc = UIAlertController(title: role.title, message: "Выбери игрока", preferredStyle: .alert)
        vc.view.tintColor = .black
        
        switch role {
        case .maf:
            if alivePlayerWith(roles: [role, .boss, .wolf]).isEmpty {
                complete()
                return
            }
            playersWithAnother(roles: model.isWolfWakedUp ? [role, .boss, .wolf] : [role, .boss]).sorted().forEach { ind in
                let action = UIAlertAction(title: "\(ind + 1)", style: .default) { _ in
                    self.nightModel.mafia = ind
                    complete()
                }
                vc.addAction(action)
            }
            
        case .boss:
            if alivePlayerWith(roles: [role]).isEmpty {
                complete()
                return
            }
            playersWithAnother(roles: [role, .maf]).sorted().forEach { ind in
                let action = UIAlertAction(title: "\(ind + 1)", style: .default) { _ in
                    
                    var isCorrect = false
                    if self.model.isAlive(role: .commissar) {
                        isCorrect = self.playersWith(roles: [.commissar]).contains(ind)
                    } else if self.model.isPatrolExists {
                        isCorrect = self.playersWith(roles: [.patrol]).contains(ind)
                    }
                    self.showAlert(title: isCorrect ? "Попал" : "Мимо", message: nil)
                    
                    self.nightModel.boss = ind
                    complete()
                }
                vc.addAction(action)
            }
            
        case .wolf:
            complete()
            return
            
        case .maniac:
            if alivePlayerWith(roles: [role]).isEmpty {
                complete()
                return
            }
            playersWithAnother(roles: [role]).sorted().forEach { ind in
                let action = UIAlertAction(title: "\(ind + 1)", style: .default) { _ in
                    self.nightModel.maniac = ind
                    complete()
                }
                vc.addAction(action)
            }
            
        case .commissar:
            if alivePlayerWith(roles: [role]).isEmpty {
                complete()
                return
            }
            playersWithAnother(roles: [role]).sorted().forEach { ind in
                let action = UIAlertAction(title: "\(ind + 1)", style: .default) { _ in
                    
                    let isCorrect = self.playersWith(roles: self.model.isWolfWakedUp ? [.boss, .maf, .wolf] : [.boss, .maf]).contains(ind)
                    self.showAlert(title: isCorrect ? "Попал" : "Мимо", message: nil)
                    
                    self.nightModel.commissar = ind
                    complete()
                }
                vc.addAction(action)
            }
            
        case .patrol:
            if alivePlayerWith(roles: [role]).isEmpty {
                complete()
                return
            }
            if model.isAlive(role: .commissar) {
                complete()
                return
            }
            playersWithAnother(roles: [role]).sorted().forEach { ind in
                let action = UIAlertAction(title: "\(ind + 1)", style: .default) { _ in
                    
                    let isCorrect = self.playersWith(roles: self.model.isWolfWakedUp ? [.boss, .maf, .wolf] : [.boss, .maf]).contains(ind)
                    self.showAlert(title: isCorrect ? "Попал" : "Мимо", message: nil)
                    
                    self.nightModel.patrol = ind
                    complete()
                }
                vc.addAction(action)
            }
            
        case .bloodhound:
            if alivePlayerWith(roles: [role]).isEmpty {
                complete()
                return
            }
            playersWithAnother(roles: [role]).sorted().forEach { ind in
                let action = UIAlertAction(title: "\(ind + 1)", style: .default) { _ in
                    
                    let isCorrect = self.playersWith(roles: [.maniac]).contains(ind)
                    self.showAlert(title: isCorrect ? "Попал" : "Мимо", message: nil)
                    
                    self.nightModel.bloodhound = ind
                    complete()
                }
                vc.addAction(action)
            }
            
        case .medic:
            var players = playersWithAnother(roles: [])
            if let lastNightMedicHeal {
                players.removeAll(where: { ind in
                    lastNightMedicHeal == ind
                })
            }
            if alivePlayerWith(roles: [.medic]).isEmpty || players.isEmpty {
                complete()
                return
            }
            players.sorted().forEach { ind in
                let action = UIAlertAction(title: "\(ind + 1)", style: .default) { _ in
                    self.nightModel.medic = ind
                    complete()
                }
                vc.addAction(action)
            }
            
        default:
            break
        }
        
        vc.addAction(.init(title: "Отмена", style: .cancel))
        presentedVC?.present(vc, animated: true)
    }
    
    // Fills labels with actual information
    private func prepare() {
        let rolePlayers = rolesToWake[rolesToWakeIndex]
        let role = rolePlayers.role
        guard role != .wolf else {
            moveToNextPlayer()
            return
        }
        
        roleLabel.text = rolePlayers.role.title
        var result: [String] = []
        rolePlayers.players.forEach { ind in
            result.append("\(ind + 1)")
        }
        
        switch role {
        case .maf:
            let isBossExists = model.isBossExists
            if isBossExists {
                rolesToWake.first { role in
                    role.role == .boss
                }?.players.forEach({ ind in
                    result.append("\(ind + 1)(Б.)")
                })
            }
            
            if model.isWolfWakedUp {
                rolesToWake.first { role in
                    role.role == .wolf
                }?.players.forEach({ ind in
                    result.append( "\(ind + 1)(Об.)")
                })
            }
            
        case .patrol:
            if model.isAlive(role: .patrol) {
                moveToNextPlayer()
            } else {
                roleLabel.text = SessionRoleId.commissar.title
                let last = result.last
                if last != nil {
                    result.remove(at: result.endIndex - 1)
                    result.append("\(last!) (Патрульный)")
                }
                else {
                    result.append("(Патрульный)")
                }
            }
            
        default:
            break
        }
        
        playersLabel.text = result.joined(separator: ", ")
    }
    
    private func finished() {
        if let killedByMafia = nightModel.mafia {
            nightModel.dies.append(killedByMafia)
        }
        if let killedByManiac = nightModel.maniac {
            nightModel.dies.append(killedByManiac)
        }
        if let healedByMedic = nightModel.medic {
            if let ind = nightModel.dies.firstIndex(of: healedByMedic) {
                nightModel.dies.remove(at: ind)
            }
        }
        model.deadPlayers.insert(contentsOf: nightModel.dies, at: 0)
        
        onComplete(nightModel)
    }
}
