import SwiftUI

struct ScoreboardView: View {
    let setup: GameSetup?
    var compact: Bool = false

    var body: some View {
        if let setup = setup {
            VStack(spacing: compact ? 4 : 8) {
                // Inning
                HStack {
                    Image(systemName: setup.topBottom == "top" ? "arrow.up" : "arrow.down")
                        .font(.system(size: compact ? 10 : 12))
                    Text("Inning \(setup.inning)")
                        .font(compact ? PlayIQFonts.caption : PlayIQFonts.scoreboard)
                }
                .foregroundColor(.white)

                // Score row
                HStack(spacing: compact ? 12 : 24) {
                    VStack(spacing: 2) {
                        Text("AWAY")
                            .font(.system(size: compact ? 8 : 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(setup.score.away)")
                            .font(.system(size: compact ? 18 : 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }

                    Rectangle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 1, height: compact ? 24 : 32)

                    VStack(spacing: 2) {
                        Text("HOME")
                            .font(.system(size: compact ? 8 : 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(setup.score.home)")
                            .font(.system(size: compact ? 18 : 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }

                // Outs
                HStack(spacing: 6) {
                    Text("OUTS")
                        .font(.system(size: compact ? 9 : 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))

                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(i < setup.outs ? PlayIQColors.gold : .white.opacity(0.2))
                                .frame(width: compact ? 10 : 14, height: compact ? 10 : 14)
                        }
                    }
                }
            }
            .padding(.horizontal, compact ? 12 : 20)
            .padding(.vertical, compact ? 8 : 12)
            .background(PlayIQColors.scoreboardGreen)
            .cornerRadius(compact ? 8 : 12)
            .overlay(
                RoundedRectangle(cornerRadius: compact ? 8 : 12)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ScoreboardView(setup: GameSetup(
        inning: 7,
        topBottom: "bottom",
        outs: 2,
        score: Score(home: 3, away: 5),
        runners: Runners(first: true, second: false, third: false)
    ))
    .padding()
    .background(PlayIQColors.background)
}
