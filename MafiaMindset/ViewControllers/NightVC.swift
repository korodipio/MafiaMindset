//
//  NightVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 12.08.23.
//

import UIKit
import LTMorphingLabel

class NightVC: UIViewController {

    private let onComplete: (NightModel) -> Void
    private let model: SessionModel
    private var rolesToWake: [RolePlayers] = []
    private var rolesToWakeIndex = 0
    
    private var lastNightModel: NightModel? {
        model.nights.last
    }
    private(set) var nightModel = NightModel()
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
    private var lastNightLoverSelection: Int? {
        lastNightModel?.lover
    }
    
    init(model: SessionModel, onComplete: @escaping (NightModel) -> Void) {
        self.model = model
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
        title = "Ночь"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        titleLabel.text = "Просыпается"
        titleLabel.textAlignment = .center
        titleLabel.font = .rounded(ofSize: 20, weight: .regular)
        roleLabel.morphingEffect = .evaporate
        playersLabel.morphingEffect = .evaporate
        roleLabel.font = .rounded(ofSize: 52, weight: .bold)
        playersLabel.font = .rounded(ofSize: 20, weight: .medium)
        playersLabel.textAlignment = .center
        playersLabel.lineBreakMode = .byWordWrapping
        playersLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        view.addSubview(roleLabel)
        view.addSubview(playersLabel)
        playersLabel.lineBreakMode = .byWordWrapping
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        playersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            roleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: roleLabel.topAnchor),
            
            playersLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 15),
            playersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            playersLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
        ])

        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
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
    
    private func nightCompleted() {
        showResult(for: nightModel)
    }
    
    private func showResult(for nightModel: NightModel) {
        let vc = NightResultVC(onComplete: { [weak self] () in
            guard let self else { return }
            self.onComplete(self.nightModel)
        }, nightModel: nightModel)
        navigationController?.pushViewController(vc, animated: true)
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
    
    private func showAlert(title: String?, message: String? = nil, completed: (() -> Void)? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.view.tintColor = .label
        
        let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
            completed?()
        }
        vc.addAction(okAction)
        present(vc, animated: true)
    }
    
    // Handles each role unique action
    private func handle(complete: @escaping () -> Void) {
        let rolePlayers = rolesToWake[rolesToWakeIndex]
        let role = rolePlayers.role
        let vc = UIAlertController(title: role.title, message: "Выбери игрока", preferredStyle: .alert)
        vc.view.tintColor = .label
        
        switch role {
        case .maf:
            if alivePlayerWith(roles: [role, .boss, .wolf]).isEmpty {
                complete()
                return
            }
            // Mafic can kill themself
            // model.isWolfWakedUp ? [role, .boss, .wolf] : [role, .boss]
            playersWithAnother(roles: []).sorted().forEach { ind in
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
                    self.nightModel.boss = ind
                    
                    var takenByLover = false
                    if let loverSelection = self.nightModel.lover {
                        takenByLover = loverSelection == ind
                    }
                    if takenByLover {
                        self.showAlert(title: "Мимо", message: nil) {
                            complete()
                        }
                    }
                    else {
                        var isCorrect = false
                        if self.model.isAlive(role: .commissar) {
                            isCorrect = self.playersWith(roles: [.commissar]).contains(ind)
                        } else if self.model.isPatrolExists {
                            isCorrect = self.playersWith(roles: [.patrol]).contains(ind)
                        }
                        self.showAlert(title: isCorrect ? "Попал" : "Мимо", message: nil) {
                            complete()
                        }
                    }
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
            // Maniac can kill himself
            playersWithAnother(roles: []).sorted().forEach { ind in
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
                    self.nightModel.commissar = ind
                    
                    var takenByLover = false
                    if let loverSelection = self.nightModel.lover {
                        takenByLover = loverSelection == ind
                    }
                    if takenByLover {
                        self.showAlert(title: "Мимо", message: nil) {
                            complete()
                        }
                    }
                    else {
                        let isCorrect = self.playersWith(roles: self.model.isWolfWakedUp ? [.boss, .maf, .wolf] : [.boss, .maf]).contains(ind)
                        self.showAlert(title: isCorrect ? "Попал" : "Мимо", message: nil) {
                            complete()
                        }
                    }
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
                    self.nightModel.patrol = ind
                    
                    var takenByLover = false
                    if let loverSelection = self.nightModel.lover {
                        takenByLover = loverSelection == ind
                    }
                    if takenByLover {
                        self.showAlert(title: "Мимо", message: nil) {
                            complete()
                        }
                    }
                    else {
                        let isCorrect = self.playersWith(roles: self.model.isWolfWakedUp ? [.boss, .maf, .wolf] : [.boss, .maf]).contains(ind)
                        self.showAlert(title: isCorrect ? "Попал" : "Мимо", message: nil) {
                            complete()
                        }
                    }
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
                    self.nightModel.bloodhound = ind
                    
                    var takenByLover = false
                    if let loverSelection = self.nightModel.lover {
                        takenByLover = loverSelection == ind
                    }
                    if takenByLover {
                        self.showAlert(title: "Мимо", message: nil) {
                            complete()
                        }
                    }
                    else {
                        let isCorrect = self.playersWith(roles: [.maniac]).contains(ind)
                        self.showAlert(title: isCorrect ? "Попал" : "Мимо", message: nil) {
                            complete()
                        }
                    }
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
            
        case .lover:
            var players = playersWithAnother(roles: [])
            if let lastNightLoverSelection {
                players.removeAll(where: { ind in
                    lastNightLoverSelection == ind
                })
            }
            if alivePlayerWith(roles: [role]).isEmpty || players.isEmpty {
                complete()
                return
            }
            players.sorted().forEach { ind in
                let action = UIAlertAction(title: "\(ind + 1)", style: .default) { _ in
                    self.nightModel.lover = ind
                    complete()
                }
                vc.addAction(action)
            }
            
        case .civ:
            break
        }
        
        vc.addAction(.init(title: "Отмена", style: .cancel))
        present(vc, animated: true)
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
        if let loverSelection = nightModel.lover {
            let isLoverDead = nightModel.dies.contains(alivePlayerWith(roles: [.lover]).first!)
            if isLoverDead {
                nightModel.dies.append(loverSelection)
//                if let healedByMedic = nightModel.medic {
//                    if healedByMedic != loverSelection {
//                        nightModel.dies.append(loverSelection)
//                    }
//                } else {
//                    nightModel.dies.append(loverSelection)
//                }
            }
            else {
                nightModel.dies.removeAll { ind in
                    ind == loverSelection
                }
            }
        }

        // Removes duplicates
        nightModel.dies = Array(Set(nightModel.dies))
        model.deadPlayers.insert(contentsOf: nightModel.dies, at: 0)
        
        nightCompleted()
    }
}
