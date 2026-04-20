import Foundation

final class APIClient {
    private let baseURL = "https://app.playiqapp.com"
    private let session: URLSession
    private let decoder: JSONDecoder

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)

        decoder = JSONDecoder()
    }

    // MARK: - Scenarios

    func listScenarios(tier: String) async throws -> [ScenarioListItem] {
        let url = URL(string: "\(baseURL)/api/scenarios/\(tier)")!
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        return try decoder.decode([ScenarioListItem].self, from: data)
    }

    func loadScenario(tier: String, id: String) async throws -> Scenario {
        let url = URL(string: "\(baseURL)/api/scenarios/\(tier)/\(id)")!
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        return try decoder.decode(Scenario.self, from: data)
    }

    // MARK: - Players

    func createPlayer(username: String, displayName: String) async throws -> Player {
        let url = URL(string: "\(baseURL)/api/players")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = PlayerCreateRequest(username: username, displayName: displayName)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(Player.self, from: data)
    }

    func login(username: String) async throws -> Player {
        let url = URL(string: "\(baseURL)/api/players/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = PlayerLoginRequest(username: username)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(Player.self, from: data)
    }

    // MARK: - Sessions

    func createSession(playerId: UUID, tier: String, sport: String) async throws -> GameSession {
        let url = URL(string: "\(baseURL)/api/sessions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = SessionCreate(playerId: playerId, tier: tier, sport: sport)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(GameSession.self, from: data)
    }

    func endSession(id: UUID) async throws {
        let url = URL(string: "\(baseURL)/api/sessions/\(id.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }

    func saveResult(sessionId: UUID, result: SessionResult) async throws {
        let url = URL(string: "\(baseURL)/api/sessions/\(sessionId.uuidString)/results")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(result)

        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }

    // MARK: - Helpers

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "Server error (HTTP \(code))"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        }
    }
}
