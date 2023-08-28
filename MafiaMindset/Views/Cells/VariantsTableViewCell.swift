//
//  VariantsTableViewCell.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 27.08.23.
//

import UIKit

struct Variant {
    var id: String
    var title: String
    var data: Any? = nil
}

class VariantsTableViewCell: EditableTableViewCell {
    
    private var defaultVariantIndex: Int {
        didSet {
            updateVariant()
        }
    }
    private let onComplete: (Variant) -> Void
    private let variants: [Variant]
    private let contentLabel = UILabel()
    
    init(variants: [Variant], defaultVariantIndex: Int, onComplete: @escaping (Variant) -> Void) {
        self.variants = variants
        self.defaultVariantIndex = defaultVariantIndex
        self.onComplete = onComplete
        super.init(style: .default, reuseIdentifier: nil)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUi() {
        contentLabel.font = .rounded(ofSize: 12, weight: .regular)
        self.addContentView(contentLabel)
        addTapGesture(target: self, action: #selector(didTap))
        
        updateVariant()
    }
    
    private func updateVariant() {
        if let variant = variants[safe: defaultVariantIndex] {
            contentLabel.text = variant.title
        }
    }
    
    @objc private func didTap() {
        let alertVC = UIAlertController(title: "Выбери нужный вариант", message: nil, preferredStyle: .alert)
        alertVC.view.tintColor = .label
        
        variants.enumerated().forEach { variant in
            let action = UIAlertAction(title: variant.element.title, style: .default) { _ in
                self.defaultVariantIndex = variant.offset
                self.onComplete(variant.element)
            }
            alertVC.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertVC.addAction(cancelAction)
        
        presentedVC?.present(alertVC, animated: true)
    }
}
