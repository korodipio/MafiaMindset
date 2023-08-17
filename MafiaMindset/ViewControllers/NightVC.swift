//
//  NightVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 12.08.23.
//

import UIKit

class NightVC: UIViewController {

    private let onComplete: (NightModel) -> Void
    private let model: SessionModel
    private var nightView: NightView!
    
    init(model: SessionModel, onComplete: @escaping (NightModel) -> Void) {
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
        title = "Ночь"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.hidesBackButton = true
        
        nightView = .init(model: model) { [weak self] nightModel in
            self?.nightCompleted(nightModel)
        }
        view.addSubview(nightView)
        nightView.constraintToParent()
        nightView.start()
    }
    
    private func nightCompleted(_ nightModel: NightModel) {
        model.nights.append(nightModel)
        showResult(for: nightModel)
    }
    
    private func showResult(for nightModel: NightModel) {
        let vc = NightResultVC(onComplete: { [weak self] () in
            guard let self else { return }
            self.onComplete(self.nightView.nightModel)
        }, nightModel: nightModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func start() {
        nightView?.start()
    }
}
