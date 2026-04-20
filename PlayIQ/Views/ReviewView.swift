import SwiftUI

struct ReviewView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var playerStore: PlayerStore

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Session Complete Header
                VStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 48))
                        .foregroundColor(PlayIQColors.gold)

                    Text("Session Complete!")
                        .font(PlayIQFonts.title)
                        .foregroundColor(PlayIQColors.text)
                }
                .padding(.top, 32)

                // IQ Score card
                VStack(spacing: 8) {
                    Text("\(gameState.totalIQ)")
                        .font(PlayIQFonts.iqScore)
                        .foregroundColor(PlayIQColors.gold)

                    Text("Total IQ Points")
                        .font(PlayIQFonts.callout)
                        .foregroundColor(PlayIQColors.textSecondary)

                    // Grade badge
                    Text(gameState.iqGrade)
                        .font(PlayIQFonts.headline)
                        .foregroundColor(gradeColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(gradeColor.opacity(0.15))
                        .cornerRadius(20)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(PlayIQColors.card)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(PlayIQColors.gold.opacity(0.3), lineWidth: 1)
                )

                // Stats row
                HStack(spacing: 16) {
                    StatCard(
                        icon: "list.bullet.clipboard.fill",
                        value: "\(gameState.scenariosCompleted)",
                        label: "Scenarios"
                    )

                    StatCard(
                        icon: "brain.fill",
                        value: gameState.scenariosCompleted > 0
                            ? "\(gameState.totalIQ / gameState.scenariosCompleted)"
                            : "0",
                        label: "Avg IQ"
                    )

                    StatCard(
                        icon: "star.fill",
                        value: "\(greatCount)",
                        label: "Great"
                    )
                }

                // Decision History
                if !gameState.history.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Decisions")
                            .font(PlayIQFonts.headline)
                            .foregroundColor(PlayIQColors.text)

                        ForEach(Array(gameState.history.enumerated()), id: \.offset) { index, record in
                            DecisionRow(index: index + 1, record: record)
                        }
                    }
                }

                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        gameState.keepGoing()
                        Task {
                            await gameState.loadNextScenario()
                        }
                    }) {
                        HStack {
                            Image(systemName: "flame.fill")
                            Text("Keep Going")
                                .font(PlayIQFonts.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(PlayIQColors.gold)
                        .foregroundColor(PlayIQColors.background)
                        .cornerRadius(10)
                    }

                    Button(action: {
                        gameState.newSession()
                        gameState.changeTier()
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text("Change Level")
                                .font(PlayIQFonts.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(PlayIQColors.card)
                        .foregroundColor(PlayIQColors.text)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(PlayIQColors.cardBorder, lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(PlayIQColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .onAppear {
            Task { await gameState.endSession() }
        }
    }

    private var gradeColor: Color {
        switch gameState.iqGrade {
        case "MVP": return PlayIQColors.resultGreat
        case "All-Star": return PlayIQColors.resultGood
        case "Starter": return PlayIQColors.resultOkay
        default: return PlayIQColors.resultBad
        }
    }

    private var greatCount: Int {
        gameState.history.filter { $0.result.lowercased() == "great" }.count
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(PlayIQColors.gold)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(PlayIQColors.text)

            Text(label)
                .font(PlayIQFonts.caption)
                .foregroundColor(PlayIQColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(PlayIQColors.card)
        .cornerRadius(12)
    }
}

struct DecisionRow: View {
    let index: Int
    let record: DecisionRecord

    private var resultColor: Color {
        PlayIQColors.resultColor(for: record.result)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Number
            ZStack {
                Circle()
                    .fill(resultColor.opacity(0.2))
                    .frame(width: 32, height: 32)

                Text("\(index)")
                    .font(PlayIQFonts.caption)
                    .foregroundColor(resultColor)
            }

            // Result
            VStack(alignment: .leading, spacing: 2) {
                Text(record.result.capitalized)
                    .font(PlayIQFonts.headline)
                    .foregroundColor(PlayIQColors.text)

                Text("Scenario \(index)")
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.textSecondary)
            }

            Spacer()

            // Points
            Text("+\(record.iqPoints)")
                .font(PlayIQFonts.scoreboard)
                .foregroundColor(resultColor)
        }
        .padding(12)
        .background(PlayIQColors.card)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(resultColor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ReviewView()
        .environmentObject(GameState())
        .environmentObject(PlayerStore())
}
