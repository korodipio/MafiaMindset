import UIKit
import RealmSwift

enum SessionRoleId: String, CaseIterable {
    static let roleWakeUpOrder: [SessionRoleId] = [.lover, .maf, .boss, .wolf, .maniac, .commissar, .patrol, .bloodhound, .medic, .civ]
    
    case civ = "Civilian"
    case maf = "Mafia"
    case wolf = "Wolf"
    case boss = "Boss"
    case medic = "Medic"
    case commissar = "Commissar"
    case patrol = "Patrol"
    case maniac = "Maniac"
    case bloodhound = "Bloodhound"
    case lover = "Lover"
    
    var image: UIImage? {
        switch self {
        case .civ:
            return .init(named: "civilian.png")
        case .maf, .boss:
            return .init(named: "mafia.png")
        case .wolf:
            return .init(named: "wolf.png")
        case .maniac:
            return .init(named: "maniac.png")
        case .medic:
            return .init(named: "medic.png")
        case .lover:
            return .init(named: "lover.png")
        case .commissar, .patrol:
            return .init(named: "commissar.png")
        case .bloodhound:
            return .init(named: "loupe.png")
        }
    }
    
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
        case .lover:
            return "Любовница"
        }
    }
    
    var description: String {
        switch self {
        case .civ:
            return "Просыпается днем и ищет мафию"
        case .maf:
            return "Просыпается ночью и выбирает жертву"
        case .wolf:
            return "Превращается в мафию после исключения первой мафии, до этого мирный"
        case .boss:
            return "Просыпается ночью и ищет комиссара"
        case .medic:
            return "Просыпается ночью и лечит любого игрока, лечить дважды одного и того же нельзя"
        case .commissar:
            return "Просыпается ночью и ищет мафию"
        case .patrol:
            return "Превращается в комиссара после его выхода из игры"
        case .maniac:
            return "Просыпается ночью и выбирает жертву"
        case .bloodhound:
            return "Просыпается ночью и ищет маньяка"
        case .lover:
            return "Просыпается ночью и забирает любого игрока на ночь, который позже не голосует, а также его нельзя убить ночью. Забирать дважды одного и того же нельзя"
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
    var unixDateCreated = Date().timeIntervalSince1970
    
    var mafia: Int?
    var boss: Int?
    var maniac: Int?
    var commissar: Int?
    var patrol: Int?
    var bloodhound: Int?
    var medic: Int?
    var lover: Int?
    
    var dies: [Int] = []
}

class DayVoteModel {
    var by: Int = 0
    var to: Int = 0
    var voteCount: Int = 0
}

class DayModel {
    var votedPlayerCount: Int {
        var votedPlayersCount = 0
        votedPlayers.forEach { v1 in
            votedPlayersCount += v1.voteCount
        }
        return votedPlayersCount
    }

    var unixDateCreated = Date().timeIntervalSince1970
    
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
    
    func isAlive(role: SessionRoleId) -> Bool {
        guard let rpl = roleAndPlayers[role] else { return false }
        let pl = Set(rpl)
        return pl == pl.subtracting(deadPlayers + kickedPlayers)
    }

    var winner: SessionRoleId? {
        let mafRoles: [SessionRoleId] = [.maf, .boss, .wolf]
        let inactiveRoles: [SessionRoleId] = [.lover, .medic, .commissar, .patrol, .bloodhound, .civ]
        
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
        
        if aliveMaf > aliveManiac && inactives == 0 {
            return .maf
        }
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
    var loverCount: Int = 0
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
        m.loverCount = loverCount
        m.civCount = civCount
        return m
    }
    
    var activeCount: Int {
        mafCount + bossCount + wolfCount + medicCount + commissarCount + patrolCount + maniacCount + bloodhoundCount + loverCount
    }
    var totalCount: Int {
        mafCount + bossCount + wolfCount + medicCount + commissarCount + patrolCount + maniacCount + bloodhoundCount + loverCount + civCount
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
    var isLoverExists: Bool {
        get { loverCount != 0 }
        set { loverCount = newValue ? 1 : 0 }
    }
}
