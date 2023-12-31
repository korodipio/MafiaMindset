//
//  StorageModels.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 17.08.23.
//

import RealmSwift

class StorageNightModel: Object {
    @Persisted var unixDateCreated: TimeInterval = 0
    @Persisted var mafia: Int?
    @Persisted var boss: Int?
    @Persisted var maniac: Int?
    @Persisted var commissar: Int?
    @Persisted var patrol: Int?
    @Persisted var bloodhound: Int?
    @Persisted var medic: Int?
    @Persisted var lover: Int?
    @Persisted var dies = List<Int>()
}

class StorageDayVoteModel: Object {
    @Persisted var by: Int = 0
    @Persisted var to: Int = 0
    @Persisted var voteCount: Int = 0
}

class StorageDayModel: Object {
    @Persisted var unixDateCreated: TimeInterval = 0
    @Persisted var kickedPlayers = List<Int>()
    @Persisted var votedPlayers = List<StorageDayVoteModel>()
    @Persisted var nonVotedPlayersCount: Int = 0
}

class StorageSessionModel: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var unixDateCreated: TimeInterval = Date().timeIntervalSince1970
    @Persisted var mafCount: Int = 0
    @Persisted var bossCount: Int = 0
    @Persisted var wolfCount: Int = 0
    @Persisted var medicCount: Int = 0
    @Persisted var commissarCount: Int = 0
    @Persisted var patrolCount: Int = 0
    @Persisted var maniacCount: Int = 0
    @Persisted var bloodhoundCount: Int = 0
    @Persisted var loverCount: Int = 0
    @Persisted var civCount: Int = 0
    @Persisted var players = Map<String, String>()
    @Persisted var kickedPlayers = List<Int>()
    @Persisted var deadPlayers = List<Int>()
    @Persisted var days = List<StorageDayModel>()
    @Persisted var nights = List<StorageNightModel>()
    @Persisted var dayNightCycleType: Int?
}
