//
//  RoleTableViewCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 09.08.23.
//

import UIKit

class EditableTableViewCell: UITableViewCell {
    
    var onUpdate: ((EditableTableViewCell) -> Void)?
    private var _id: String?
    var id: String?
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let contentBox = UILabel()
    private let helpButton = UIButton()
    private var isSetupUi = false
    var isValid = false {
        didSet {
            didChangeIsValid()
        }
    }
    var isError = false {
        didSet {
            didChangeIsValid()
        }
    }
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var helpDescription: String? {
        didSet {
            helpButton.isHidden = helpDescription == nil
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: .init(top: 0, left: layoutMargins.left, bottom: 0, right: layoutMargins.right))
    }
    
    private func setupUi() {
        selectionStyle = .none
        clipsToBounds = false
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        layer.shadowColor = UIColor.primary?.cgColor
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
        stackView.addArrangedSubview(contentBox)
        stackView.addArrangedSubview(helpButton)
        helpButton.tintColor = .label
        helpButton.setImage(.init(systemName: "info.circle"), for: .normal)
        helpButton.isHidden = helpDescription == nil
        helpButton.addTarget(self, action: #selector(didTapHelpButton), for: .touchUpInside)
        
        titleLabel.font = .rounded(ofSize: 16, weight: .medium)
    }
    
    @objc private func didTapHelpButton() {
        let alertVC = UIAlertController(title: "Информация", message: helpDescription, preferredStyle: .alert)
        alertVC.view.tintColor = .label
        
        let okAction = UIAlertAction(title: "Ок", style: .cancel)
        alertVC.addAction(okAction)
        
        presentedVC?.present(alertVC, animated: true)
    }
    
    func addContentView(_ view: UIView) {
        contentBox.addSubview(view)
        view.constraintToParent()
    }
    
    private func didChangeIsValid() {
        UIView.animate(withDuration: 0.1) {
            self.layer.shadowOpacity = self.isValid ? 0.3 : 0.0
            self.layer.shadowColor = self.isError ? UIColor.red.cgColor : UIColor(named: "PrimaryColor")?.cgColor
        }
    }

}
