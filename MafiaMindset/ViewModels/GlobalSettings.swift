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

class GlobalSettings {
    static var shared: GlobalSettings {
        GlobalSettings.loadGlobalSettings
    }
    
    var globalDiscussionSeconds: TimeInterval = 60 * 3
    var playerDiscussionSeconds: TimeInterval = 60
    var votedPlayerDiscussionSeconds: TimeInterval = 30
    var kickedPlayerDiscussionSeconds: TimeInterval = 60
    var discussionOrder: DiscussionOrder = .globalDiscussionThenPlayer
    var unusedVotesToLastPlayer: Bool = true
    var disableVibration = false
    
    static var loadGlobalSettings: GlobalSettings {
        let r = GlobalSettings()
        let config = Realm.Configuration(
            schemaVersion: 2)
        guard let realm = try? Realm(configuration: config) else { return r }
        guard let stored = realm.objects(StorageGlobalSettings.self).first else { return r }
        
        r.disableVibration = stored.disableVibration
        r.unusedVotesToLastPlayer = stored.unusedVotesToLastPlayer
        r.discussionOrder = DiscussionOrder(rawValue: stored.discussionOrder) ?? r.discussionOrder
        r.globalDiscussionSeconds = stored.globalDiscussionSeconds
        r.playerDiscussionSeconds = stored.playerDiscussionSeconds
        r.votedPlayerDiscussionSeconds = stored.votedPlayerDiscussionSeconds
        r.kickedPlayerDiscussionSeconds = stored.kickedPlayerDiscussionSeconds
        
        return r
    }
    
    func copy() -> GlobalSettings {
        let r = GlobalSettings()
        
        r.disableVibration = disableVibration
        r.unusedVotesToLastPlayer = unusedVotesToLastPlayer
        r.discussionOrder = discussionOrder
        r.globalDiscussionSeconds = globalDiscussionSeconds
        r.playerDiscussionSeconds = playerDiscussionSeconds
        r.votedPlayerDiscussionSeconds = votedPlayerDiscussionSeconds
        r.kickedPlayerDiscussionSeconds = kickedPlayerDiscussionSeconds
        
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
    @Persisted var kickedPlayerDiscussionSeconds: TimeInterval = 60
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
        r.kickedPlayerDiscussionSeconds = gs.kickedPlayerDiscussionSeconds

        return r
    }
}
