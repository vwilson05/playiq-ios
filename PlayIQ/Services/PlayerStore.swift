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
                await refreshPlayer(id: player.id)
            }
        } catch {
            isLoading = false
        }
    }

    @Published var successMessage: String?

    // MARK: - Login

    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let player = try await apiClient.login(username: username, password: password)
            currentPlayer = player
            isGuest = false
            savePlayer(player)
        } catch let error as APIError {
            switch error {
            case .httpError(let code) where code == 404:
                errorMessage = "Player not found. Try signing up!"
            case .httpError(let code) where code == 401:
                errorMessage = "Wrong password"
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = "Could not connect to server: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Signup

    func signup(username: String, displayName: String, password: String, parentEmail: String) async {
        isLoading = true
        errorMessage = nil

        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = parentEmail.trimmingCharacters(in: .whitespacesAndNewlines)

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

        guard password.count >= 4 else {
            errorMessage = "Password must be at least 4 characters"
            isLoading = false
            return
        }

        do {
            let player = try await apiClient.createPlayer(
                username: trimmedUsername,
                displayName: trimmedDisplayName.isEmpty ? trimmedUsername : trimmedDisplayName,
                password: password,
                parentEmail: trimmedEmail.isEmpty ? nil : trimmedEmail
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

    // MARK: - Forgot Password

    func forgotPassword(username: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let _ = try await apiClient.forgotPassword(username: username)
            successMessage = "If that account has a parent email, a reset code was sent."
        } catch {
            errorMessage = "Could not connect to server"
        }

        isLoading = false
    }

    // MARK: - Reset Password

    func resetPassword(username: String, code: String, newPassword: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        guard newPassword.count >= 4 else {
            errorMessage = "Password must be at least 4 characters"
            isLoading = false
            return false
        }

        do {
            let _ = try await apiClient.resetPassword(username: username, code: code, newPassword: newPassword)
            isLoading = false
            return true
        } catch let error as APIError {
            switch error {
            case .httpError:
                errorMessage = "Invalid or expired code"
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = "Could not connect to server"
        }

        isLoading = false
        return false
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

    private func refreshPlayer(id: UUID) async {
        do {
            let profile = try await apiClient.fetchPlayerProfile(id: id)
            let player = Player(
                id: profile.id,
                username: profile.username,
                displayName: profile.displayName,
                avatar: profile.avatar,
                cumulativeIQ: profile.cumulativeIQ,
                totalSessions: profile.totalSessions
            )
            currentPlayer = player
            savePlayer(player)
        } catch {
            // Keep cached data if refresh fails
        }
    }
}
