import SwiftUI

struct TierInfo: Identifiable {
    let id: String
    let number: Int
    let name: String
    let description: String
    let icon: String
}

private let tiers: [TierInfo] = [
    TierInfo(id: "tball", number: 1, name: "T-Ball", description: "Learn the basics — where to throw, where to run, how to catch", icon: "1.circle.fill"),
    TierInfo(id: "rookie", number: 2, name: "Rookie", description: "Fundamentals — force outs, tagging up, base running decisions", icon: "2.circle.fill"),
    TierInfo(id: "minors", number: 3, name: "Minors", description: "Game IQ — cutoffs, relays, situational hitting, defensive positioning", icon: "3.circle.fill"),
    TierInfo(id: "majors", number: 4, name: "Majors", description: "Advanced — double plays, pitch sequencing, hit-and-run, defensive schemes", icon: "4.circle.fill"),
    TierInfo(id: "the-show", number: 5, name: "The Show", description: "Elite — squeeze plays, shifts, pitcher/batter chess, full-game strategy", icon: "5.circle.fill"),
]

struct TierPickerView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var playerStore: PlayerStore

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Choose Your Level")
                    .font(PlayIQFonts.title)
                    .foregroundColor(PlayIQColors.text)

                Text("Start where you feel comfortable")
                    .font(PlayIQFonts.callout)
                    .foregroundColor(PlayIQColors.textSecondary)
            }
            .padding(.top, 20)

            // Tier Cards
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(tiers) { tier in
                        TierCard(tier: tier)
                            .onTapGesture {
                                selectTier(tier.id)
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(PlayIQColors.background.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { gameState.changeTeam() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Team")
                    }
                    .foregroundColor(PlayIQColors.gold)
                }
            }
        }
    }

    private func selectTier(_ tier: String) {
        gameState.selectTier(tier)
        Task {
            if let player = playerStore.currentPlayer {
                await gameState.startSession(playerId: player.id, isGuest: playerStore.isGuest)
            } else {
                // Guest mode — skip API session, just load scenarios
                await gameState.startGuestSession()
            }
        }
    }
}

struct TierCard: View {
    let tier: TierInfo

    private var tierColor: Color {
        switch tier.number {
        case 1: return Color(hex: "#22c55e")
        case 2: return Color(hex: "#3b82f6")
        case 3: return Color(hex: "#a855f7")
        case 4: return Color(hex: "#f59e0b")
        case 5: return Color(hex: "#ef4444")
        default: return PlayIQColors.gold
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Number badge
            ZStack {
                Circle()
                    .fill(tierColor)
                    .frame(width: 48, height: 48)

                Text("\(tier.number)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(tier.name)
                    .font(PlayIQFonts.headline)
                    .foregroundColor(PlayIQColors.text)

                Text(tier.description)
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(PlayIQColors.textSecondary)
        }
        .padding(16)
        .background(PlayIQColors.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(tierColor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        TierPickerView()
            .environmentObject(GameState())
            .environmentObject(PlayerStore())
    }
}
