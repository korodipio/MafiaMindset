//
//  GlobalSettings.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 27.08.23.
//

import Foundation
import RealmSwift
import Combine

enum DiscussionOrder: String {
    case playersDiscussionThenGlobal
    case globalDiscussionThenPlayer
    
    var title: String {
        switch self {
        case .globalDiscussionThenPlayer:
            return "Общая дискуссия"
        case .playersDiscussionThenGlobal:
            return "Дискуссия игроков"
        }
    }
}

class GlobalSettings: ObservableObject {
    static let shared: GlobalSettings = {
       return GlobalSettings.loadGlobalSettings
    }()
    
    @Published var globalDiscussionSeconds: TimeInterval = 60 * 3
    @Published var playerDiscussionSeconds: TimeInterval = 60
    @Published var votedPlayerDiscussionSeconds: TimeInterval = 30
    @Published var discussionOrder: DiscussionOrder = .globalDiscussionThenPlayer
    @Published var unusedVotesToLastPlayer: Bool = true
    @Published var disableVibration = false
    
    private var cancellables: [AnyCancellable] = []
    private var ignoreChanges = false
    
    init() {
        objectWillChange.sink { [weak self] v in
            guard let self, !self.ignoreChanges else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.save()
            }
        }.store(in: &cancellables)
    }
    
    static var loadGlobalSettings: GlobalSettings {
        let r = GlobalSettings()
        guard let realm = try? Realm() else { return r }
        guard let stored = realm.objects(StorageGlobalSettings.self).first else { return r }
        
        r.ignoreChanges = true
        
        r.disableVibration = stored.disableVibration
        r.unusedVotesToLastPlayer = stored.unusedVotesToLastPlayer
        r.discussionOrder = DiscussionOrder(rawValue: stored.discussionOrder) ?? r.discussionOrder
        r.globalDiscussionSeconds = stored.globalDiscussionSeconds
        r.playerDiscussionSeconds = stored.playerDiscussionSeconds
        r.votedPlayerDiscussionSeconds = stored.votedPlayerDiscussionSeconds
        
        r.ignoreChanges = false

        return r
    }
    
    func save() {
        guard let realm = try? Realm() else { return }
    
        try! realm.write({
            realm.objects(StorageGlobalSettings.self).forEach { obj in
                realm.delete(obj)
            }
            
            realm.add(StorageGlobalSettings.fromGlobalSettings(self))
        })
    }
}

class StorageGlobalSettings: Object {
    @Persisted var globalDiscussionSeconds: TimeInterval = 60 * 3
    @Persisted var playerDiscussionSeconds: TimeInterval = 60
    @Persisted var votedPlayerDiscussionSeconds: TimeInterval = 30
    @Persisted var discussionOrder: String = DiscussionOrder.globalDiscussionThenPlayer.rawValue
    @Persisted var unusedVotesToLastPlayer: Bool = true
    @Persisted var disableVibration = false
    
    static func fromGlobalSettings(_ gs: GlobalSettings) -> StorageGlobalSettings {
        let r = StorageGlobalSettings()
        
        r.globalDiscussionSeconds = gs.globalDiscussionSeconds
        r.playerDiscussionSeconds = gs.playerDiscussionSeconds
        r.votedPlayerDiscussionSeconds = gs.votedPlayerDiscussionSeconds
        r.discussionOrder = gs.discussionOrder.rawValue
        r.unusedVotesToLastPlayer = gs.unusedVotesToLastPlayer
        r.disableVibration = gs.disableVibration

        return r
    }
}
