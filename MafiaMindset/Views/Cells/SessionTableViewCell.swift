//
//  SessionTableViewCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 17.08.23.
//

import UIKit

class SessionTableViewCell: UITableViewCell {
    
    static let identifier = "SessionTableViewCell"

    var model: SessionModel? {
        didSet {
            didChangeModel()
        }
    }
    private var isSetupUi = false
    let sessionView = SessionView()
    
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
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 6
        contentView.layer.shadowOffset = .init(width: 0, height: 1)
//        contentView.layer.shadowOpacity = 0.1
        
        contentView.addSubview(sessionView)
        sessionView.constraintToParent()
        sessionView.type = .compact
    }

    private func didChangeModel() {
        sessionView.model = model
    }
}
