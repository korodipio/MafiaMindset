//
//  SessionTableViewCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 17.08.23.
//

import UIKit

class SessionTableViewCell: UITableViewCell {
    
    static let identifier = "SessionTableViewCell"

    weak var model: SessionModel? {
        didSet {
            didChangeModel()
        }
    }
    private var isSetupUi = false
    private let sessionView = SessionView()
    
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
        contentView.backgroundColor = .systemBackground
        backgroundColor = .clear
        
        contentView.addSubview(sessionView)
        sessionView.constraintToParent()
    }

    private func didChangeModel() {
        sessionView.model = model
    }
}
