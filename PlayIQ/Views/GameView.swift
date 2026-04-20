import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var playerStore: PlayerStore
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            GameHeaderView()

            if gameState.isLoadingScenario {
                Spacer()
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(PlayIQColors.gold)
                        .scaleEffect(1.5)
                    Text("Loading scenario...")
                        .font(PlayIQFonts.callout)
                        .foregroundColor(PlayIQColors.textSecondary)
                }
                Spacer()
            } else if let node = gameState.currentNode {
                if sizeClass == .regular {
                    // iPad: side-by-side
                    iPadLayout(node: node)
                } else {
                    // iPhone: stacked
                    iPhoneLayout(node: node)
                }
            } else {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "baseball.diamond.bases")
                        .font(.system(size: 48))
                        .foregroundColor(PlayIQColors.textSecondary)
                    Text("No scenario loaded")
                        .font(PlayIQFonts.headline)
                        .foregroundColor(PlayIQColors.textSecondary)

                    Button("Load Scenario") {
                        Task { await gameState.loadNextScenario() }
                    }
                    .font(PlayIQFonts.headline)
                    .foregroundColor(PlayIQColors.background)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(PlayIQColors.gold)
                    .cornerRadius(10)
                }
                Spacer()
            }
        }
        .background(PlayIQColors.background.ignoresSafeArea())
        .sheet(isPresented: $gameState.showMenu) {
            MenuView()
        }
    }

    @ViewBuilder
    private func iPadLayout(node: ScenarioNode) -> some View {
        HStack(spacing: 0) {
            // Left: Scenario content
            ScrollView {
                scenarioContent(node: node)
                    .padding(24)
            }
            .frame(maxWidth: .infinity)

            // Right: Field + Scoreboard
            VStack(spacing: 16) {
                Spacer()
                FieldView(setup: gameState.currentSetup)
                ScoreboardView(setup: gameState.currentSetup)
                if let setup = gameState.currentSetup {
                    runnersLabel(setup: setup)
                }
                Spacer()
            }
            .frame(width: 340)
            .padding(16)
            .background(PlayIQColors.card.opacity(0.5))
        }
    }

    @ViewBuilder
    private func iPhoneLayout(node: ScenarioNode) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Compact field + scoreboard
                HStack(alignment: .top, spacing: 12) {
                    FieldView(setup: gameState.currentSetup, compact: true)
                    VStack(spacing: 8) {
                        ScoreboardView(setup: gameState.currentSetup, compact: true)
                        if let setup = gameState.currentSetup {
                            runnersLabel(setup: setup)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Scenario content
                scenarioContent(node: node)
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private func scenarioContent(node: ScenarioNode) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Scenario title
            if let scenario = gameState.currentScenario {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(PlayIQColors.gold)
                    Text("You are the \(scenario.role)")
                        .font(PlayIQFonts.caption)
                        .foregroundColor(PlayIQColors.gold)
                }
            }

            // Impact multiplier banner
            if let scenario = gameState.currentScenario,
               scenario.tokenMultiplier >= 2,
               let label = scenario.multiplierLabel {
                HStack(spacing: 8) {
                    Text(label.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(PlayIQColors.text)
                        .tracking(0.5)
                    Text("\(scenario.tokenMultiplier)x Token Multiplier")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(PlayIQColors.gold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(PlayIQColors.gold.opacity(0.15))
                        .cornerRadius(4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(PlayIQColors.gold.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(PlayIQColors.gold.opacity(0.25), lineWidth: 1)
                        )
                )
            }

            // Narration
            if let narration = node.narration {
                Text(narration)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .lineSpacing(4)
            }

            // Decision choices
            if node.type == "decision", let choices = node.choices {
                let shuffledChoices = choices.shuffled()
                VStack(spacing: 10) {
                    ForEach(Array(shuffledChoices.enumerated()), id: \.element.id) { index, choice in
                        // Filter by sport if onlyIn is set
                        if choice.onlyIn == nil || choice.onlyIn == gameState.selectedSport {
                            if let disabledReason = choice.disabledReason {
                                // Disabled choice
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(PlayIQColors.textSecondary.opacity(0.3))
                                            .frame(width: 32, height: 32)
                                        Text(String(Character(UnicodeScalar(65 + index)!)))
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(PlayIQColors.textSecondary)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(choice.text)
                                            .font(PlayIQFonts.body)
                                            .foregroundColor(PlayIQColors.textSecondary)
                                        Text(disabledReason)
                                            .font(PlayIQFonts.caption)
                                            .foregroundColor(PlayIQColors.textSecondary.opacity(0.7))
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .background(PlayIQColors.card.opacity(0.5))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(PlayIQColors.cardBorder.opacity(0.5), lineWidth: 1)
                                )
                            } else {
                                ChoiceButton(
                                    letter: String(Character(UnicodeScalar(65 + index)!)),
                                    text: choice.text
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        gameState.makeChoice(choice)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Transition auto-advance
            if node.type == "transition", let next = node.next {
                Button(action: {
                    withAnimation {
                        gameState.advanceToNode(next)
                    }
                }) {
                    HStack {
                        Text("Continue")
                            .font(PlayIQFonts.headline)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(PlayIQColors.gold)
                    .foregroundColor(PlayIQColors.background)
                    .cornerRadius(10)
                }
            }

            // Outcome
            if node.type == "outcome", let outcome = node.outcome {
                let hasMoreNodes = outcome.next != nil && outcome.next != "end"
                let allDone = gameState.scenarioIndex >= gameState.scenarioList.count || (gameState.scenariosCompleted + 1) >= gameState.scenariosPerRound
                let label = hasMoreNodes ? "Continue" : (allDone ? "See Results" : "Next Scenario")

                OutcomeView(outcome: outcome, buttonLabel: label, multiplier: gameState.currentScenario?.tokenMultiplier ?? 1) {
                    gameState.recordOutcome(outcome, category: gameState.currentScenario?.role ?? "general")
                    if hasMoreNodes, let next = outcome.next {
                        // More nodes in this scenario — continue
                        withAnimation {
                            gameState.advanceToNode(next)
                        }
                    } else {
                        // Scenario complete (next is nil or "end") — save result and load next
                        Task {
                            await gameState.saveCurrentResult()
                            await gameState.loadNextScenario()
                        }
                    }
                }
            }
        }
    }

    private func runnersLabel(setup: GameSetup) -> some View {
        Text(setup.runners.description)
            .font(PlayIQFonts.caption)
            .foregroundColor(PlayIQColors.textSecondary)
    }
}

struct ChoiceButton: View {
    let letter: String
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(PlayIQColors.gold)
                        .frame(width: 32, height: 32)

                    Text(letter)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(PlayIQColors.background)
                }

                Text(text)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(PlayIQColors.textSecondary)
            }
            .padding(14)
            .background(PlayIQColors.card)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(PlayIQColors.cardBorder, lineWidth: 1)
            )
        }
    }
}

struct GameHeaderView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        HStack {
            // Logo
            HStack(spacing: 2) {
                Text("PLAY")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(PlayIQColors.text)
                Text("IQ")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(PlayIQColors.gold)
            }

            Spacer()

            // Tier badge
            if let tier = gameState.selectedTier {
                Text(tier.replacingOccurrences(of: "-", with: " ").capitalized)
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(PlayIQColors.gold.opacity(0.15))
                    .cornerRadius(8)
            }

            // IQ Display
            HStack(spacing: 4) {
                Image(systemName: "brain.fill")
                    .font(.system(size: 12))
                Text("\(gameState.totalIQ)")
                    .font(PlayIQFonts.scoreboard)
            }
            .foregroundColor(PlayIQColors.gold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(PlayIQColors.card)
            .cornerRadius(8)

            // Token Display
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 12))
                Text("\(gameState.totalTokens)")
                    .font(PlayIQFonts.scoreboard)
            }
            .foregroundColor(PlayIQColors.gold.opacity(0.8))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(PlayIQColors.card)
            .cornerRadius(8)

            // Menu
            Button(action: { gameState.showMenu = true }) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18))
                    .foregroundColor(PlayIQColors.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(PlayIQColors.card.opacity(0.8))
    }
}

#Preview {
    GameView()
        .environmentObject(GameState())
        .environmentObject(PlayerStore())
}
