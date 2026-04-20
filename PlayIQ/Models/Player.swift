import Foundation

struct Player: Codable, Identifiable {
    let id: UUID
    let username: String
    let displayName: String
    let avatar: String
    var cumulativeIQ: Int
    var totalSessions: Int

    enum CodingKeys: String, CodingKey {
        case id, username
        case displayName = "display_name"
        case avatar
        case cumulativeIQ = "cumulative_iq"
        case totalSessions = "total_sessions"
    }

    init(id: UUID = UUID(), username: String, displayName: String, avatar: String = "default", cumulativeIQ: Int = 0, totalSessions: Int = 0) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatar = avatar
        self.cumulativeIQ = cumulativeIQ
        self.totalSessions = totalSessions
    }

    static let guest = Player(
        username: "guest",
        displayName: "Guest",
        avatar: "default",
        cumulativeIQ: 0,
        totalSessions: 0
    )
}

struct PlayerLoginRequest: Codable {
    let username: String
}

struct PlayerCreateRequest: Codable {
    let username: String
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case username
        case displayName = "display_name"
    }
}

struct SessionCreate: Codable {
    let playerId: UUID
    let tier: String
    let sport: String

    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case tier, sport
    }
}

struct SessionResult: Codable {
    let scenarioId: String
    let iqEarned: Int
    let result: String
    let decisions: [DecisionRecord]

    enum CodingKeys: String, CodingKey {
        case scenarioId = "scenario_id"
        case iqEarned = "iq_earned"
        case result, decisions
    }
}

struct DecisionRecord: Codable, Identifiable {
    var id: String { nodeId }
    let nodeId: String
    let choiceId: String
    let result: String
    let iqPoints: Int

    enum CodingKeys: String, CodingKey {
        case nodeId = "node_id"
        case choiceId = "choice_id"
        case result
        case iqPoints = "iq_points"
    }
}

struct GameSession: Codable, Identifiable {
    let id: UUID
    let playerId: UUID
    let tier: String
    let sport: String
    var totalIQ: Int
    var scenariosCompleted: Int

    enum CodingKeys: String, CodingKey {
        case id
        case playerId = "player_id"
        case tier, sport
        case totalIQ = "total_iq"
        case scenariosCompleted = "scenarios_completed"
    }
}
