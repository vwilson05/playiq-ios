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

                // Tokens earned badge
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 16))
                    Text("+\(gameState.totalIQ) tokens earned this round")
                        .font(PlayIQFonts.headline)
                }
                .foregroundColor(PlayIQColors.gold)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(PlayIQColors.gold.opacity(0.12))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(PlayIQColors.gold.opacity(0.3), lineWidth: 1)
                )

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

                // Category Breakdown
                if !categoryData.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category Breakdown")
                            .font(PlayIQFonts.headline)
                            .foregroundColor(PlayIQColors.text)

                        ForEach(categoryData, id: \.name) { cat in
                            CategoryBarView(
                                name: cat.name,
                                percentage: cat.percentage,
                                count: cat.greatGoodCount,
                                total: cat.total
                            )
                        }
                    }
                    .padding(16)
                    .background(PlayIQColors.card)
                    .cornerRadius(12)
                }

                // Focus Area
                if let weakest = weakestCategory {
                    HStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(.system(size: 24))
                            .foregroundColor(PlayIQColors.resultOkay)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Focus Area")
                                .font(PlayIQFonts.caption)
                                .foregroundColor(PlayIQColors.textSecondary)
                            Text("Work on: \(weakest.capitalized)")
                                .font(PlayIQFonts.headline)
                                .foregroundColor(PlayIQColors.text)
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(PlayIQColors.resultOkay.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(PlayIQColors.resultOkay.opacity(0.3), lineWidth: 1)
                    )
                }

                // Key Facts to Review
                if !factsToReview.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "brain.head.profile.fill")
                                .font(.system(size: 18))
                                .foregroundColor(PlayIQColors.resultGood)
                            Text("Review These")
                                .font(PlayIQFonts.headline)
                                .foregroundColor(PlayIQColors.text)
                        }

                        ForEach(Array(factsToReview.enumerated()), id: \.offset) { _, record in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(record.category.capitalized)
                                    .font(PlayIQFonts.caption)
                                    .foregroundColor(PlayIQColors.textSecondary)
                                Text(record.whatToRemember ?? "")
                                    .font(PlayIQFonts.body)
                                    .foregroundColor(PlayIQColors.text)
                                    .lineSpacing(3)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(PlayIQColors.resultGood.opacity(0.06))
                            .cornerRadius(8)
                        }
                    }
                    .padding(16)
                    .background(PlayIQColors.card)
                    .cornerRadius(12)
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

    // MARK: - Computed Properties

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

    private var factsToReview: [DecisionRecord] {
        gameState.history.filter { $0.result.lowercased() != "great" && $0.whatToRemember != nil }
    }

    private var categoryData: [CategoryStat] {
        var map: [String: CategoryStat] = [:]
        for record in gameState.history {
            let cat = record.category.lowercased()
            var stat = map[cat] ?? CategoryStat(name: cat, greatGoodCount: 0, total: 0)
            stat.total += 1
            if record.result.lowercased() == "great" || record.result.lowercased() == "good" {
                stat.greatGoodCount += 1
            }
            map[cat] = stat
        }
        let order = ["defense", "offense", "pitching", "baserunning"]
        return map.values.sorted { a, b in
            let ai = order.firstIndex(of: a.name) ?? order.count
            let bi = order.firstIndex(of: b.name) ?? order.count
            return ai < bi
        }
    }

    private var weakestCategory: String? {
        guard !categoryData.isEmpty else { return nil }
        let weakest = categoryData.min(by: { $0.percentage < $1.percentage })
        if let w = weakest, w.percentage < 70 {
            return w.name
        }
        return nil
    }
}

struct CategoryStat {
    let name: String
    var greatGoodCount: Int
    var total: Int

    var percentage: Int {
        total > 0 ? Int(round(Double(greatGoodCount) / Double(total) * 100)) : 0
    }
}

struct CategoryBarView: View {
    let name: String
    let percentage: Int
    let count: Int
    let total: Int

    private var barColor: Color {
        if percentage >= 70 { return PlayIQColors.resultGreat }
        if percentage >= 40 { return PlayIQColors.resultOkay }
        return PlayIQColors.resultBad
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name.capitalized)
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.text)
                Spacer()
                Text("\(percentage)%")
                    .font(PlayIQFonts.caption)
                    .foregroundColor(barColor)
                Text("(\(count)/\(total))")
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.textSecondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(PlayIQColors.cardBorder)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geometry.size.width * CGFloat(min(percentage, 100)) / 100, height: 8)
                }
            }
            .frame(height: 8)
        }
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

                Text(record.category.capitalized)
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
