import Foundation

struct Scenario: Codable, Identifiable {
    let id: String
    let title: String
    let sport: [String]?
    let tier: String?
    let role: String
    let tags: [String]?
    let setup: GameSetup
    let nodes: [String: ScenarioNode]
}

struct GameSetup: Codable {
    let inning: Int
    let topBottom: String
    let outs: Int
    let score: Score
    let runners: Runners

    // JSON keys are already camelCase, no mapping needed
}

struct Score: Codable {
    let home: Int
    let away: Int
}

struct Runners: Codable {
    let first: Bool
    let second: Bool
    let third: Bool

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
}
