import SwiftUI

struct OutcomeView: View {
    let outcome: Outcome
    let onContinue: () -> Void

    private var resultColor: Color {
        PlayIQColors.resultColor(for: outcome.result)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Result header
            HStack(spacing: 10) {
                Image(systemName: PlayIQColors.resultIcon(for: outcome.result))
                    .font(.system(size: 24))
                    .foregroundColor(resultColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(outcome.result.uppercased())
                        .font(PlayIQFonts.caption)
                        .foregroundColor(resultColor)

                    Text(outcome.headline)
                        .font(PlayIQFonts.headline)
                        .foregroundColor(PlayIQColors.text)
                }

                Spacer()

                // IQ points
                VStack(spacing: 2) {
                    Text("+\(outcome.iqPoints)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(resultColor)
                    Text("IQ")
                        .font(PlayIQFonts.caption)
                        .foregroundColor(PlayIQColors.textSecondary)
                }
            }
            .padding(16)
            .background(resultColor.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(resultColor.opacity(0.3), lineWidth: 1)
            )

            // Explanation
            VStack(alignment: .leading, spacing: 8) {
                Label("What Happened", systemImage: "lightbulb.fill")
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.gold)

                Text(outcome.explanation)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .lineSpacing(4)
            }
            .padding(14)
            .background(PlayIQColors.card)
            .cornerRadius(10)

            // Key Terms
            if let keyTerms = outcome.keyTerms, !keyTerms.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Key Terms", systemImage: "book.fill")
                        .font(PlayIQFonts.caption)
                        .foregroundColor(PlayIQColors.gold)

                    ForEach(keyTerms) { term in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(term.term)
                                .font(PlayIQFonts.headline)
                                .foregroundColor(PlayIQColors.text)
                            Text(term.definition)
                                .font(PlayIQFonts.callout)
                                .foregroundColor(PlayIQColors.textSecondary)
                                .lineSpacing(2)
                        }
                    }
                }
                .padding(14)
                .background(PlayIQColors.card)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(PlayIQColors.gold.opacity(0.2), lineWidth: 1)
                )
            }

            // Remember This
            VStack(alignment: .leading, spacing: 8) {
                Label("Remember This", systemImage: "brain.head.profile.fill")
                    .font(PlayIQFonts.caption)
                    .foregroundColor(PlayIQColors.resultGood)

                Text(outcome.whatToRemember)
                    .font(PlayIQFonts.body)
                    .foregroundColor(PlayIQColors.text)
                    .lineSpacing(4)
            }
            .padding(14)
            .background(PlayIQColors.resultGood.opacity(0.08))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(PlayIQColors.resultGood.opacity(0.2), lineWidth: 1)
            )

            // Continue button
            Button(action: onContinue) {
                HStack {
                    Text("Next Scenario")
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
    }
}

#Preview {
    ScrollView {
        OutcomeView(
            outcome: Outcome(
                result: "great",
                headline: "Perfect relay throw!",
                explanation: "You hit the cutoff man perfectly, which allowed a strong throw to home plate.",
                whatToRemember: "Always hit the cutoff man to maintain accuracy on relay throws.",
                iqPoints: 25,
                keyTerms: [
                    KeyTerm(term: "Cutoff Man", definition: "The infielder who positions between the outfielder and the base to relay throws."),
                    KeyTerm(term: "Relay Throw", definition: "A throw from an outfielder to an infielder who then throws to a base.")
                ],
                next: nil
            ),
            onContinue: {}
        )
        .padding()
    }
    .background(PlayIQColors.background)
}
