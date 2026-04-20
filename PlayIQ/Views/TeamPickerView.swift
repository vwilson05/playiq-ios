import SwiftUI

struct TeamPickerView: View {
    @EnvironmentObject var gameState: GameState

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 140), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Pick Your Team")
                    .font(PlayIQFonts.title)
                    .foregroundColor(PlayIQColors.text)

                Text("Choose your favorite MLB team")
                    .font(PlayIQFonts.callout)
                    .foregroundColor(PlayIQColors.textSecondary)
            }
            .padding(.top, 20)

            // Team Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(MLBTeam.allTeams) { team in
                        TeamCard(team: team)
                            .onTapGesture {
                                gameState.selectTeam(team)
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .background(PlayIQColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
    }
}

struct TeamCard: View {
    let team: MLBTeam

    var body: some View {
        VStack(spacing: 6) {
            Text(team.abbreviation)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text(team.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [team.primaryColor, team.primaryColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(team.secondaryColor.opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        TeamPickerView()
            .environmentObject(GameState())
    }
}
