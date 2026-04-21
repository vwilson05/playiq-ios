import SwiftUI

// MARK: - Sport Metadata

struct SportInfo: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let category: String
}

let allSports: [SportInfo] = [
    // Sports
    SportInfo(id: "baseball", name: "Baseball", icon: "baseball.fill", color: Color(hex: "#3b82f6"), category: "Sports"),
    SportInfo(id: "softball", name: "Softball", icon: "baseball", color: Color(hex: "#a855f7"), category: "Sports"),
    SportInfo(id: "basketball", name: "Basketball", icon: "basketball.fill", color: Color(hex: "#f97316"), category: "Sports"),
    SportInfo(id: "football", name: "Football", icon: "football.fill", color: Color(hex: "#84cc16"), category: "Sports"),
    SportInfo(id: "soccer", name: "Soccer", icon: "soccerball", color: Color(hex: "#22c55e"), category: "Sports"),
    SportInfo(id: "hockey", name: "Hockey", icon: "hockey.puck.fill", color: Color(hex: "#06b6d4"), category: "Sports"),
    SportInfo(id: "tennis", name: "Tennis", icon: "tennisball.fill", color: Color(hex: "#eab308"), category: "Sports"),
    SportInfo(id: "golf", name: "Golf", icon: "figure.golf", color: Color(hex: "#10b981"), category: "Sports"),
    // Strategy
    SportInfo(id: "chess", name: "Chess", icon: "crown.fill", color: Color(hex: "#8b5cf6"), category: "Strategy"),
    SportInfo(id: "detective", name: "Detective", icon: "magnifyingglass", color: Color(hex: "#6366f1"), category: "Strategy"),
    // Life Skills
    SportInfo(id: "money", name: "Money", icon: "dollarsign.circle.fill", color: Color(hex: "#22c55e"), category: "Life Skills"),
    SportInfo(id: "coding", name: "Coding", icon: "chevron.left.forwardslash.chevron.right", color: Color(hex: "#3b82f6"), category: "Life Skills"),
    SportInfo(id: "survival", name: "Survival", icon: "leaf.fill", color: Color(hex: "#84cc16"), category: "Life Skills"),
    SportInfo(id: "social", name: "Social", icon: "person.2.fill", color: Color(hex: "#ec4899"), category: "Life Skills"),
    // Science
    SportInfo(id: "science", name: "Science", icon: "flask.fill", color: Color(hex: "#06b6d4"), category: "Science"),
    // History
    SportInfo(id: "history", name: "History", icon: "clock.fill", color: Color(hex: "#f59e0b"), category: "History"),
]

let sportCategories = ["Sports", "Strategy", "Life Skills", "Science", "History"]

func sportInfo(for id: String) -> SportInfo? {
    allSports.first { $0.id == id }
}

// MARK: - Sport Picker View

struct SportPickerView: View {
    @EnvironmentObject var gameState: GameState

    private let columns = [
        GridItem(.adaptive(minimum: 90, maximum: 120), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Your Module")
                        .font(PlayIQFonts.title)
                        .foregroundColor(PlayIQColors.text)

                    Text("Pick a sport, skill, or subject")
                        .font(PlayIQFonts.callout)
                        .foregroundColor(PlayIQColors.textSecondary)
                }
                .padding(.top, 20)

                // Categories
                ForEach(sportCategories, id: \.self) { category in
                    let sportsInCat = allSports.filter { $0.category == category }
                    VStack(alignment: .leading, spacing: 10) {
                        Text(category.uppercased())
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(PlayIQColors.textSecondary)
                            .tracking(1)
                            .padding(.leading, 4)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(sportsInCat) { sport in
                                SportCard(
                                    name: sport.name,
                                    icon: sport.icon,
                                    color: sport.color
                                ) {
                                    selectSport(sport.id)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
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
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)

                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(PlayIQColors.text)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(PlayIQColors.card)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
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
