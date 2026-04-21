import Foundation
import SwiftUI

@MainActor
final class GameState: ObservableObject {
    @Published var selectedTeam: MLBTeam?
    @Published var selectedSoftballTeam: SoftballTeam?
    @Published var selectedTier: String?
    @Published var selectedSport: String?
    @Published var currentScenario: Scenario?
    @Published var currentNodeId: String?
    @Published var history: [DecisionRecord] = []
    @Published var totalIQ: Int = 0
    @Published var totalTokens: Int = 0
    @Published var scenariosCompleted: Int = 0
    @Published var sessionComplete: Bool = false
    @Published var currentSession: GameSession?
    @Published var isLoadingScenario: Bool = false
    @Published var showMenu: Bool = false
    @Published var showProfile: Bool = false
    @Published var scenarioList: [ScenarioListItem] = []
    @Published var scenarioIndex: Int = 0

    let scenariosPerRound = 5
    var sessionPlayedIds: [String] = []

    private let apiClient = APIClient()
    private let defaults = UserDefaults.standard

    // MARK: - Preferences

    func loadPreferences() {
        selectedSport = defaults.string(forKey: "selectedSport")
        if let teamId = defaults.string(forKey: "selectedTeamId") {
            if selectedSport == "softball" {
                if let team = SoftballTeam.allTeams.first(where: { $0.id == teamId }) {
                    selectedSoftballTeam = team
                    selectedTeam = MLBTeam(id: team.id, name: team.name, city: team.city, abbreviation: team.abbreviation, primaryHex: team.primaryHex, secondaryHex: team.secondaryHex)
                }
            } else if let team = MLBTeam.allTeams.first(where: { $0.id == teamId }) {
                selectedTeam = team
            }
        }
        selectedTier = defaults.string(forKey: "selectedTier")
    }

    func savePreferences() {
        defaults.set(selectedTeam?.id, forKey: "selectedTeamId")
        defaults.set(selectedTier, forKey: "selectedTier")
        defaults.set(selectedSport, forKey: "selectedSport")
    }

    // MARK: - Team Selection

    func selectTeam(_ team: MLBTeam) {
        selectedTeam = team
        selectedSoftballTeam = nil
        savePreferences()
    }

    func selectSoftballTeam(_ team: SoftballTeam) {
        selectedSoftballTeam = team
        // Store as MLBTeam shape so the rest of the app can use selectedTeam
        selectedTeam = MLBTeam(id: team.id, name: team.name, city: team.city, abbreviation: team.abbreviation, primaryHex: team.primaryHex, secondaryHex: team.secondaryHex)
        savePreferences()
    }

    // MARK: - Tier Selection

    func selectTier(_ tier: String) {
        selectedTier = tier
        savePreferences()
    }

    // MARK: - Sport Selection

    func selectSport(_ sport: String) {
        selectedSport = sport
        savePreferences()
    }

    // MARK: - Scenario Management

    func loadScenarioList() async {
        guard let tier = selectedTier else { return }
        do {
            let allScenarios = try await apiClient.listScenarios(tier: tier)
            // Filter by selected sport
            if let sport = selectedSport {
                scenarioList = allScenarios.filter { item in
                    guard let sportList = item.sport else { return true }
                    return sportList.contains(sport)
                }
            } else {
                scenarioList = allScenarios
            }
            scenarioIndex = 0
        } catch {
            print("Failed to load scenario list: \(error)")
        }
    }

    func loadNextScenario() async {
        guard let tier = selectedTier else { return }

        // Round limit reached
        if scenariosCompleted >= scenariosPerRound {
            sessionComplete = true
            return
        }

        isLoadingScenario = true
        defer { isLoadingScenario = false }

        do {
            if scenarioList.isEmpty {
                await loadScenarioList()
            }

            // Find next scenario that hasn't been played this session
            while scenarioIndex < scenarioList.count {
                let item = scenarioList[scenarioIndex]
                if sessionPlayedIds.contains(item.id) {
                    scenarioIndex += 1
                    continue
                }
                let scenario = try await apiClient.loadScenario(tier: tier, id: item.id)
                currentScenario = scenario
                sessionPlayedIds.append(item.id)
                scenarioIndex += 1

                // Resolve the starting node — skip transition nodes to find the first decision
                var nodeId = "root"
                while let node = scenario.nodes[nodeId] {
                    if node.type == "decision" || node.type == "outcome" {
                        break
                    }
                    // Transition node — follow the next pointer
                    if let next = node.next {
                        nodeId = next
                    } else {
                        break
                    }
                }
                currentNodeId = nodeId
                return
            }

            // All scenarios exhausted
            sessionComplete = true
        } catch {
            print("Failed to load scenario: \(error)")
        }
    }

    func advanceToNode(_ nodeId: String) {
        currentNodeId = nodeId
    }

    func makeChoice(_ choice: Choice) {
        // Follow through transition nodes to find the outcome/decision
        var nodeId = choice.nextNode
        while let node = currentScenario?.nodes[nodeId] {
            if node.type == "decision" || node.type == "outcome" {
                break
            }
            if let next = node.next {
                nodeId = next
            } else {
                break
            }
        }
        advanceToNode(nodeId)
    }

    func recordOutcome(_ outcome: Outcome, category: String = "general") {
        let multiplier = currentScenario?.tokenMultiplier ?? 1
        let tokensEarned = outcome.iqPoints * multiplier

        totalIQ += outcome.iqPoints
        totalTokens += tokensEarned
        scenariosCompleted += 1

        let record = DecisionRecord(
            nodeId: currentNodeId ?? "unknown",
            choiceId: "outcome",
            result: outcome.result,
            iqPoints: outcome.iqPoints,
            tokensEarned: tokensEarned,
            multiplier: multiplier,
            category: category,
            whatToRemember: outcome.result.lowercased() != "great" ? outcome.whatToRemember : nil
        )
        history.append(record)
    }

    // MARK: - Session

    func startSession(playerId: UUID, isGuest: Bool = false) async {
        totalIQ = 0
        totalTokens = 0
        scenariosCompleted = 0
        history = []
        sessionComplete = false

        // Only call API if not a guest
        if !isGuest, let tier = selectedTier, let sport = selectedSport {
            do {
                let session = try await apiClient.createSession(
                    playerId: playerId,
                    tier: tier,
                    sport: sport
                )
                currentSession = session
            } catch {
                print("Failed to start session: \(error)")
                // Non-fatal — continue with local play
            }
        }

        await loadNextScenario()
    }

    func startGuestSession() async {
        totalIQ = 0
        totalTokens = 0
        scenariosCompleted = 0
        history = []
        sessionComplete = false
        currentSession = nil
        await loadNextScenario()
    }

    func saveCurrentResult() async {
        guard let session = currentSession,
              let scenario = currentScenario else { return }
        // Only save if we have a server session (not guest)
        let lastRecord = history.last
        let result = SessionResult(
            scenarioId: scenario.id,
            iqEarned: lastRecord?.iqPoints ?? 0,
            result: lastRecord?.result ?? "unknown",
            decisions: history
        )
        do {
            try await apiClient.saveResult(sessionId: session.id, result: result)
        } catch {
            print("Failed to save result: \(error)")
            // Non-fatal
        }
    }

    func endSession() async {
        guard let session = currentSession else { return }
        do {
            try await apiClient.endSession(
                id: session.id,
                totalIQ: totalIQ,
                grade: iqGrade,
                scenariosPlayed: scenariosCompleted,
                totalTokens: totalTokens
            )
        } catch {
            print("Failed to end session: \(error)")
        }
    }

    // MARK: - Reset

    func reset() {
        selectedTeam = nil
        selectedSoftballTeam = nil
        selectedTier = nil
        selectedSport = nil
        currentScenario = nil
        currentNodeId = nil
        history = []
        totalIQ = 0
        totalTokens = 0
        scenariosCompleted = 0
        sessionComplete = false
        currentSession = nil
        scenarioList = []
        scenarioIndex = 0
        sessionPlayedIds = []

        defaults.removeObject(forKey: "selectedTeamId")
        defaults.removeObject(forKey: "selectedTier")
        defaults.removeObject(forKey: "selectedSport")
    }

    func changeTeam() {
        selectedTeam = nil
        selectedSoftballTeam = nil
        defaults.removeObject(forKey: "selectedTeamId")
    }

    func changeTier() {
        selectedTier = nil
        defaults.removeObject(forKey: "selectedTier")
    }

    func changeSport() {
        selectedSport = nil
        selectedTeam = nil
        selectedSoftballTeam = nil
        selectedTier = nil
        defaults.removeObject(forKey: "selectedSport")
        defaults.removeObject(forKey: "selectedTeamId")
        defaults.removeObject(forKey: "selectedTier")
    }

    func keepGoing() {
        // Reset round state but keep session played IDs
        scenariosCompleted = 0
        totalIQ = 0
        totalTokens = 0
        history = []
        sessionComplete = false
        currentScenario = nil
        currentNodeId = nil
    }

    func newSession() {
        currentScenario = nil
        currentNodeId = nil
        history = []
        totalIQ = 0
        totalTokens = 0
        scenariosCompleted = 0
        sessionComplete = false
        currentSession = nil
        scenarioList = []
        scenarioIndex = 0
        sessionPlayedIds = []
    }

    // MARK: - Current Node

    var currentNode: ScenarioNode? {
        guard let scenario = currentScenario, let nodeId = currentNodeId else { return nil }
        return scenario.nodes[nodeId]
    }

    var currentSetup: GameSetup? {
        currentScenario?.setup
    }

    // MARK: - Sport Helpers

    /// Sports that use the team picker (baseball/softball only)
    var needsTeamSelection: Bool {
        guard let sport = selectedSport else { return false }
        return sport == "baseball" || sport == "softball"
    }

    /// Sports that show the baseball field + scoreboard
    var isBaseballSport: Bool {
        guard let sport = selectedSport else { return false }
        return sport == "baseball" || sport == "softball"
    }

    // MARK: - IQ Grade

    var iqGrade: String {
        let avgIQ = scenariosCompleted > 0 ? totalIQ / scenariosCompleted : 0
        switch avgIQ {
        case 90...: return "MVP"
        case 70..<90: return "All-Star"
        case 50..<70: return "Starter"
        case 30..<50: return "Rookie"
        default: return "Keep Going"
        }
    }

    // MARK: - Sport-Specific Tier Names

    static let tierNames: [String: [String]] = [
        "baseball":   ["T-Ball", "Rookie", "Minors", "Majors", "The Show"],
        "softball":   ["T-Ball", "Rookie", "Minors", "Majors", "The Show"],
        "chess":      ["Pawn", "Knight", "Bishop", "Rook", "Queen"],
        "basketball": ["Rec League", "JV", "Varsity", "College", "Pro"],
        "football":   ["Flag", "Pee Wee", "JV", "Varsity", "Pro"],
        "soccer":     ["U6", "U8", "U10", "U12", "Academy"],
        "hockey":     ["Learn to Skate", "Mite", "Bantam", "Junior", "Pro"],
        "tennis":     ["Rally", "Club", "Junior", "Challenger", "Grand Slam"],
        "golf":       ["First Tee", "Junior", "Club", "Amateur", "Tour Pro"],
        "money":      ["Piggy Bank", "Allowance", "Smart Shopper", "Entrepreneur", "Investor"],
        "coding":     ["Blocks", "Scratch", "Builder", "Hacker", "Dev"],
        "detective":  ["Clue Finder", "Junior Detective", "Investigator", "Case Solver", "Master Detective"],
        "survival":   ["Safety Star", "Trail Scout", "Wilderness Guide", "Ranger", "Survivor"],
        "science":    ["Observer", "Questioner", "Experimenter", "Analyst", "Scientist"],
        "social":     ["Friend", "Buddy", "Team Player", "Leader", "Mentor"],
        "history":    ["Time Traveler", "Explorer", "Governor", "Changemaker", "World Shaper"],
    ]

    static let tierIds = ["tball", "rookie", "minors", "majors", "the-show"]

    static let tierDescriptions: [String: [String]] = [
        "baseball":   [
            "Learn the basics -- where to throw, where to run, how to catch",
            "Fundamentals -- force outs, tagging up, base running decisions",
            "Game IQ -- cutoffs, relays, situational hitting, defensive positioning",
            "Advanced -- double plays, pitch sequencing, hit-and-run, defensive schemes",
            "Elite -- squeeze plays, shifts, pitcher/batter chess, full-game strategy",
        ],
        "basketball": [
            "Learn the basics -- passing, dribbling, simple plays",
            "Fundamentals -- pick and roll, spacing, fast breaks",
            "Game IQ -- plays, rotations, situational decisions",
            "Advanced -- complex sets, matchup hunting, clock management",
            "Elite -- full-court strategy, adjustments, championship moments",
        ],
        "football": [
            "Learn the basics -- positions, simple plays, flag rules",
            "Fundamentals -- formations, basic reads, tackle decisions",
            "Game IQ -- play calling, defensive reads, situational football",
            "Advanced -- audibles, blitz recognition, two-minute drill",
            "Elite -- full game management, adjustments, championship moments",
        ],
        "soccer": [
            "Learn the basics -- passing, positions, simple plays",
            "Fundamentals -- formations, throw-ins, corner kicks",
            "Game IQ -- through balls, offsides trap, set pieces",
            "Advanced -- pressing, counter-attacks, tactical switches",
            "Elite -- full match strategy, formation changes, tournament play",
        ],
        "hockey": [
            "Learn the basics -- skating, puck handling, positions",
            "Fundamentals -- passing, face-offs, line changes",
            "Game IQ -- power plays, breakouts, defensive zone coverage",
            "Advanced -- systems play, penalty kill, special teams",
            "Elite -- full game strategy, matchups, playoff intensity",
        ],
        "chess": [
            "Learn the basics -- how pieces move, simple captures",
            "Fundamentals -- basic tactics, pins, forks",
            "Game IQ -- opening principles, middle game plans",
            "Advanced -- complex tactics, endgame technique",
            "Elite -- deep strategy, master-level combinations",
        ],
        "tennis": [
            "Learn the basics -- strokes, scoring, court positions",
            "Fundamentals -- serve placement, rally consistency",
            "Game IQ -- approach shots, net play, patterns",
            "Advanced -- tactical serving, shot selection under pressure",
            "Elite -- full match strategy, mental game, tour-level play",
        ],
        "golf": [
            "Learn the basics -- grip, stance, club selection",
            "Fundamentals -- course management, putting basics",
            "Game IQ -- shot shaping, green reading, strategy",
            "Advanced -- risk/reward decisions, tournament pressure",
            "Elite -- full course management, tour-level decisions",
        ],
        "money": [
            "Learn the basics -- coins, saving, needs vs wants",
            "Fundamentals -- budgeting, earning, spending wisely",
            "Game IQ -- comparison shopping, interest, value",
            "Advanced -- business basics, investing concepts, profit",
            "Elite -- portfolios, compound growth, financial planning",
        ],
        "coding": [
            "Learn the basics -- sequences, loops, simple logic",
            "Fundamentals -- visual programming, events, variables",
            "Game IQ -- functions, data types, debugging",
            "Advanced -- algorithms, APIs, real-world projects",
            "Elite -- system design, optimization, production code",
        ],
        "detective": [
            "Learn the basics -- observation, clue spotting",
            "Fundamentals -- evidence gathering, witness interviews",
            "Game IQ -- deduction, connecting evidence, timelines",
            "Advanced -- complex cases, red herrings, forensics",
            "Elite -- master deduction, cold cases, criminal profiling",
        ],
        "survival": [
            "Learn the basics -- safety rules, emergency contacts",
            "Fundamentals -- trail navigation, weather awareness",
            "Game IQ -- shelter building, water finding, fire safety",
            "Advanced -- wilderness first aid, animal encounters",
            "Elite -- extreme conditions, multi-day survival, rescue ops",
        ],
        "science": [
            "Learn the basics -- observation, asking questions",
            "Fundamentals -- hypothesis, simple experiments",
            "Game IQ -- variables, measurement, data collection",
            "Advanced -- analysis, conclusions, scientific method",
            "Elite -- research design, peer review, discovery",
        ],
        "social": [
            "Learn the basics -- sharing, taking turns, being kind",
            "Fundamentals -- teamwork, empathy, communication",
            "Game IQ -- conflict resolution, group dynamics",
            "Advanced -- leadership, mentoring, public speaking",
            "Elite -- community building, negotiation, influence",
        ],
        "history": [
            "Learn the basics -- timelines, famous people, key events",
            "Fundamentals -- cause and effect, primary sources",
            "Game IQ -- governance, trade, cultural exchange",
            "Advanced -- social movements, revolution, reform",
            "Elite -- geopolitics, historiography, shaping the future",
        ],
    ]

    func tierDisplayName(for tierId: String) -> String {
        guard let sport = selectedSport,
              let names = GameState.tierNames[sport],
              let index = GameState.tierIds.firstIndex(of: tierId),
              index < names.count else {
            return tierId.replacingOccurrences(of: "-", with: " ").capitalized
        }
        return names[index]
    }
}
