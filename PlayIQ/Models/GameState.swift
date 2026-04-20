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
    @Published var scenariosCompleted: Int = 0
    @Published var sessionComplete: Bool = false
    @Published var currentSession: GameSession?
    @Published var isLoadingScenario: Bool = false
    @Published var showMenu: Bool = false
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
            scenarioList = try await apiClient.listScenarios(tier: tier)
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

    func recordOutcome(_ outcome: Outcome) {
        totalIQ += outcome.iqPoints
        scenariosCompleted += 1

        let record = DecisionRecord(
            nodeId: currentNodeId ?? "unknown",
            choiceId: "outcome",
            result: outcome.result,
            iqPoints: outcome.iqPoints
        )
        history.append(record)
    }

    // MARK: - Session

    func startSession(playerId: UUID, isGuest: Bool = false) async {
        totalIQ = 0
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
            try await apiClient.endSession(id: session.id)
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
        defaults.removeObject(forKey: "selectedSport")
        defaults.removeObject(forKey: "selectedTeamId")
    }

    func keepGoing() {
        // Reset round state but keep session played IDs
        scenariosCompleted = 0
        totalIQ = 0
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

    // MARK: - IQ Grade

    var iqGrade: String {
        let avgIQ = scenariosCompleted > 0 ? totalIQ / scenariosCompleted : 0
        switch avgIQ {
        case 90...: return "MVP"
        case 70..<90: return "All-Star"
        case 50..<70: return "Starter"
        case 30..<50: return "Rookie"
        default: return "Bench"
        }
    }
}
