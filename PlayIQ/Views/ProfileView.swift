import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var playerStore: PlayerStore
    @Environment(\.dismiss) var dismiss

    @State private var profile: PlayerProfile?
    @State private var awards: [PlayerAward] = []
    @State private var sessionHistory: [SessionHistory] = []
    @State private var isLoading = true
    @State private var loadError: String?

    private let apiClient = APIClient()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if playerStore.isGuest {
                        guestContent
                    } else if isLoading {
                        loadingContent
                    } else if let error = loadError {
                        errorContent(error)
                    } else {
                        loggedInContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(PlayIQColors.background.ignoresSafeArea())
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(PlayIQColors.gold)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            loadProfileData()
        }
    }

    // MARK: - Guest Content

    private var guestContent: some View {
        VStack(spacing: 24) {
            // Guest header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(PlayIQColors.gold.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundColor(PlayIQColors.gold)
                }

                Text("Guest Player")
                    .font(PlayIQFonts.title)
                    .foregroundColor(PlayIQColors.text)

                Text("\(gameState.totalIQ) IQ")
                    .font(PlayIQFonts.iqScore)
                    .foregroundColor(PlayIQColors.gold)

                Text("This session only")
                    .font(PlayIQFonts.callout)
                    .foregroundColor(PlayIQColors.textSecondary)
            }
            .padding(.top, 24)

            // CTA
            VStack(spacing: 12) {
                Text("Create an account to save your progress, earn awards, and track your improvement over time.")
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                Button(action: {
                    dismiss()
                    gameState.reset()
                    playerStore.logout()
                }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Create Account to Save Progress")
                            .font(PlayIQFonts.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(PlayIQColors.gold)
                    .foregroundColor(PlayIQColors.background)
                    .cornerRadius(10)
                }
            }
            .padding(20)
            .background(PlayIQColors.card)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(PlayIQColors.gold.opacity(0.3), lineWidth: 1)
            )

            // Session-local category stats
            let localCats = localCategoryData
            if !localCats.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Session Stats")
                        .font(PlayIQFonts.headline)
                        .foregroundColor(PlayIQColors.text)

                    ForEach(localCats, id: \.name) { cat in
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
        }
    }

    // MARK: - Logged-In Content

    private var loggedInContent: some View {
        VStack(spacing: 24) {
            // Player header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(PlayIQColors.gold.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundColor(PlayIQColors.gold)
                }

                Text(profile?.displayName ?? playerStore.currentPlayer?.displayName ?? "Player")
                    .font(PlayIQFonts.title)
                    .foregroundColor(PlayIQColors.text)

                Text("\(profile?.cumulativeIQ ?? playerStore.currentPlayer?.cumulativeIQ ?? 0)")
                    .font(PlayIQFonts.iqScore)
                    .foregroundColor(PlayIQColors.gold)

                Text("Cumulative IQ")
                    .font(PlayIQFonts.callout)
                    .foregroundColor(PlayIQColors.textSecondary)

                // Overall grade
                let totalSessions = profile?.totalSessions ?? playerStore.currentPlayer?.totalSessions ?? 0
                Text("\(totalSessions) session\(totalSessions != 1 ? "s" : "") played")
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.textSecondary)
            }
            .padding(.top, 24)

            // Token balance
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 20))
                    Text("Token Balance: \(profile?.cumulativeIQ ?? playerStore.currentPlayer?.cumulativeIQ ?? 0)")
                        .font(PlayIQFonts.headline)
                }
                .foregroundColor(PlayIQColors.gold)

                Text("Tokens unlock rewards -- coming soon")
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(PlayIQColors.gold.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(PlayIQColors.gold.opacity(0.3), lineWidth: 1)
            )

            // Category Mastery
            if let categories = profile?.categories, !categories.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category Mastery")
                        .font(PlayIQFonts.headline)
                        .foregroundColor(PlayIQColors.text)

                    ForEach(categories) { cat in
                        CategoryBarView(
                            name: cat.category,
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

            // Awards
            VStack(alignment: .leading, spacing: 12) {
                Text("Awards")
                    .font(PlayIQFonts.headline)
                    .foregroundColor(PlayIQColors.text)

                if awards.isEmpty {
                    Text("Keep playing to earn awards!")
                        .font(PlayIQFonts.callout)
                        .foregroundColor(PlayIQColors.textSecondary)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(awards) { award in
                            VStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(PlayIQColors.gold)

                                Text(award.awardName)
                                    .font(PlayIQFonts.caption)
                                    .foregroundColor(PlayIQColors.text)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)

                                if let date = award.earnedAt {
                                    Text(formatDate(date))
                                        .font(.system(size: 10, weight: .regular, design: .rounded))
                                        .foregroundColor(PlayIQColors.textSecondary)
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(PlayIQColors.card)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(PlayIQColors.gold.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding(16)
            .background(PlayIQColors.card)
            .cornerRadius(12)

            // Recent Sessions
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Sessions")
                    .font(PlayIQFonts.headline)
                    .foregroundColor(PlayIQColors.text)

                if sessionHistory.isEmpty {
                    Text("No sessions recorded yet.")
                        .font(PlayIQFonts.callout)
                        .foregroundColor(PlayIQColors.textSecondary)
                } else {
                    ForEach(Array(sessionHistory.prefix(5))) { session in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(session.tier?.replacingOccurrences(of: "-", with: " ").capitalized ?? "Unknown")
                                        .font(PlayIQFonts.headline)
                                        .foregroundColor(PlayIQColors.text)

                                    if let grade = session.grade {
                                        Text("(\(grade))")
                                            .font(PlayIQFonts.caption)
                                            .foregroundColor(PlayIQColors.textSecondary)
                                    }
                                }

                                if let date = session.createdAt {
                                    Text(formatDate(date))
                                        .font(PlayIQFonts.caption)
                                        .foregroundColor(PlayIQColors.textSecondary)
                                }
                            }

                            Spacer()

                            Text("\(session.totalIQ ?? 0) IQ")
                                .font(PlayIQFonts.scoreboard)
                                .foregroundColor(PlayIQColors.gold)
                        }
                        .padding(12)
                        .background(PlayIQColors.background)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(16)
            .background(PlayIQColors.card)
            .cornerRadius(12)
        }
    }

    // MARK: - Loading / Error

    private var loadingContent: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 80)
            ProgressView()
                .tint(PlayIQColors.gold)
                .scaleEffect(1.5)
            Text("Loading profile...")
                .font(PlayIQFonts.callout)
                .foregroundColor(PlayIQColors.textSecondary)
        }
    }

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 80)
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundColor(PlayIQColors.resultOkay)
            Text(message)
                .font(PlayIQFonts.body)
                .foregroundColor(PlayIQColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Data Loading

    private func loadProfileData() {
        guard !playerStore.isGuest, let player = playerStore.currentPlayer else {
            isLoading = false
            return
        }

        Task {
            do {
                async let profileReq = apiClient.fetchPlayerProfile(id: player.id)
                async let awardsReq = apiClient.fetchPlayerAwards(id: player.id)
                async let historyReq = apiClient.fetchPlayerHistory(id: player.id)

                let (p, a, h) = try await (profileReq, awardsReq, historyReq)
                profile = p
                awards = a
                sessionHistory = h
            } catch {
                // Partial fallback: use local player data
                loadError = nil
            }
            isLoading = false
        }
    }

    // MARK: - Helpers

    private var localCategoryData: [CategoryStat] {
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
        return map.values.sorted { $0.name < $1.name }
    }

    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: isoString) {
            let display = DateFormatter()
            display.dateStyle = .medium
            return display.string(from: date)
        }
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: isoString) {
            let display = DateFormatter()
            display.dateStyle = .medium
            return display.string(from: date)
        }
        return isoString
    }
}

#Preview {
    ProfileView()
        .environmentObject(GameState())
        .environmentObject(PlayerStore())
}
