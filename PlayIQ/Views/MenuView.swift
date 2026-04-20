import SwiftUI

struct MenuView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var playerStore: PlayerStore
    @Environment(\.dismiss) var dismiss
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            List {
                // Player profile section
                Section {
                    if let player = playerStore.currentPlayer {
                        Button(action: { showProfile = true }) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(PlayIQColors.gold.opacity(0.2))
                                        .frame(width: 50, height: 50)

                                    Image(systemName: "person.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(PlayIQColors.gold)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(player.displayName)
                                        .font(PlayIQFonts.headline)
                                        .foregroundColor(PlayIQColors.text)

                                    Text("@\(player.username)")
                                        .font(PlayIQFonts.caption)
                                        .foregroundColor(PlayIQColors.textSecondary)

                                    HStack(spacing: 4) {
                                        Image(systemName: "brain.fill")
                                            .font(.system(size: 10))
                                        Text("Cumulative IQ: \(player.cumulativeIQ)")
                                            .font(PlayIQFonts.caption)
                                    }
                                    .foregroundColor(PlayIQColors.gold)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(PlayIQColors.textSecondary)
                            }
                        }
                        .listRowBackground(PlayIQColors.card)
                    }
                }

                // Current settings
                Section("Current Settings") {
                    if let team = gameState.selectedTeam {
                        HStack {
                            Label("Team", systemImage: "tshirt.fill")
                                .foregroundColor(PlayIQColors.text)
                            Spacer()
                            Text(team.name)
                                .foregroundColor(team.primaryColor)
                        }
                        .listRowBackground(PlayIQColors.card)
                    }

                    if let tier = gameState.selectedTier {
                        HStack {
                            Label("Level", systemImage: "chart.bar.fill")
                                .foregroundColor(PlayIQColors.text)
                            Spacer()
                            Text(tier.replacingOccurrences(of: "-", with: " ").capitalized)
                                .foregroundColor(PlayIQColors.gold)
                        }
                        .listRowBackground(PlayIQColors.card)
                    }

                    if let sport = gameState.selectedSport {
                        HStack {
                            Label("Sport", systemImage: "baseball.fill")
                                .foregroundColor(PlayIQColors.text)
                            Spacer()
                            Text(sport.capitalized)
                                .foregroundColor(PlayIQColors.textSecondary)
                        }
                        .listRowBackground(PlayIQColors.card)
                    }
                }

                // Session stats
                if gameState.scenariosCompleted > 0 {
                    Section("This Session") {
                        HStack {
                            Label("IQ Earned", systemImage: "brain.fill")
                                .foregroundColor(PlayIQColors.text)
                            Spacer()
                            Text("\(gameState.totalIQ)")
                                .foregroundColor(PlayIQColors.gold)
                                .font(PlayIQFonts.scoreboard)
                        }
                        .listRowBackground(PlayIQColors.card)

                        HStack {
                            Label("Scenarios", systemImage: "list.bullet.clipboard.fill")
                                .foregroundColor(PlayIQColors.text)
                            Spacer()
                            Text("\(gameState.scenariosCompleted)")
                                .foregroundColor(PlayIQColors.textSecondary)
                        }
                        .listRowBackground(PlayIQColors.card)

                        HStack {
                            Label("Tokens", systemImage: "dollarsign.circle.fill")
                                .foregroundColor(PlayIQColors.text)
                            Spacer()
                            Text("\(gameState.totalIQ)")
                                .foregroundColor(PlayIQColors.gold)
                                .font(PlayIQFonts.scoreboard)
                        }
                        .listRowBackground(PlayIQColors.card)
                    }
                }

                // Actions
                Section("Actions") {
                    Button(action: { showProfile = true }) {
                        Label("My Profile", systemImage: "person.crop.circle")
                            .foregroundColor(PlayIQColors.text)
                    }
                    .listRowBackground(PlayIQColors.card)

                    Button(action: {
                        dismiss()
                        gameState.changeSport()
                    }) {
                        Label("Change Sport", systemImage: "arrow.triangle.2.circlepath")
                            .foregroundColor(PlayIQColors.text)
                    }
                    .listRowBackground(PlayIQColors.card)

                    Button(action: {
                        dismiss()
                        gameState.changeTeam()
                    }) {
                        Label("Change Team", systemImage: "arrow.triangle.2.circlepath")
                            .foregroundColor(PlayIQColors.text)
                    }
                    .listRowBackground(PlayIQColors.card)

                    Button(action: {
                        dismiss()
                        gameState.changeTier()
                    }) {
                        Label("Change Level", systemImage: "slider.horizontal.3")
                            .foregroundColor(PlayIQColors.text)
                    }
                    .listRowBackground(PlayIQColors.card)

                    Button(action: {
                        dismiss()
                        Task { await gameState.endSession() }
                        gameState.sessionComplete = true
                    }) {
                        Label("End Session", systemImage: "stop.circle.fill")
                            .foregroundColor(PlayIQColors.resultOkay)
                    }
                    .listRowBackground(PlayIQColors.card)
                }

                // Logout
                Section {
                    Button(action: {
                        dismiss()
                        gameState.reset()
                        playerStore.logout()
                    }) {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(PlayIQColors.resultBad)
                    }
                    .listRowBackground(PlayIQColors.card)
                }
            }
            .scrollContentBackground(.hidden)
            .background(PlayIQColors.background)
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(PlayIQColors.gold)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(GameState())
        .environmentObject(PlayerStore())
}
