import UIKit
import RealmSwift

enum SessionRoleId: String, CaseIterable {
    static let roleWakeUpOrder: [SessionRoleId] = [.maf, .boss, .wolf, .maniac, .commissar, .patrol, .bloodhound, .medic, .civ]
    
    case civ = "Civilian"
    case maf = "Mafia"
    case wolf = "Wolf"
    case boss = "Boss"
    case medic = "Medic"
    case commissar = "Commissar"
    case patrol = "Patrol"
    case maniac = "Maniac"
    case bloodhound = "Bloodhound"
    
    var title: String {
        switch self {
        case .civ:
            return "Мирный"
        case .maf:
            return "Мафия"
        case .wolf:
            return "Оборотень"
        case .boss:
            return "Босс мафии"
        case .medic:
            return "Доктор"
        case .commissar:
            return "Комиссар"
        case .patrol:
            return "Патрульный"
        case .maniac:
            return "Маньяк"
        case .bloodhound:
            return "Ищейка"
        }
    }
}

struct RolePlayers {
    var role: SessionRoleId
    var players: [Int]
}

enum DayNightCycleType: Int {
    case day = 0
    case night
}

class NightModel {
    var mafia: Int?
    var boss: Int?
    var maniac: Int?
    var commissar: Int?
    var patrol: Int?
    var bloodhound: Int?
    var medic: Int?
    
    var dies: [Int] = []
}

class DayVoteModel {
    var by: Int = 0
    var to: Int = 0
}

class DayModel {
    var votedPlayerCount: Int {
        var votedPlayersCount = 0
        numberOfVote.forEach { v1 in
            votedPlayersCount += v1.value
        }
        return votedPlayersCount
    }
    
    var numberOfVote: [Int: Int] = [:]
    var votedPlayers: [DayVoteModel] = []
    var kickedPlayers: [Int] = []
    var nonVotedPlayersCount: Int = 0
}

class SessionModel {
    var id: String?
    var unixDateCreated = Date().timeIntervalSince1970
    
    var dayNightCycleType: DayNightCycleType = .night
    var nights: [NightModel] = []
    var days: [DayModel] = []
    var deadPlayers: [Int] = []
    var kickedPlayers: [Int] = []
    
    // [PlayerIndex: Role]
    var players: [Int: SessionRoleId] = [:]
    // [Role: [PlayerIndex]]
    var roleAndPlayers: [SessionRoleId: [Int]] {
        var r: [SessionRoleId: [Int]] = [:]
        players.forEach { (index: Int, role: SessionRoleId?) in
            guard let role else { return }
            var indecies = r[role] ?? []
            indecies.append(index)
            r[role] = indecies
        }
        return r
    }
    // Alive [Role: [PlayerIndex]]
    var aliveRolePlayers: [SessionRoleId: [Int]] {
        var r: [SessionRoleId: [Int]] = [:]
        roleAndPlayers.forEach { v1 in
            let pl = Set(v1.value).subtracting(deadPlayers + kickedPlayers)
            r[v1.key] = Array<Int>(pl)
        }
        return r
    }
    // Alive players count
    var alivePlayersCount: Int {
        var count = 0
        aliveRolePlayers.forEach({ v1 in
            count += v1.value.count
        })
        return count
    }
    
    var isAnyMafiaOrBossDeadOrKicked: Bool {
        let pl = Set((roleAndPlayers[.maf] ?? []) + (roleAndPlayers[.boss] ?? []))
        return pl != pl.subtracting(deadPlayers + kickedPlayers)
    }
    var isCommissarAlive: Bool {
        guard commissarCount > 0 else { return false }
        let pl = Set(roleAndPlayers[.commissar] ?? [])
        return pl == pl.subtracting(deadPlayers + kickedPlayers)
    }
    
    var winner: SessionRoleId? {
        let mafRoles: [SessionRoleId] = [.maf, .boss, .wolf]
        let inactiveRoles: [SessionRoleId] = [.medic, .commissar, .patrol, .bloodhound, .civ]
        
        let alive = aliveRolePlayers
        
        var aliveMaf = 0
        alive.forEach { v1 in
            if mafRoles.contains(v1.key) {
                aliveMaf += v1.value.count
            }
        }
        var inactives = 0
        alive.forEach { v1 in
            if inactiveRoles.contains(v1.key) {
                inactives += v1.value.count
            }
        }
        let aliveManiac = alive[.maniac]?.count ?? 0
        let actives = aliveMaf + aliveManiac
        
        if actives >= inactives {
            if aliveManiac == 0 {
                return .maf
            }
        }
        if ((actives + inactives) - aliveManiac) == aliveManiac {
            return .maniac
        }
        if actives == 0 {
            return .civ
        }
        
        return nil
    }
    
    var mafCount: Int = 0
    var bossCount: Int = 0
    var wolfCount: Int = 0
    var medicCount: Int = 0
    var commissarCount: Int = 0
    var patrolCount: Int = 0
    var maniacCount: Int = 0
    var bloodhoundCount: Int = 0
    var civCount: Int = 0
    
    func copy() -> SessionModel {
        let m = SessionModel()
        m.players = players
        m.mafCount = mafCount
        m.wolfCount = wolfCount
        m.bossCount = bossCount
        m.medicCount = medicCount
        m.commissarCount = commissarCount
        m.patrolCount = patrolCount
        m.maniacCount = maniacCount
        m.bloodhoundCount = bloodhoundCount
        m.civCount = civCount
        return m
    }
    
    var activeCount: Int {
        mafCount + bossCount + wolfCount + medicCount + commissarCount + patrolCount + maniacCount + bloodhoundCount
    }
    var totalCount: Int {
        mafCount + bossCount + wolfCount + medicCount + commissarCount + patrolCount + maniacCount + bloodhoundCount + civCount
    }
    
    var isWolfWakedUp = false
    var isPatrolWakedUp = false
    var isMafExists: Bool {
        mafCount != 0
    }
    var isCivExists: Bool {
        civCount != 0
    }
    var isBossExists: Bool {
        get { bossCount != 0 }
        set { bossCount = newValue ? 1 : 0 }
    }
    var isWolfExists: Bool {
        get { wolfCount != 0 }
        set { wolfCount = newValue ? 1 : 0 }
    }
    var isMedicExists: Bool {
        get { medicCount != 0 }
        set { medicCount = newValue ? 1 : 0 }
    }
    var isCommisarExists: Bool {
        get { commissarCount != 0 }
        set { commissarCount = newValue ? 1 : 0 }
    }
    var isPatrolExists: Bool {
        get { patrolCount != 0 }
        set { patrolCount = newValue ? 1 : 0 }
    }
    var isManiacExists: Bool {
        get { maniacCount != 0 }
        set { maniacCount = newValue ? 1 : 0 }
    }
    var isBloodhoundExists: Bool {
        get { bloodhoundCount != 0 }
        set { bloodhoundCount = newValue ? 1 : 0 }
    }
}
