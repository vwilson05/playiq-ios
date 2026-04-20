import SwiftUI

@main
struct PlayIQApp: App {
    @StateObject private var gameState = GameState()
    @StateObject private var playerStore = PlayerStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(gameState)
                .environmentObject(playerStore)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var playerStore: PlayerStore
    @EnvironmentObject var gameState: GameState

    var body: some View {
        NavigationStack {
            Group {
                if playerStore.isLoading {
                    ProgressView("Loading...")
                        .tint(PlayIQColors.gold)
                } else if playerStore.currentPlayer == nil {
                    AuthView()
                } else if gameState.selectedSport == nil {
                    SportPickerView()
                } else if gameState.selectedTeam == nil {
                    TeamPickerView()
                } else if gameState.selectedTier == nil {
                    TierPickerView()
                } else if gameState.sessionComplete {
                    ReviewView()
                } else {
                    GameView()
                }
            }
            .background(PlayIQColors.background.ignoresSafeArea())
        }
        .tint(PlayIQColors.gold)
        .onAppear {
            playerStore.autoLogin()
            gameState.loadPreferences()
        }
    }
}
