//
//  NightResultVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 12.08.23.
//

import UIKit

class NightResultVC: UIViewController {

    private let onComplete: () -> Void
    private let nightModel: NightModel
    private let tableView = UITableView()
    private var isPresented = false
    private var output: [String] = []
    private let doneButton = UIButton()
    private var buttonVC: ButtonVC!
    
    init(onComplete: @escaping () -> Void, nightModel: NightModel) {
        self.onComplete = onComplete
        self.nightModel = nightModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPresented = true
    }

    private func setupUi() {
        title = "Ночь. Результаты"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.constraintToParent()
        tableView.contentInset.bottom = 80
        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: LabelTableViewCell.identifier)
        
        buttonVC = .init(didTap: { [weak self] () in
            self?.didTapDoneButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Ок"

        handleData()
    }
    
    private func handleData() {
        if !nightModel.dies.isEmpty {
            let r = nightModel.dies
            var str = "Этой ночью умерли: "
            r.sorted().forEach { i in
                str += "\(i + 1),"
            }
            str.removeLast()
            output.append(str)
        } else {
            output.append("Этой ночью никто не умер")
        }
        if let r = nightModel.mafia {
            output.append("Выбор Мафии: \(r + 1)")
        }
        if let r = nightModel.boss {
            output.append("Выбор Босса: \(r + 1)")
        }
        if let r = nightModel.maniac {
            output.append("Выбор Маньяка: \(r + 1)")
        }
        if let r = nightModel.lover {
            output.append("Выбор Любовницы: \(r + 1)")
        }
        if let r = nightModel.commissar {
            output.append("Выбор Комиссара: \(r + 1)")
        }
        if let r = nightModel.patrol {
            output.append("Выбор Патрульного: \(r + 1)")
        }
        if let r = nightModel.bloodhound {
            output.append("Выбор Ищейки: \(r + 1)")
        }
        if let r = nightModel.medic {
            output.append("Выбор Доктора: \(r + 1)")
        }
        tableView.reloadData()
    }
    
    @objc private func didTapDoneButton() {
        onComplete()
    }
}

extension NightResultVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        12
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        output.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LabelTableViewCell.identifier, for: indexPath) as! LabelTableViewCell
        
        cell.title = output[indexPath.section]
        
        if !isPresented {
            cell.alpha = 0
            cell.transform = .init(translationX: 0, y: 20)
            let duration = 0.25
            UIView.animate(withDuration: duration, delay: duration * Double(indexPath.section) * 0.2, options: .curveEaseInOut) {
                cell.alpha = 1
                cell.transform = .identity
            }
        }
        
        if indexPath.section == 0 {
            let nightKill = !nightModel.dies.isEmpty
            cell.layer.shadowOpacity = 0.3
            cell.layer.shadowColor = nightKill ? UIColor.red.cgColor : UIColor.primary?.cgColor
        }
        else {
            cell.layer.shadowOpacity = 0
            cell.layer.shadowColor = nil
        }
        
        return cell
    }
}
