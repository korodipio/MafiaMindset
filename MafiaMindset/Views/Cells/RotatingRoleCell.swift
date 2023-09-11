//
//  RotatingRoleCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 10.09.23.
//

import UIKit

protocol RotatingRoleProtocol: AnyObject {
    func willSelectRole(_ cell: RotatingRoleCell)
    func didSelectRole(role: SessionRoleId)
}

class RotatingRoleCell: UICollectionViewCell {
    static let identifier = "RotatingRoleCell"
    
    weak var delegate: RotatingRoleProtocol?
    private let impact = UIImpactFeedbackGenerator(style: .rigid)
    private let rotatingView = RotatingView()
    private let coverView = UIView()
    private let roleView = UIView()
    private let descriptionLabel = UILabel()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private var role: SessionRoleId?
    private var isSetup = false

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupUi()
    }
    
    private func setupUi() {
        if isSetup { return }
        isSetup = true
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        clipsToBounds = false
        contentView.clipsToBounds = false
        
        contentView.layer.shadowColor = UIColor.primary?.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOffset = .init(width: 0, height: 2)
        
        contentView.addSubview(rotatingView)
        rotatingView.constraintToParent()
        rotatingView.willStateChange = { [weak self] () in
            guard let self else { return }
            impact.prepare()
            delegate?.willSelectRole(self)
        }
        rotatingView.onStateChange = { [weak self] state in
            guard let self, let role = self.role, state == .vis else { return }
            delegate?.didSelectRole(role: role)
            impact.impactOccurred()
        }
        
        coverView.layer.cornerRadius = 12
        coverView.backgroundColor = .primary
        
        roleView.layer.cornerRadius = 12
        roleView.backgroundColor = .secondarySystemBackground
        roleView.layer.borderWidth = 2
        roleView.layer.borderColor = UIColor.primary?.cgColor
        
        rotatingView.frontView.addSubview(coverView)
        coverView.constraintToParent()
        
        rotatingView.backView.addSubview(roleView)
        roleView.constraintToParent()
        
        let sv = UIStackView()
        sv.axis = .vertical
        coverView.addSubview(sv)
        sv.constraintToParent()
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 20, left: 0, bottom: 20, right: 0)
        
        let iv = UIImageView(image: .init(systemName: "questionmark"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.transform = .init(scaleX: 0.8, y: 0.8)
        sv.addArrangedSubview(iv)
        
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .rounded(ofSize: 16, weight: .medium)
        label.text = "Нажми чтобы узнать роль"
        sv.addArrangedSubview(label)
        
        let roleStackView = UIStackView()
        roleStackView.axis = .vertical
        roleStackView.isLayoutMarginsRelativeArrangement = true
        roleStackView.layoutMargins = .init(top: 20, left: 10, bottom: 20, right: 10)
        roleView.addSubview(roleStackView)
        roleStackView.constraintToParent()
        
        titleLabel.textAlignment = .center
        titleLabel.font = .rounded(ofSize: 20, weight: .medium)
        roleStackView.addArrangedSubview(titleLabel)
        
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.transform = .init(scaleX: 0.8, y: 0.8)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        roleStackView.addArrangedSubview(imageView)
        
        descriptionLabel.font = .rounded(ofSize: 14, weight: .medium)
        descriptionLabel.textAlignment = .center
        descriptionLabel.alpha = 0.7
        descriptionLabel.numberOfLines = 0
        roleStackView.addArrangedSubview(descriptionLabel)
    }
    
    func reset() {
        rotatingView.setState(state: .hid, animated: false)
    }
    
    func configure(role: SessionRoleId) {
        self.role = role
        
        titleLabel.text = role.title
        imageView.image = role.image?.withRenderingMode(.alwaysTemplate)
        descriptionLabel.text = role.description
    }
}
