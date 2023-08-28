//
//  BoolRoleTableViewCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 10.08.23.
//

import UIKit

class BoolTableViewCell: EditableTableViewCell {

    var isChecked = false {
        didSet {
            self.isValid = isChecked
            self.contentImage.alpha = isChecked ? 1 : 0
            self.onUpdate?(self)
        }
    }
    private let contentImage = UIImageView()
    private var isSetupUi = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        setupUi()
//    }
    
    private func setupUi() {
        if isSetupUi { return }
        isSetupUi = true
        
        self.addContentView(contentImage)
        contentImage.image = UIImage(systemName: "checkmark.circle")
        contentImage.contentMode = .scaleAspectFit
        contentImage.tintColor = .label
        addTapGesture(target: self, action: #selector(didTap))
    }
    
    @objc private func didTap() {
        self.isChecked = !self.isChecked
    }
}
