//
//  NightResultTableViewCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 11.08.23.
//

import UIKit

class LabelTableViewCell: UITableViewCell {

    static let identifier = "LabelTableViewCell"

    var isActive: Bool = true {
        didSet {
            didChangeIsActive()
        }
    }
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    private var isSetupUi = false
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let overlayView = UIView()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupUi()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: .init(top: 0, left: layoutMargins.left, bottom: 0, right: layoutMargins.right))
    }

    private func setupUi() {
        if isSetupUi { return }
        isSetupUi = true
        
        selectionStyle = .none
        clipsToBounds = false
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.backgroundColor = .tertiarySystemBackground
        backgroundColor = .clear
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        
        contentView.addSubview(stackView)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 10, left: 15, bottom: 10, right: 15)
        stackView.constraintToParent()
        stackView.spacing = 15
        stackView.axis = .horizontal
        stackView.backgroundColor = .tertiarySystemBackground
        stackView.addArrangedSubview(titleLabel)
        stackView.backgroundColor = .clear
        titleLabel.font = .rounded(ofSize: 16, weight: .regular)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        contentView.addSubview(overlayView)
        overlayView.constraintToParent()
        overlayView.backgroundColor = .systemGray6.withAlphaComponent(0.5)
        
        didChangeIsActive()
    }
    
    private func didChangeIsActive() {
        overlayView.alpha = isActive ? 0 : 1
    }
}
