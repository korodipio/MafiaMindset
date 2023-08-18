//
//  SessionView.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 18.08.23.
//

import UIKit

class SessionView: UIView {
    
    enum ViewType {
        case compact
        case full
    }

    var type: ViewType = .full {
        didSet {
            didChangeType()
        }
    }
    var continueSession: (() -> Void)?
    private let vStack = UIStackView()
    private let hStack = UIStackView()
    private let stack = UIStackView()
    var model: SessionModel? {
        didSet {
            didChangeModel()
        }
    }
    private let titleLabel = UILabel()
    private lazy var winnerImageView = UIImageView()
    private var buttonVC: ButtonVC!
    
    init() {
        super.init(frame: .zero)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUi() {
        backgroundColor = .clear
        clipsToBounds =  true
        layer.cornerRadius = 12
        layer.borderColor = UIColor.primary?.cgColor
        layer.borderWidth = 2
        
        addSubview(vStack)
        vStack.backgroundColor = .systemBackground
        vStack.constraintToParent()
        vStack.axis = .vertical
        vStack.isLayoutMarginsRelativeArrangement = true
        vStack.layoutMargins = .init(top: 15, left: 15, bottom: 15, right: 15)
        vStack.spacing = 12

        vStack.addArrangedSubview(hStack)
        hStack.axis = .horizontal
        hStack.distribution = .fillProportionally
        
        titleLabel.font = .rounded(ofSize: 16, weight: .medium)
        hStack.addArrangedSubview(titleLabel)
        
        winnerImageView.contentMode = .scaleAspectFit
        winnerImageView.image = .init(systemName: "trophy")
        winnerImageView.tintColor = .black
        hStack.addArrangedSubview(winnerImageView)

        vStack.addArrangedSubview(stack)
        stack.axis = .vertical
        stack.backgroundColor = .secondarySystemBackground
        stack.layer.cornerRadius = 8
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapContinueSessionButton()
        })
        addSubview(buttonVC.view)
        buttonVC.view.constraintToParent()
        buttonVC.buttonTitle = "Продолжить игру"
        
        didChangeType()
    }
    
    private func didChangeModel() {
        guard let model else { return }
        
        titleLabel.text = "Игра от " + Date(timeIntervalSince1970: model.unixDateCreated).formatted()
        winnerImageView.isHidden = model.winner == nil

        clearAll()
        handleData(model: model)
    }
    
    private func clearAll() {
        stack.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
    }
    
    private func didChangeType() {
        switch type {
        case .compact:
            vStack.layoutMargins.bottom = 15
            stack.isHidden = true
            stack.alpha = 0
            buttonVC.view.alpha = 0
            
        case .full:
            vStack.layoutMargins.bottom = 50 + 15 + 12
            stack.isHidden = false
            stack.alpha = 1
            buttonVC.view.alpha = 1
        }
    }
    
    private func createAndAddCell(title: String, value: String) {
        let fLabel = UILabel()
        let sLabel = UILabel()
        
        fLabel.font = .rounded(ofSize: 16, weight: .medium)
        sLabel.font = .rounded(ofSize: 16, weight: .medium)
        sLabel.textAlignment = .right

        fLabel.text = title
        sLabel.text = value
        
        let s = UIView()
        s.addSubview(fLabel)
        s.addSubview(sLabel)
        s.translatesAutoresizingMaskIntoConstraints = false
        
        fLabel.translatesAutoresizingMaskIntoConstraints = false
        sLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = s.heightAnchor.constraint(equalToConstant: 40)
        constraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            sLabel.trailingAnchor.constraint(equalTo: s.trailingAnchor, constant: -15),
            sLabel.centerYAnchor.constraint(equalTo: s.centerYAnchor),
            
            fLabel.leadingAnchor.constraint(equalTo: s.leadingAnchor, constant: 15),
            fLabel.trailingAnchor.constraint(equalTo: sLabel.leadingAnchor),
            fLabel.centerYAnchor.constraint(equalTo: s.centerYAnchor),
            
            constraint
        ])
        
        stack.addArrangedSubview(s)
    }
    
    private func handleData(model: SessionModel) {
        let isGameComplete = model.winner != nil
        if let winner = model.winner {
            createAndAddCell(title: "Победитель", value: winner.title)
        }
        
        createAndAddCell(title: "Кол-во игроков", value: "\(model.totalCount)")
        createAndAddCell(title: isGameComplete ? "Кол-во выживших игроков" : "Кол-во живых игроков", value: "\(model.alivePlayersCount)")
        model.roleAndPlayers.sorted { v1, v2 in
            let i1 = SessionRoleId.roleWakeUpOrder.firstIndex(of: v1.key)!
            let i2 = SessionRoleId.roleWakeUpOrder.firstIndex(of: v2.key)!
            return i1 < i2
        }.forEach { (role: SessionRoleId, players: [Int]) in
            let pl = players.compactMap { ind in
                "\(ind + 1)"
            }.joined(separator: ", ")
            createAndAddCell(title: role.title, value: "\(pl)")
        }
    }
    
    private func didTapContinueSessionButton() {
        continueSession?()
    }
}
