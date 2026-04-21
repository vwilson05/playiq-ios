import Foundation

struct Scenario: Codable, Identifiable {
    let id: String
    let title: String
    let sport: [String]?
    let tier: String?
    let impact: Int?
    let role: String
    let tags: [String]?
    let setup: GameSetup
    let nodes: [String: ScenarioNode]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        sport = try container.decodeIfPresent([String].self, forKey: .sport)
        tier = try container.decodeIfPresent(String.self, forKey: .tier)
        impact = try container.decodeIfPresent(Int.self, forKey: .impact)
        role = try container.decode(String.self, forKey: .role)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        setup = try container.decodeIfPresent(GameSetup.self, forKey: .setup) ?? GameSetup()
        nodes = try container.decode([String: ScenarioNode].self, forKey: .nodes)
    }

    /// Impact multiplier for token calculation (1-5x).
    /// Uses the JSON `impact` field if present, otherwise calculates from game setup.
    var tokenMultiplier: Int {
        if let impact = impact, impact >= 1 { return min(impact, 5) }
        return Self.calcImpact(from: setup)
    }

    static func calcImpact(from setup: GameSetup) -> Int {
        // Non-baseball scenarios default to 1x if no setup context
        guard setup.inning > 0 else { return 1 }
        var impact: Double = 1
        if setup.inning >= 9 { impact += 2 }
        else if setup.inning >= 7 { impact += 1 }
        let scoreDiff = abs(setup.score.home - setup.score.away)
        if scoreDiff <= 1 { impact += 1 }
        else if scoreDiff <= 2 { impact += 0.5 }
        if setup.runners.second || setup.runners.third { impact += 1 }
        if setup.outs == 2 { impact += 0.5 }
        return min(Int(impact.rounded()), 5)
    }

    var multiplierLabel: String? {
        let m = tokenMultiplier
        if m >= 5 { return "Game-Changing Moment" }
        if m >= 4 { return "Clutch Time" }
        if m >= 3 { return "Big Decision" }
        if m >= 2 { return "Key Play" }
        return nil
    }
}

struct GameSetup: Codable {
    let inning: Int
    let topBottom: String
    let outs: Int
    let score: Score
    let runners: Runners
    let context: String?

    init(inning: Int = 0, topBottom: String = "", outs: Int = 0, score: Score = Score(home: 0, away: 0), runners: Runners = Runners(first: false, second: false, third: false), context: String? = nil) {
        self.inning = inning
        self.topBottom = topBottom
        self.outs = outs
        self.score = score
        self.runners = runners
        self.context = context
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        inning = try container.decodeIfPresent(Int.self, forKey: .inning) ?? 0
        topBottom = try container.decodeIfPresent(String.self, forKey: .topBottom) ?? ""
        outs = try container.decodeIfPresent(Int.self, forKey: .outs) ?? 0
        score = try container.decodeIfPresent(Score.self, forKey: .score) ?? Score(home: 0, away: 0)
        runners = try container.decodeIfPresent(Runners.self, forKey: .runners) ?? Runners(first: false, second: false, third: false)
        context = try container.decodeIfPresent(String.self, forKey: .context)
    }
}

struct Score: Codable {
    let home: Int
    let away: Int

    init(home: Int = 0, away: Int = 0) {
        self.home = home
        self.away = away
    }
}

struct Runners: Codable {
    let first: Bool
    let second: Bool
    let third: Bool

    init(first: Bool = false, second: Bool = false, third: Bool = false) {
        self.first = first
        self.second = second
        self.third = third
    }

    var description: String {
        var positions: [String] = []
        if first { positions.append("1st") }
        if second { positions.append("2nd") }
        if third { positions.append("3rd") }
        return positions.isEmpty ? "Bases empty" : "Runners on \(positions.joined(separator: ", "))"
    }

    var hasAny: Bool {
        first || second || third
    }
}

struct ScenarioNode: Codable {
    let type: String  // "decision", "transition", "outcome"
    let narration: String?
    let choices: [Choice]?
    let outcome: Outcome?
    let next: String?
    let delay: Int?
}

struct Choice: Codable, Identifiable {
    let id: String
    let text: String
    let nextNode: String
    let onlyIn: String?
    let disabledReason: String?

    // JSON keys are already camelCase, no mapping needed
}

struct Outcome: Codable {
    let result: String  // great, good, okay, bad
    let headline: String
    let explanation: String
    let whatToRemember: String
    let iqPoints: Int
    let keyTerms: [KeyTerm]?
    let next: String?

    // JSON keys are already camelCase, no mapping needed

    var resultColor: String {
        switch result.lowercased() {
        case "great": return "resultGreat"
        case "good": return "resultGood"
        case "okay": return "resultOkay"
        case "bad": return "resultBad"
        default: return "resultGood"
        }
    }
}

struct KeyTerm: Codable, Identifiable {
    var id: String { term }
    let term: String
    let definition: String
}

struct ScenarioListItem: Codable, Identifiable {
    let id: String
    let title: String
    let tier: String?
    let role: String?
    let tags: [String]?
    let sport: [String]?
}
