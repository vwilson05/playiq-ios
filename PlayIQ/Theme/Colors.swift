import SwiftUI

enum PlayIQColors {
    static let background = Color(hex: "#0a0e17")
    static let card = Color(hex: "#141a28")
    static let cardBorder = Color(hex: "#1e2a3f")
    static let text = Color(hex: "#f0f2f5")
    static let textSecondary = Color(hex: "#8899aa")
    static let gold = Color(hex: "#f5a623")
    static let goldDark = Color(hex: "#c4841c")

    static let resultGreat = Color(hex: "#22c55e")
    static let resultGood = Color(hex: "#3b82f6")
    static let resultOkay = Color(hex: "#eab308")
    static let resultBad = Color(hex: "#fb923c") // orange — opportunity, not punishment

    static let fieldGreen = Color(hex: "#2d5a27")
    static let fieldDirt = Color(hex: "#c4a265")
    static let scoreboardGreen = Color(hex: "#0a3d0a")

    static func resultColor(for result: String) -> Color {
        switch result.lowercased() {
        case "great": return resultGreat
        case "good": return resultGood
        case "okay": return resultOkay
        case "bad": return resultBad
        default: return resultGood
        }
    }

    static func resultIcon(for result: String) -> String {
        switch result.lowercased() {
        case "great": return "star.fill"
        case "good": return "hand.thumbsup.fill"
        case "okay": return "minus.circle.fill"
        case "bad": return "lightbulb.fill" // opportunity to learn
        default: return "questionmark.circle.fill"
        }
    }
}
