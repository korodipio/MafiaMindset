//
//  IntRoleTableViewCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 09.08.23.
//

import UIKit

class IntRoleTableViewCell: RoleTableViewCell {
    
    var intValue: Int? {
        guard let text = contentLabel.text else { return nil }
        return Int(text)
    }
    var content: String? {
        get { contentLabel.text }
        set {
            contentLabel.text = newValue
            self.onUpdate?(self)
        }
    }
    private let contentLabel = UILabel()
    private var isSetupUi = false
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupUi()
    }
    
    private func setupUi() {
        if isSetupUi { return }
        isSetupUi = true
        
        contentLabel.font = .rounded(ofSize: 16, weight: .medium)
        self.addContentView(contentLabel)
        addTapGesture(target: self, action: #selector(didTap))
    }
    
    @objc private func didTap() {
        let alertVC = UIAlertController(title: "Колличество", message: "Введи кол-во персонажей данной роли", preferredStyle: .alert)
        alertVC.view.tintColor = .label
        
        var textField: UITextField?
        alertVC.addTextField { tf in
            textField = tf
            tf.placeholder = "От 0 до 30"
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            guard let value = textField?.text, !value.isEmpty else { return }
            guard let intValue = Int(value), intValue > 0 && intValue <= 30 else { return }
            self.isValid = true
            self.content = value
        }
        alertVC.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertVC.addAction(cancelAction)
        
        presentedVC?.present(alertVC, animated: true)
    }
}
