//
//  RootVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 09.08.23.
//

import UIKit

class RootVC: UIViewController {
    
    private var label: UILabel? = UILabel()
    private let storageViewModel = StorageSessionViewModel()
    private let tableView = UITableView()
    private var models: [SessionModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSessions(reload: true)
    }
    
    private func loadSessions(reload: Bool) {
        models = storageViewModel.loadSessions().sorted(by: { v1, v2 in
            v1.unixDateCreated > v2.unixDateCreated
        })
        if reload {
            tableView.reloadData()
        }
        if !models.isEmpty {
            label?.removeFromSuperview()
            label = nil
        }
    }
    
    private func deleteSession(_ model: SessionModel) {
        storageViewModel.deleteSession(model)
        loadSessions(reload: false)
    }
    
    private func setupUi() {
        title = "Игры"
        view.backgroundColor = .secondarySystemBackground
        
//        for _ in 0..<100 {
//            let model = SessionModel()
//            model.players = [0: .maf, 1: .civ, 2: .civ, 3: .wolf, 4: .boss, 5: .bloodhound, 6: .maniac, 7: .medic, 8: .maf]
//            model.deadPlayers = [0, 6]
//            model.mafCount = 1
//            model.bossCount = 1
//            model.civCount = 2
//            model.wolfCount = 1
//            model.bloodhoundCount = 1
//            model.maniacCount = 1
//            model.medicCount = 1
//            model.commissarCount = 1
//            model.patrolCount = 1
//            storageViewModel.saveSession(model)
//        }
//        loadSessions()
        
        let label = UILabel()
        view.addSubview(label)
        label.constraintToParent()
        label.font = .rounded(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label.withAlphaComponent(0.5)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = "Тут будут твои игры"
        self.label = label
        
        let navBarAppearance = UINavigationBarAppearance()
        let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.rounded(ofSize: 16, weight: .medium),]
        navBarAppearance.largeTitleTextAttributes = [.font: UIFont.rounded(ofSize: 24, weight: .bold)]
        navBarAppearance.titleTextAttributes = attributes
        navBarAppearance.buttonAppearance.normal.titleTextAttributes = attributes
        navBarAppearance.doneButtonAppearance.normal.titleTextAttributes = attributes
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(systemName: "plus"), style: .done, target: self, action: #selector(didTapCreateSessionButton))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.constraintToParent()
        tableView.contentInset.bottom = 80
        tableView.register(SessionTableViewCell.self, forCellReuseIdentifier: SessionTableViewCell.identifier)
    }
    
    @objc private func didTapCreateSessionButton() {
//        let model = SessionModel()
//        model.players = [0: .maf, 1: .civ, 2: .civ, 3: .wolf, 4: .boss, 5: .bloodhound, 6: .maniac, 7: .medic, 8: .maf]
//        model.deadPlayers = [0, 6]
//        model.mafCount = 1
//        model.bossCount = 1
//        model.civCount = 2
//        model.wolfCount = 1
//        model.bloodhoundCount = 1
//        model.maniacCount = 1
//        model.medicCount = 1
//        model.commissarCount = 1
//        model.patrolCount = 1
        
//        let vc = DayNightCicleVC(storageViewModel: storageViewModel, model: model)

        let vc = CreateSessionVC { [weak self] model in
            self?.createSessionWith(model)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createSessionWith(_ model: SessionModel) {
        let vc = CardAssignmentVC(onComplete: { [weak self] model in
            self?.startFirstNight(model)
        }, model: model)
        navigationController?.setViewControllers([self, vc], animated: true)
    }
    
    private func startFirstNight(_ model: SessionModel) {
        let vc = FirstNightVC(onComplete: { [weak self] model in
            self?.startFirstDay(model)
        }, model: model)
        navigationController?.setViewControllers([self, vc], animated: true)
    }
    
    private func startFirstDay(_ model: SessionModel) {
        let vc = FirstDayVC { [weak self] () in
            self?.startDayNight(model)
        }
        navigationController?.setViewControllers([self, vc], animated: true)
    }
    
    private func startDayNight(_ model: SessionModel) {
        let vc = DayNightCicleVC(storageViewModel: storageViewModel, model: model)
        navigationController?.setViewControllers([self, vc], animated: true)
    }
}

extension RootVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        12
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SessionTableViewCell.identifier, for: indexPath) as! SessionTableViewCell
        
        let model = models[indexPath.section]
        cell.model = model
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.section]
        guard model.winner == nil else { return }
        
        startDayNight(model)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let model = models[indexPath.section]

        deleteSession(model)
        tableView.deleteSections([indexPath.section], with: .automatic)
    }
}

