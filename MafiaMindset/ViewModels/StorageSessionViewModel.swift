//
//  StorageSessionViewModel.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 17.08.23.
//

import RealmSwift

class StorageSessionViewModel {
    private var realm: Realm!
    
    init() {
        realm = try! Realm(configuration: Realm.Configuration(
            schemaVersion: 8))
    }
    
    private func getDaysFromStorage(_ sm: StorageSessionModel) -> [DayModel] {
        sm.days.compactMap { sd in
            let d = DayModel()
            sd.kickedPlayers.forEach { ind in
                d.kickedPlayers.append(ind)
            }
            sd.votedPlayers.forEach { voteModel in
                let m = DayVoteModel()
                m.by = voteModel.by
                m.to = voteModel.to
                m.voteCount = voteModel.voteCount
                d.votedPlayers.append(m)
            }
            d.nonVotedPlayersCount = sd.nonVotedPlayersCount
            d.unixDateCreated = sd.unixDateCreated
            return d
        }
    }
    
    private func getNightsFromStorage(_ sm: StorageSessionModel) -> [NightModel] {
        sm.nights.compactMap { sn in
            let n = NightModel()
            n.mafia = sn.mafia
            n.boss = sn.boss
            n.maniac = sn.maniac
            n.lover = sn.lover
            n.commissar = sn.commissar
            n.patrol = sn.patrol
            n.bloodhound = sn.bloodhound
            n.medic = sn.medic
            n.lover = sn.lover
            n.unixDateCreated = sn.unixDateCreated
            sn.dies.forEach { ind in
                n.dies.append(ind)
            }
            return n
        }
    }
    
    func loadSessions() -> [SessionModel] {
        realm.objects(StorageSessionModel.self).compactMap { sm in
            let s = SessionModel()
            s.id = sm._id.stringValue
            s.dayNightCycleType = sm.dayNightCycleType == nil ? .night : DayNightCycleType(rawValue: sm.dayNightCycleType!)!
            s.unixDateCreated = sm.unixDateCreated
            s.mafCount = sm.mafCount
            s.bossCount = sm.bossCount
            s.wolfCount = sm.wolfCount
            s.medicCount = sm.medicCount
            s.commissarCount = sm.commissarCount
            s.patrolCount = sm.patrolCount
            s.maniacCount = sm.maniacCount
            s.loverCount = sm.loverCount
            s.bloodhoundCount = sm.bloodhoundCount
            s.civCount = sm.civCount
            s.days = getDaysFromStorage(sm)
            s.nights = getNightsFromStorage(sm)
            sm.players.forEach { e in
                s.players[Int(e.key)!] = .init(rawValue: e.value)
            }
            sm.deadPlayers.forEach { ind in
                s.deadPlayers.append(ind)
            }
            sm.kickedPlayers.forEach { ind in
                s.kickedPlayers.append(ind)
            }
            
            return s
        }
    }
    
    private func getDaysForStorage(from s: SessionModel) -> List<StorageDayModel> {
        let l = List<StorageDayModel>()
        s.days.forEach { d in
            let sd = StorageDayModel()
            d.kickedPlayers.forEach { ind in
                sd.kickedPlayers.append(ind)
            }
            d.votedPlayers.forEach { voteModel in
                let sm = StorageDayVoteModel()
                sm.by = voteModel.by
                sm.to = voteModel.to
                sm.voteCount = voteModel.voteCount
                sd.votedPlayers.append(sm)
            }
            sd.nonVotedPlayersCount = d.nonVotedPlayersCount
            sd.unixDateCreated = d.unixDateCreated
            l.append(sd)
        }
        return l
    }
    
    private func getNightsForStorage(from s: SessionModel) -> List<StorageNightModel> {
        let l = List<StorageNightModel>()
        s.nights.forEach { n in
            let sn = StorageNightModel()
            sn.mafia = n.mafia
            sn.boss = n.boss
            sn.maniac = n.maniac
            sn.commissar = n.commissar
            sn.patrol = n.patrol
            sn.bloodhound = n.bloodhound
            sn.medic = n.medic
            sn.lover = n.lover
            sn.unixDateCreated = n.unixDateCreated
            n.dies.forEach { ind in
                sn.dies.append(ind)
            }
            l.append(sn)
        }
        return l
    }
    
    func saveSession(_ s: SessionModel) {
        let obj = StorageSessionModel()
        obj._id = s.id == nil ? .generate() : try! ObjectId(string: s.id!)
        obj.dayNightCycleType = s.dayNightCycleType.rawValue
        obj.unixDateCreated = s.unixDateCreated
        obj.mafCount = s.mafCount
        obj.bossCount = s.bossCount
        obj.wolfCount = s.wolfCount
        obj.medicCount = s.medicCount
        obj.commissarCount = s.commissarCount
        obj.patrolCount = s.patrolCount
        obj.maniacCount = s.maniacCount
        obj.bloodhoundCount = s.bloodhoundCount
        obj.civCount = s.civCount
        obj.nights = getNightsForStorage(from: s)
        obj.days = getDaysForStorage(from: s)
        s.players.forEach { (key: Int, value: SessionRoleId) in
            obj.players["\(key)"] = value.rawValue
        }
        s.deadPlayers.forEach { ind in
            obj.deadPlayers.append(ind)
        }
        s.kickedPlayers.forEach { ind in
            obj.kickedPlayers.append(ind)
        }
        
        try? realm.write({
            realm.add(obj, update: .modified)
        })
        s.id = obj._id.stringValue
    }
    
    func deleteSession(_ model: SessionModel) {
        guard let id = model.id, let objId = try? ObjectId(string: id) else { return }
        guard let obj = realm.object(ofType: StorageSessionModel.self, forPrimaryKey: objId) else { return }
        try? realm.write({
            realm.delete(obj)
        })
    }
}
