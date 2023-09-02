//
//  GenericTableViewCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 30.08.23.
//

import UIKit

class GenericTableViewCell: UITableViewCell {

    private var isSetupUi = false
    
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
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
    }
}
