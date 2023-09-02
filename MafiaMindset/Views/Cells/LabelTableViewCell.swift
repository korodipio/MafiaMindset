//
//  NightResultTableViewCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 11.08.23.
//

import UIKit

class LabelTableViewCell: GenericTableViewCell {

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
    
    private func setupUi() {
        if isSetupUi { return }
        isSetupUi = true
        
        contentView.addSubview(stackView)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 10, left: 15, bottom: 10, right: 15)
        stackView.constraintToParent()
        stackView.spacing = 15
        stackView.axis = .horizontal
        stackView.backgroundColor = .tertiarySystemBackground
        stackView.addArrangedSubview(titleLabel)

        titleLabel.font = .rounded(ofSize: 16, weight: .medium)
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
