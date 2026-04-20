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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        displayName = try container.decode(String.self, forKey: .displayName)
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar) ?? "default"
        cumulativeIQ = try container.decodeIfPresent(Int.self, forKey: .cumulativeIQ) ?? 0
        totalSessions = try container.decodeIfPresent(Int.self, forKey: .totalSessions) ?? 0
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
    let tokensEarned: Int
    let multiplier: Int
    let category: String
    let whatToRemember: String?

    enum CodingKeys: String, CodingKey {
        case nodeId = "node_id"
        case choiceId = "choice_id"
        case result
        case iqPoints = "iq_points"
        case tokensEarned = "tokens_earned"
        case multiplier
        case category
        case whatToRemember = "what_to_remember"
    }

    init(nodeId: String, choiceId: String, result: String, iqPoints: Int, tokensEarned: Int = 0, multiplier: Int = 1, category: String = "general", whatToRemember: String? = nil) {
        self.nodeId = nodeId
        self.choiceId = choiceId
        self.result = result
        self.iqPoints = iqPoints
        self.tokensEarned = tokensEarned
        self.multiplier = multiplier
        self.category = category
        self.whatToRemember = whatToRemember
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

// MARK: - Profile API Models

struct PlayerProfile: Codable {
    let id: UUID
    let username: String
    let displayName: String
    let avatar: String
    let cumulativeIQ: Int
    let totalSessions: Int
    let categories: [CategoryMastery]?

    enum CodingKeys: String, CodingKey {
        case id, username, avatar, categories
        case displayName = "display_name"
        case cumulativeIQ = "cumulative_iq"
        case totalSessions = "total_sessions"
    }
}

struct CategoryMastery: Codable, Identifiable {
    var id: String { category }
    let category: String
    let total: Int
    let great: Int?
    let good: Int?
    let okay: Int?
    let bad: Int?

    var greatGoodCount: Int {
        (great ?? 0) + (good ?? 0)
    }

    var percentage: Int {
        total > 0 ? Int(round(Double(greatGoodCount) / Double(total) * 100)) : 0
    }
}

struct PlayerAward: Codable, Identifiable {
    var id: String { awardName }
    let awardName: String
    let earnedAt: String?

    enum CodingKeys: String, CodingKey {
        case awardName = "award_name"
        case earnedAt = "earned_at"
    }
}

struct SessionHistory: Codable, Identifiable {
    let id: UUID
    let tier: String?
    let grade: String?
    let totalIQ: Int?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, tier, grade
        case totalIQ = "total_iq"
        case createdAt = "created_at"
    }
}
