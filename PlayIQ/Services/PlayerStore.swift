import Foundation
import SwiftUI

@MainActor
final class PlayerStore: ObservableObject {
    @Published var currentPlayer: Player?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isGuest: Bool = false

    private let apiClient = APIClient()
    private let defaults = UserDefaults.standard

    private let playerIdKey = "playiq_player_id"
    private let playerUsernameKey = "playiq_player_username"
    private let playerDataKey = "playiq_player_data"

    // MARK: - Auto Login

    func autoLogin() {
        guard let savedData = defaults.data(forKey: playerDataKey) else {
            isLoading = false
            return
        }

        do {
            let player = try JSONDecoder().decode(Player.self, from: savedData)
            currentPlayer = player
            isLoading = false

            // Refresh from API in background
            Task {
                await refreshPlayer(username: player.username)
            }
        } catch {
            isLoading = false
        }
    }

    // MARK: - Login

    func login(username: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let player = try await apiClient.login(username: username)
            currentPlayer = player
            isGuest = false
            savePlayer(player)
        } catch let error as APIError {
            switch error {
            case .httpError(let code) where code == 404:
                errorMessage = "Player not found. Try signing up!"
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = "Could not connect to server: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Signup

    func signup(username: String, displayName: String) async {
        isLoading = true
        errorMessage = nil

        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty else {
            errorMessage = "Username cannot be empty"
            isLoading = false
            return
        }

        guard trimmedUsername.count >= 3 else {
            errorMessage = "Username must be at least 3 characters"
            isLoading = false
            return
        }

        do {
            let player = try await apiClient.createPlayer(
                username: trimmedUsername,
                displayName: trimmedDisplayName.isEmpty ? trimmedUsername : trimmedDisplayName
            )
            currentPlayer = player
            isGuest = false
            savePlayer(player)
        } catch let error as APIError {
            switch error {
            case .httpError(let code) where code == 409:
                errorMessage = "Username already taken"
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = "Could not connect to server: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Guest Mode

    func playAsGuest() {
        currentPlayer = Player.guest
        isGuest = true
    }

    // MARK: - Logout

    func logout() {
        currentPlayer = nil
        isGuest = false
        defaults.removeObject(forKey: playerIdKey)
        defaults.removeObject(forKey: playerUsernameKey)
        defaults.removeObject(forKey: playerDataKey)
    }

    // MARK: - Persistence

    private func savePlayer(_ player: Player) {
        defaults.set(player.id.uuidString, forKey: playerIdKey)
        defaults.set(player.username, forKey: playerUsernameKey)

        if let data = try? JSONEncoder().encode(player) {
            defaults.set(data, forKey: playerDataKey)
        }
    }

    private func refreshPlayer(username: String) async {
        do {
            let player = try await apiClient.login(username: username)
            currentPlayer = player
            savePlayer(player)
        } catch {
            // Keep cached data if refresh fails
        }
    }
}
