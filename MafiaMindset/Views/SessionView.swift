//
//  SessionView.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 17.08.23.
//

import UIKit

class SessionView: UIView {
    
    weak var model: SessionModel? {
        didSet {
            didChangeModel()
        }
    }
    
    private let stackView = UIStackView()
    private let dateLabel = UILabel()
    private let playersLabel = UILabel()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUi() {
        addSubview(stackView)
        stackView.constraintToParent()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 15, left: 15, bottom: 15, right: 45)
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(playersLabel)
        
        addSubview(imageView)
        imageView.image = .init(systemName: "trophy")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            imageView.widthAnchor.constraint(equalToConstant: 25),
            imageView.heightAnchor.constraint(equalToConstant: 25)
        ])
        imageView.isHidden = true
        
        dateLabel.font = .rounded(ofSize: 16, weight: .medium)
        playersLabel.font = .rounded(ofSize: 12, weight: .regular)
    }
    
    private func didChangeModel() {
        guard let model else { return }
        
        imageView.isHidden = model.winner == nil
        dateLabel.text = "Игра от " + Date(timeIntervalSince1970: model.unixDateCreated).formatted()
        playersLabel.text = "Кол-во игроков \(model.totalCount)"
    }
}
