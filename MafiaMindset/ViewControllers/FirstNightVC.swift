//
//  FirstNightVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 10.08.23.
//

import UIKit
import LTMorphingLabel

class FirstNightVC: UIViewController {
    
    private let onComplete: (SessionModel) -> Void
    private let model: SessionModel
    private var rolesToWake: [RolePlayers] = []
    private var rolesToWakeIndex = 0
    private let titleLabel = UILabel()
    private let roleLabel = LTMorphingLabel()
    private let playersLabel = LTMorphingLabel()
    private var buttonVC: ButtonVC!
    
    init(model: SessionModel, onComplete: @escaping (SessionModel) -> Void) {
        self.onComplete = onComplete
        self.model = model
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
        title = "Ночь. Знакомство"
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
            self?.didTapWakedUpButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Проснулись"

        rolesToWake = model.roleAndPlayers.compactMap({ v1 in
            return v1.key != .civ ? RolePlayers(role: v1.key, players: v1.value.sorted()) : nil
        }).sorted(by: { v1, v2 in
            let i1 = SessionRoleId.roleWakeUpOrder.firstIndex(of: v1.role)!
            let i2 = SessionRoleId.roleWakeUpOrder.firstIndex(of: v2.role)!
            return i1 < i2
        })
        rolesToWakeIndex = 0
        prepare()
    }
    
    @objc private func didTapWakedUpButton() {
        guard rolesToWakeIndex < rolesToWake.count - 1 else {
            onComplete(model)
            return
        }
        
        rolesToWakeIndex += 1
        prepare()
    }

    private func prepare() {
        let rolePlayers = rolesToWake[rolesToWakeIndex]
        roleLabel.text = rolePlayers.role.title
        playersLabel.text = ""
        rolePlayers.players.forEach { ind in
            playersLabel.text! += "\(ind + 1),"
        }
        
        let isBossExists = model.isBossExists
        if isBossExists && rolePlayers.role == .maf {
            rolesToWake.first { role in
                role.role == .boss
            }?.players.forEach({ ind in
                playersLabel.text! += "\(ind + 1)(Б.),"
            })
        }
        
        playersLabel.text!.removeLast()
    }
}
