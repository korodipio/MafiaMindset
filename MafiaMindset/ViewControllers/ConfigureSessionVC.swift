//
//  ConfigureSessionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 16.08.23.
//

import UIKit

class ConfigureSessionVC: UIViewController {
    
    struct PlayerInfo {
        var ind: Int
        var roleTitle: String
        var isAlive: Bool
    }
    
    var isEditable = false {
        didSet {
            didChangeIsEditable()
        }
    }
    private let onComplete: () -> Void
    private let model: SessionModel
    private let tableView = UITableView()
    private var isPresented = false
    private var players: [PlayerInfo] = []
    private var buttonVC: ButtonVC!
    private let rightButtonItem = UIBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
    
    init(model: SessionModel, onComplete: @escaping () -> Void) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPresented = true
    }
    
    private func setupUi() {
        title = "Настройки игры"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        rightButtonItem.isEnabled = false
        navigationItem.rightBarButtonItem = rightButtonItem
        
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
        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: LabelTableViewCell.identifier)
        
        setupData()
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = isEditable ? "Применить" : "Вернуться"
    }
    
    private func didChangeIsEditable() {
        rightButtonItem.image = .init(systemName: isEditable ? "lock.open" : "lock")
        buttonVC?.buttonTitle = isEditable ? "Применить" : "Вернуться"
    }
    
    @objc private func didTapDoneButton() {
        players.forEach { player in
            guard player.isAlive != self.isPlayerAlive(player.ind) else { return }
            
            if player.isAlive {
                model.kickedPlayers.removeAll { ind in
                    player.ind == ind
                }
                model.deadPlayers.removeAll { ind in
                    player.ind == ind
                }
            }
            else {
                model.deadPlayers.append(player.ind)
            }
        }
        
        onComplete()
    }
    
    private func isPlayerAlive(_ ind: Int) -> Bool {
        return !(model.kickedPlayers + model.deadPlayers).contains(ind)
    }
    
    private func setupData() {
        players = model.players.compactMap({ (key: Int, value: SessionRoleId) -> PlayerInfo in
                .init(ind: key, roleTitle: value.title, isAlive: self.isPlayerAlive(key))
        })
        players.sort { v1, v2 in
            v1.ind < v2.ind
        }
    }
}

extension ConfigureSessionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        12
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        players.count
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
        
        let player = players[indexPath.section]
        cell.title = "\(player.ind + 1) - \(player.roleTitle)"
        cell.isActive = player.isAlive
        
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowColor = player.isAlive ? UIColor.primary?.cgColor : UIColor.clear.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isEditable else { return }
        
        var player = players[indexPath.section]
        player.isAlive = !player.isAlive
        players.remove(at: indexPath.section)
        players.insert(player, at: indexPath.section)
        tableView.reloadData()
    }
}
