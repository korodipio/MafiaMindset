//
//  DetailedSessionTableViewCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 30.08.23.
//

import UIKit

enum SessionType {
    case night
    case day
}

class DetailedSessionTableViewCell: GenericTableViewCell {
    
    let type: SessionType
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    private let titleLabel = UILabel()
    private let contentStack = UIStackView()
    private let detailsStack = UIStackView()
    private let model: Any
    
    init(model: Any, type: SessionType) {
        self.model = model
        self.type = type
        super.init(style: .default, reuseIdentifier: nil)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUi() {
        contentView.addSubview(contentStack)
        contentStack.constraintToParent()
        
        contentStack.backgroundColor = .tertiarySystemBackground
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = .init(top: 15, left: 15, bottom: 15, right: 15)
        contentStack.spacing = 10
        contentStack.axis = .vertical
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(detailsStack)
        
        titleLabel.font = .rounded(ofSize: 16, weight: .medium)
        
        detailsStack.backgroundColor = .secondarySystemBackground
//        detailsStack.isLayoutMarginsRelativeArrangement = true
//        detailsStack.layoutMargins = .init(top: 15, left: 15, bottom: 15, right: 15)
//        detailsStack.spacing = 10
        detailsStack.axis = .vertical
        detailsStack.layer.cornerRadius = 8
        
        handleData()
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
        
        detailsStack.addArrangedSubview(s)
    }
    
    private func handleNightData() {
        guard let nightModel = model as? NightModel else { return }
        
        var output: [String] = []
        if !nightModel.dies.isEmpty {
            let r = nightModel.dies
            var str = "Этой ночью умерли: "
            r.forEach { i in
                str += "\(i + 1),"
            }
            str.removeLast()
            output.append(str)
        } else {
            output.append("Этой ночью никто не умер")
        }
        if let r = nightModel.mafia {
            output.append("Выбор Мафии: \(r + 1)")
        }
        if let r = nightModel.boss {
            output.append("Выбор Босса: \(r + 1)")
        }
        if let r = nightModel.maniac {
            output.append("Выбор Маньяка: \(r + 1)")
        }
        if let r = nightModel.lover {
            output.append("Выбор Любовницы: \(r + 1)")
        }
        if let r = nightModel.commissar {
            output.append("Выбор Комиссара: \(r + 1)")
        }
        if let r = nightModel.patrol {
            output.append("Выбор Патрульного: \(r + 1)")
        }
        if let r = nightModel.bloodhound {
            output.append("Выбор Ищейки: \(r + 1)")
        }
        if let r = nightModel.medic {
            output.append("Выбор Доктора: \(r + 1)")
        }
        
        output.forEach { output in
            self.createAndAddCell(title: output, value: "")
        }
    }
    
    private func handleDayData() {
        guard let dayModel = model as? DayModel else { return }
        
        var output: [String] = []
        if !dayModel.kickedPlayers.isEmpty {
            var t: [String] = []
            dayModel.kickedPlayers.forEach { ind in
                t.append("\(ind + 1)")
            }
            output.append((t.count == 1 ? "Исключен: " : "Исключены: ") + t.joined(separator: ", "))
        }
        else {
            output.append("Никто не исключен")
        }
        dayModel.votedPlayers.forEach { votedPlayer in
            output.append("Выдвинут: \(votedPlayer.to + 1) Игроком: \(votedPlayer.by + 1) Голосов: \(votedPlayer.voteCount)")
        }
        output.append("Пропустили голосование: \(dayModel.nonVotedPlayersCount)")
        
        output.forEach { output in
            self.createAndAddCell(title: output, value: "")
        }
    }
    
    private func handleData() {
        switch type {
        case .day:
            handleDayData()
        case .night:
            handleNightData()
        }
    }
}

