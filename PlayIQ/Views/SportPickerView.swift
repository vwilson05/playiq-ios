import SwiftUI

struct SportPickerView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 8) {
                Text("Choose Your Sport")
                    .font(PlayIQFonts.title)
                    .foregroundColor(PlayIQColors.text)

                Text("Both sports share baseball IQ")
                    .font(PlayIQFonts.callout)
                    .foregroundColor(PlayIQColors.textSecondary)
            }

            // Sport Cards
            HStack(spacing: 16) {
                SportCard(
                    name: "Baseball",
                    icon: "baseball.fill",
                    color: Color(hex: "#3b82f6")
                ) {
                    selectSport("baseball")
                }

                SportCard(
                    name: "Softball",
                    icon: "baseball",
                    color: Color(hex: "#a855f7")
                ) {
                    selectSport("softball")
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(PlayIQColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
    }

    private func selectSport(_ sport: String) {
        gameState.selectSport(sport)
    }
}

struct SportCard: View {
    let name: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 56))
                    .foregroundColor(color)

                Text(name)
                    .font(PlayIQFonts.title2)
                    .foregroundColor(PlayIQColors.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(PlayIQColors.card)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    NavigationStack {
        SportPickerView()
            .environmentObject(GameState())
    }
}
