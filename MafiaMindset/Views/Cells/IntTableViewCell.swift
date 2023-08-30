//
//  IntRoleTableViewCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 09.08.23.
//

import UIKit

class IntTableViewCell: EditableTableViewCell {
    
    var maxValue: Int = 30
    var intValue: Int? {
        get {
            guard let text = contentLabel.text else { return nil }
            return Int(text)
        }
        set {
            contentLabel.text = "\(min(maxValue, newValue ?? 0))"
        }
    }
    var content: String? {
        get { contentLabel.text }
        set {
            contentLabel.text = newValue
            self.onUpdate?(self)
        }
    }
    private let contentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUi() {
        contentLabel.font = .rounded(ofSize: 16, weight: .medium)
        self.addContentView(contentLabel)
        addTapGesture(target: self, action: #selector(didTap))
    }
    
    @objc private func didTap() {
        let alertVC = UIAlertController(title: "Колличество", message: "Введи кол-во", preferredStyle: .alert)
        alertVC.view.tintColor = .label
        
        var textField: UITextField?
        alertVC.addTextField { tf in
            textField = tf
            tf.placeholder = "От 0 до \(self.maxValue)"
        }
        
        let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
            guard let value = textField?.text, !value.isEmpty else { return }
            guard let intValue = Int(value), intValue > 0 && intValue <= self.maxValue else { return }
            self.isValid = true
            self.content = value
        }
        alertVC.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertVC.addAction(cancelAction)
        
        presentedVC?.present(alertVC, animated: true)
    }
}
