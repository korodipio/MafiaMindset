//
//  DayVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 13.08.23.
//

import UIKit

class DayVC: UIViewController {

    enum State {
        case globalDiscussion
        case playersDiscussion
        case votedPlayersDiscussion
        case voting
        case lastDiscussion
        case complete
    }
    
    private var state = State.globalDiscussion {
        didSet {
            didChangeState()
        }
    }
    private let onComplete: (DayModel) -> Void
    private let model: SessionModel
    private(set) var dayModel = DayModel()
    private let titleLabel = UILabel()
    private let stateLabel = UILabel()
    private var buttonVC: ButtonVC!
    private var listBarButtonItem: UIBarButtonItem!
    
    init(model: SessionModel, onComplete: @escaping (DayModel) -> Void) {
        self.model = model
        self.onComplete = onComplete
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }

    private func setupUi() {
        title = "День"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
     
        titleLabel.text = "На очереди"
        titleLabel.textAlignment = .center
        titleLabel.font = .rounded(ofSize: 20, weight: .regular)
        stateLabel.numberOfLines = 0
        stateLabel.textAlignment = .center
        stateLabel.lineBreakMode = .byWordWrapping
        stateLabel.font = .rounded(ofSize: 60, weight: .bold)
        view.addSubview(titleLabel)
        view.addSubview(stateLabel)

        listBarButtonItem = UIBarButtonItem(image: .init(systemName: "list.clipboard"), style: .done, target: self, action: #selector(didTapListButton))
        listBarButtonItem.tintColor = .label
        navigationItem.leftBarButtonItem = listBarButtonItem
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stateLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: stateLabel.topAnchor),
        ])
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTabStartButton()
        })
        buttonVC.buttonTitle = "Начать"
        add(buttonVC)
        
        switch GlobalSettings.shared.discussionOrder {
        case .globalDiscussionThenPlayer:
            state = .globalDiscussion
        case .playersDiscussionThenGlobal:
            state = .playersDiscussion
        }
    }
    
    @objc private func didTapListButton() {
        let vc = DayVoteStatisticVC(model: model, dayModel: dayModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushViewController(_ vc: UIViewController) {
        // Inherit left bar button
        vc.navigationItem.leftBarButtonItem = listBarButtonItem
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTabStartButton() {
        switch state {
        case .globalDiscussion:
            let vc = GlobalDiscussionVC(model: model, onComplete: { [weak self] () in
                guard let self else { return }
                
                switch GlobalSettings.shared.discussionOrder {
                case .globalDiscussionThenPlayer:
                    self.state = .playersDiscussion
                case .playersDiscussionThenGlobal:
                    if self.dayModel.votedPlayers.count <= 1 {
                        self.state = .complete
                        return
                    }
                    self.state = .votedPlayersDiscussion
                }
                
                self.navigationController?.popToViewController(self, animated: true)
            })
            pushViewController(vc)
            
        case .playersDiscussion:
            let vc = PlayersDiscussionVC(model: model, dayModel: dayModel, onComplete: { [weak self] () in
                guard let self else { return }
                if self.dayModel.votedPlayers.count <= 1 {
                    
                    switch GlobalSettings.shared.discussionOrder {
                    case .globalDiscussionThenPlayer:
                        self.state = .complete
                        return
                    default:
                        break
                    }
                }
                
                switch GlobalSettings.shared.discussionOrder {
                case .globalDiscussionThenPlayer:
                    self.state = .votedPlayersDiscussion
                case .playersDiscussionThenGlobal:
                    self.state = .globalDiscussion
                }

                self.navigationController?.popToViewController(self, animated: true)
            })
            pushViewController(vc)
            
        case .votedPlayersDiscussion:
            let vc = VotedPlayersDiscussionVC(dayModel: dayModel) { [weak self] () in
                guard let self else { return }
                self.state = .voting
                self.navigationController?.popToViewController(self, animated: true)
            }
            pushViewController(vc)

        case .voting:
            let vc = DayVoteVC(model: model, dayModel: dayModel) { [weak self] () in
                guard let self else { return }
                if self.dayModel.kickedPlayers.isEmpty {
                    self.state = .complete
                }
                else {
                    self.state = .lastDiscussion
                    self.navigationController?.popToViewController(self, animated: true)
                }
            }
            pushViewController(vc)
            
        case .lastDiscussion:
            let vc = LastDiscussionVC(dayModel: dayModel) { [weak self] () in
                guard let self else { return }
                self.state = .complete
            }
            pushViewController(vc)
            
        default:
            break
        }
    }
    
    private func didChangeState() {
        switch state {
        case .globalDiscussion:
            stateLabel.text = "Общая дискуссия"
        case .playersDiscussion:
            stateLabel.text = "Дискуссия"
        case .votedPlayersDiscussion:
            stateLabel.text = "Оправдание"
        case .voting:
            stateLabel.text = "Голосование"
        case .lastDiscussion:
            stateLabel.text = "Последнее слово"
        case .complete:
            stateLabel.text = "Результаты"

            let vc = DayResultVC(dayModel: dayModel) { [weak self] () in
                guard let self else { return }
                self.onComplete(dayModel)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
