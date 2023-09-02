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
    
    
    var isContinuable: Bool = true
    var isShowDetailedButton: Bool = false
    
    var showDetailedView: ((SessionModel) -> Void)?
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
    private var showContinueButton: Bool {
        isContinuable && model?.winner == nil
    }
    
    init() {
        super.init(frame: .zero)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUi() {
        backgroundColor = .clear

        addSubview(vStack)
        vStack.constraintToParent()
        vStack.clipsToBounds =  true
        vStack.layer.cornerRadius = 12
        vStack.backgroundColor = .tertiarySystemBackground
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
        winnerImageView.tintColor = .label
        hStack.addArrangedSubview(winnerImageView)

        vStack.addArrangedSubview(stack)
        stack.axis = .vertical
        stack.backgroundColor = .secondarySystemBackground
        stack.layer.cornerRadius = 8
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapContinueSessionButton()
        })
        addSubview(buttonVC.view)
        buttonVC.isGradientEnabled = false
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
    
    private func updateContinueButton() {
        switch type {
        case .compact:
            vStack.layoutMargins.bottom = 15
            buttonVC.view.alpha = 0
            
        case .full:
            if !showContinueButton {
                vStack.layoutMargins.bottom = 15
                buttonVC.view.alpha = 0
            } else {
                vStack.layoutMargins.bottom = 50 + 15 + 12
                buttonVC.view.alpha = 1
            }
        }
    }
    
    private func clearAll() {
        stack.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
    }
    
    private func didChangeType() {
        switch type {
        case .compact:
            updateContinueButton()
            stack.isHidden = true
            stack.alpha = 0
            
        case .full:
            updateContinueButton()
            stack.isHidden = false
            stack.alpha = 1
        }
    }
    
    @discardableResult
    private func createAndAddCell(title: String, valueView: UIView) -> UIView {
        let fLabel = UILabel()
        
        fLabel.font = .rounded(ofSize: 16, weight: .medium)
        fLabel.text = title

        let s = UIView()
        s.addSubview(fLabel)
        s.addSubview(valueView)
        s.translatesAutoresizingMaskIntoConstraints = false
        
        fLabel.translatesAutoresizingMaskIntoConstraints = false
        valueView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = s.heightAnchor.constraint(equalToConstant: 40)
        constraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            valueView.trailingAnchor.constraint(equalTo: s.trailingAnchor, constant: -15),
            valueView.centerYAnchor.constraint(equalTo: s.centerYAnchor),
            
            fLabel.leadingAnchor.constraint(equalTo: s.leadingAnchor, constant: 15),
            fLabel.trailingAnchor.constraint(equalTo: valueView.leadingAnchor),
            fLabel.centerYAnchor.constraint(equalTo: s.centerYAnchor),
            
            constraint
        ])
        
        stack.addArrangedSubview(s)
        return s
    }
    
    private func createLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.font = .rounded(ofSize: 16, weight: .medium)
        label.textAlignment = .right
        label.text = text
        return label
    }
    
    private func createImageView(with image: UIImage) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = image
        iv.tintColor = .label
        iv.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return iv
    }
    
    private func handleData(model: SessionModel) {
        let isGameComplete = model.winner != nil
        if let winner = model.winner {
            createAndAddCell(title: "Победитель", valueView: createLabel(with: winner.title))
        }
        
        createAndAddCell(title: "Кол-во игроков", valueView: createLabel(with: "\(model.totalCount)"))
        createAndAddCell(title: isGameComplete ? "Кол-во выживших игроков" : "Кол-во живых игроков", valueView: createLabel(with: "\(model.alivePlayersCount)"))
        model.roleAndPlayers.sorted { v1, v2 in
            let i1 = SessionRoleId.roleWakeUpOrder.firstIndex(of: v1.key)!
            let i2 = SessionRoleId.roleWakeUpOrder.firstIndex(of: v2.key)!
            return i1 < i2
        }.forEach { (role: SessionRoleId, players: [Int]) in
            let pl = players.sorted().compactMap { ind in
                "\(ind + 1)"
            }.joined(separator: ", ")
            createAndAddCell(title: role.title, valueView: createLabel(with: "\(pl)"))
        }
        
        if isShowDetailedButton {
            createAndAddCell(title: "Детальная статистика", valueView: createImageView(with: .init(systemName: "chevron.right")!)).addTapGesture(target: self, action: #selector(didTapShowDetailedViewButton))
        }
    }
    
    @objc private func didTapShowDetailedViewButton() {
        guard let model = self.model else { return }
        showDetailedView?(model)
    }
    
    private func didTapContinueSessionButton() {
        continueSession?()
    }
}
