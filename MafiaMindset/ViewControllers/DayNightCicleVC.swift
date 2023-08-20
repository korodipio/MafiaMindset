//
//  DayNightCicleVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 11.08.23.
//

import UIKit
import LTMorphingLabel

class DayNightCicleVC: UIViewController {

    var state: DayNightCycleType = .night {
        didSet {
            didChangeState()
        }
    }
    private let storageViewModel: StorageSessionViewModel
    private let model: SessionModel
    private let night = NightModel()
    private let titleLabel = UILabel()
    private let stateLabel = LTMorphingLabel()
    private var buttonVC: ButtonVC!
    
    init(storageViewModel: StorageSessionViewModel, model: SessionModel) {
        self.state = model.dayNightCycleType
        self.model = model
        self.storageViewModel = storageViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = self
    }
    
    private func setupUi() {
        title = "Цикл"
        view.backgroundColor = .secondarySystemBackground
        
        titleLabel.text = "На очереди"
        titleLabel.textAlignment = .center
        titleLabel.font = .rounded(ofSize: 20, weight: .regular)
        stateLabel.morphingEffect = .evaporate
        stateLabel.font = .rounded(ofSize: 60, weight: .bold)
        view.addSubview(titleLabel)
        view.addSubview(stateLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: stateLabel.topAnchor),
        ])
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTabStartButton()
        })
        buttonVC.buttonTitle = "Начать"
        add(buttonVC)

        storageViewModel.saveSession(model)
        didChangeState()
    }

    private func addConfigurationButtonItem(to navItem: UINavigationItem) {
        let rightButton = UIBarButtonItem(image: .init(systemName: "slider.vertical.3"), style: .done, target: self, action: #selector(didTapConfigureButton))
        rightButton.tintColor = .black
        navItem.rightBarButtonItem = rightButton
    }
    
    @objc private func didTapConfigureButton() {
        let vc = ConfigureSessionVC(model: model) { [weak self] () in
            guard let self else { return }
            if !self.isGameComplete() {
                self.navigationController?.popViewController(animated: true)
            }
        }
        vc.isEditable = navigationController?.topViewController == self ? true : false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @discardableResult
    private func isGameComplete() -> Bool {
        guard let winner = model.winner else {
            return false
        }
        storageViewModel.saveSession(model)
        
        let vc = WinnerVC(winner: winner) { [weak self] () in
            guard let self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
        return true
    }
    
    private func didCompleteCycle() {
        if !isGameComplete() {
            changeState()
        }
    }
    
    @objc private func didTabStartButton() {
        switch state {
        case .day:
            let dayVC = DayVC(model: model) { [weak self] dayModel in
                guard let self else { return }
                self.navigationController?.popToViewController(self, animated: true)
                self.model.days.append(dayModel)
                self.didCompleteCycle()
            }
            navigationController?.pushViewController(dayVC, animated: true)
            
        case .night:
            let nightVC = NightVC(model: model) { [weak self] nightModel in
                guard let self else { return }
                self.navigationController?.popToViewController(self, animated: true)
                self.model.nights.append(nightModel)
                self.didCompleteCycle()
            }
            nightVC.start()
            navigationController?.pushViewController(nightVC, animated: true)
        }
    }
    
    private func changeState() {
        state = state == .day ? .night : .day
        storageViewModel.saveSession(model)
    }

    private func didChangeState() {
        model.dayNightCycleType = state
        switch state {
        case .day:
            stateLabel.text = "Утро"
        case .night:
            stateLabel.text = "Ночь"
        }
    }
}

extension DayNightCicleVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard navigationController.viewControllers.contains(self) else { return }
        guard !navigationController.viewControllers.contains(where: { vc in
            vc is ConfigureSessionVC
        }) else { return }
        addConfigurationButtonItem(to: viewController.navigationItem)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return TransitionManager(direction: .present)
        case .pop:
            return TransitionManager(direction: .dismiss)
        default:
            return nil
        }
    }
}
