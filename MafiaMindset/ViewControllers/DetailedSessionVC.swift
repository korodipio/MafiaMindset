//
//  DetailedSessionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 30.08.23.
//

import UIKit

class DetailedSessionVC: UIViewController {

    var isContinuable = false {
        didSet {
            sessionView.isContinuable = isContinuable
        }
    }
    private let continueSession: (SessionModel) -> Void
    private let model: SessionModel
    private let tableView = UITableView()
    private let sessionView = SessionView()
    private var isPresented = false
    private var cells: [UITableViewCell] = []
    
    init(model: SessionModel, continueSession: @escaping (SessionModel) -> Void) {
        self.model = model
        self.continueSession = continueSession
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
        title = "Детальный отчет"
        view.backgroundColor = .secondarySystemBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.constraintToParent()
        
        sessionView.model = model
        sessionView.type = .full
        sessionView.continueSession = { [weak self] () in
            guard let self else { return }
            self.continueSession(self.model)
        }
        
        handleData()
    }
    
    private func handleData() {
        let sessionCell = GenericTableViewCell()
        sessionCell.contentView.addSubview(sessionView)
        sessionView.constraintToParent()
        cells.append(sessionCell)
        
        struct Data {
            var model: Any?
            var type: SessionType
            var unixDateCreated: TimeInterval
        }
        var data: [Data] = []
        data.append(contentsOf: model.nights.compactMap({ night in
            return night.unixDateCreated != 0 ? Data(model: night, type: .night, unixDateCreated: night.unixDateCreated) : nil
        }))
        data.append(contentsOf: model.days.compactMap({ day in
            return day.unixDateCreated != 0 ? Data(model: day, type: .day, unixDateCreated: day.unixDateCreated) : nil
        }))
        data.sort { v1, v2 in
            v1.unixDateCreated < v2.unixDateCreated
        }
        cells.append(contentsOf: data.compactMap({ data in
            guard let model = data.model else { return nil }
            
            switch data.type {
            case .day:
                let cell = DetailedSessionTableViewCell(model: model, type: .day)
                cell.title = "День от \(Date(timeIntervalSince1970: data.unixDateCreated).formatted())"
                return cell
            case .night:
                let cell = DetailedSessionTableViewCell(model: model, type: .night)
                cell.title = "Ночь от \(Date(timeIntervalSince1970: data.unixDateCreated).formatted())"
                return cell
            }
        }))
    }
}

extension DetailedSessionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        12
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        cells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cells[indexPath.section]
        
        if !isPresented {
            cell.alpha = 0
            cell.transform = .init(translationX: 0, y: 20)
            let duration = 0.25
            UIView.animate(withDuration: duration, delay: duration * Double(indexPath.section) * 0.2, options: .curveEaseInOut) {
                cell.alpha = 1
                cell.transform = .identity
            }
        }
        
        return cell
    }
}
