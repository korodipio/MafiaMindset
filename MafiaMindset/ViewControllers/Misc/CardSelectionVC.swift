//
//  CardSelectionVC.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 10.09.23.
//

import UIKit

class CardSelectionVC: UIViewController {

    private var roles: [SessionRoleId] = []
    private var selectedRole: SessionRoleId?
    private var collectionView: UICollectionView!
    private let onComplete: (SessionRoleId) -> Void
    private let impact = UIImpactFeedbackGenerator(style: .soft)
    private var lastVisibleItem: IndexPath?
    private var buttonVC: ButtonVC!
    
    private var specRoleViews: [UIView] = []
    private var specRoles: [SessionRoleId] = [.maf, .maniac, .commissar, .medic]
    private var specRoleActive: SessionRoleId?
    
    init(roles: [SessionRoleId], onComplete: @escaping (SessionRoleId) -> Void) {
        self.roles = roles
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
        title = "Выбор карты"
        view.backgroundColor = .secondarySystemBackground
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { sec, _ in
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            item.contentInsets = .init(top: 0, leading: 30, bottom: 0, trailing: 30)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.visibleItemsInvalidationHandler = { [weak self] items, offset, environment in
                guard let self else { return }
                
                var lowestDistanceFromCenter: CGFloat = .infinity
                var closestItem: IndexPath?
                items.forEach { item in
                    let off = (item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0
                    let distanceFromCenter = abs(off)
                    if distanceFromCenter < lowestDistanceFromCenter {
                        closestItem = item.indexPath
                        lowestDistanceFromCenter = distanceFromCenter
                    }
                    let minValue: CGFloat = 0.8
                    let maxValue: CGFloat = 1
                    let fraction = distanceFromCenter / environment.container.contentSize.width
                    let value = max(maxValue - fraction / 5, minValue)
                    
                    var transform = CATransform3DIdentity
                    transform.m34 = -1 / 700
                    transform = CATransform3DScale(transform, value, value, value)
                    transform = CATransform3DRotate(transform, fraction * 45 * CGFloat.pi / 180, 0, off > 0 ? -1 : 1, 0)
                    
                    item.transform3D = transform
                    item.alpha = value
                }
                if closestItem != self.lastVisibleItem {
                    self.lastVisibleItem = closestItem
                    self.impact.impactOccurred()
                }
            }
            
            return section
        }))
        
        let wrapper = UIView()
        wrapper.addSubview(collectionView)
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: wrapper.safeAreaLayoutGuide.centerYAnchor),
            collectionView.heightAnchor.constraint(equalTo: wrapper.widthAnchor, multiplier: 1.1),
            collectionView.widthAnchor.constraint(equalTo: wrapper.widthAnchor, multiplier: 1)
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(RotatingRoleCell.self, forCellWithReuseIdentifier: RotatingRoleCell.identifier)
        
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wrapper)
        NSLayoutConstraint.activate([
            wrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wrapper.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            wrapper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15)
        ])
    
        buttonVC = .init(didTap: { [weak self] () in
            guard let self else { return }
            didTapContinueButton()
        })
        add(buttonVC)
        buttonVC.buttonTitle = "Дальше"
        buttonVC.isVisible = false
        
        let specSV = UIStackView()
        specSV.axis = .horizontal
        specSV.distribution = .fillEqually
        specRoles.forEach { role in
            let v = UIView()
//            v.backgroundColor = .random()
            
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            v.addGestureRecognizer(gesture)
            gesture.minimumPressDuration = 0.5
            
            specSV.addArrangedSubview(v)
            specRoleViews.append(v)
        }
        specSV.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(specSV)
        NSLayoutConstraint.activate([
            specSV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            specSV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            specSV.heightAnchor.constraint(equalToConstant: 40),
            specSV.topAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
    }
    
    private func didTapContinueButton() {
        guard let selectedRole else { return }
        navigationController?.popViewController(animated: true)
        onComplete(selectedRole)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let view = gesture.view else { return }
        guard let index = specRoleViews.firstIndex(of: view) else { return }
        let role = specRoles[index]
        
        switch gesture.state {
        case .began:
            specRoleActive = role
        case .ended, .cancelled:
            specRoleActive = nil
        default:
            break
        }
    }
    
    func getSpecRole() -> SessionRoleId? {
        guard let specRoleActive else { return nil }
        return roles.contains(specRoleActive) ? specRoleActive : nil
    }
}

extension CardSelectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        roles.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? RotatingRoleCell else { return }
        cell.reset()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RotatingRoleCell.identifier, for: indexPath) as! RotatingRoleCell
        
        cell.configure(role: roles[indexPath.item])
        cell.delegate = self
        
        return cell
    }
}

extension CardSelectionVC: RotatingRoleProtocol {
    func willSelectRole(_ cell: RotatingRoleCell) {
        guard let role = getSpecRole() else { return }
        cell.configure(role: role)
    }
    
    func didSelectRole(role: SessionRoleId) {
        collectionView.isUserInteractionEnabled = false
        selectedRole = role
        buttonVC.isVisible = true
    }
}
