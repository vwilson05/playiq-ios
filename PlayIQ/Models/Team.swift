import SwiftUI

struct MLBTeam: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let city: String
    let abbreviation: String
    let primaryHex: String
    let secondaryHex: String

    var primaryColor: Color {
        Color(hex: primaryHex)
    }

    var secondaryColor: Color {
        Color(hex: secondaryHex)
    }

    static func == (lhs: MLBTeam, rhs: MLBTeam) -> Bool {
        lhs.id == rhs.id
    }
}

extension MLBTeam {
    static let allTeams: [MLBTeam] = [
        // AL East
        MLBTeam(id: "bal", name: "Orioles", city: "Baltimore", abbreviation: "BAL", primaryHex: "#DF4601", secondaryHex: "#000000"),
        MLBTeam(id: "bos", name: "Red Sox", city: "Boston", abbreviation: "BOS", primaryHex: "#BD3039", secondaryHex: "#0C2340"),
        MLBTeam(id: "nyy", name: "Yankees", city: "New York", abbreviation: "NYY", primaryHex: "#003087", secondaryHex: "#C4CED4"),
        MLBTeam(id: "tb", name: "Rays", city: "Tampa Bay", abbreviation: "TB", primaryHex: "#092C5C", secondaryHex: "#8FBCE6"),
        MLBTeam(id: "tor", name: "Blue Jays", city: "Toronto", abbreviation: "TOR", primaryHex: "#134A8E", secondaryHex: "#1D2D5C"),

        // AL Central
        MLBTeam(id: "cws", name: "White Sox", city: "Chicago", abbreviation: "CWS", primaryHex: "#27251F", secondaryHex: "#C4CED4"),
        MLBTeam(id: "cle", name: "Guardians", city: "Cleveland", abbreviation: "CLE", primaryHex: "#00385D", secondaryHex: "#E50022"),
        MLBTeam(id: "det", name: "Tigers", city: "Detroit", abbreviation: "DET", primaryHex: "#0C2340", secondaryHex: "#FA4616"),
        MLBTeam(id: "kc", name: "Royals", city: "Kansas City", abbreviation: "KC", primaryHex: "#004687", secondaryHex: "#BD9B60"),
        MLBTeam(id: "min", name: "Twins", city: "Minnesota", abbreviation: "MIN", primaryHex: "#002B5C", secondaryHex: "#D31145"),

        // AL West
        MLBTeam(id: "hou", name: "Astros", city: "Houston", abbreviation: "HOU", primaryHex: "#002D62", secondaryHex: "#EB6E1F"),
        MLBTeam(id: "laa", name: "Angels", city: "Los Angeles", abbreviation: "LAA", primaryHex: "#BA0021", secondaryHex: "#003263"),
        MLBTeam(id: "oak", name: "Athletics", city: "Oakland", abbreviation: "OAK", primaryHex: "#003831", secondaryHex: "#EFB21E"),
        MLBTeam(id: "sea", name: "Mariners", city: "Seattle", abbreviation: "SEA", primaryHex: "#0C2C56", secondaryHex: "#005C5C"),
        MLBTeam(id: "tex", name: "Rangers", city: "Texas", abbreviation: "TEX", primaryHex: "#003278", secondaryHex: "#C0111F"),

        // NL East
        MLBTeam(id: "atl", name: "Braves", city: "Atlanta", abbreviation: "ATL", primaryHex: "#CE1141", secondaryHex: "#13274F"),
        MLBTeam(id: "mia", name: "Marlins", city: "Miami", abbreviation: "MIA", primaryHex: "#00A3E0", secondaryHex: "#EF3340"),
        MLBTeam(id: "nym", name: "Mets", city: "New York", abbreviation: "NYM", primaryHex: "#002D72", secondaryHex: "#FF5910"),
        MLBTeam(id: "phi", name: "Phillies", city: "Philadelphia", abbreviation: "PHI", primaryHex: "#E81828", secondaryHex: "#002D72"),
        MLBTeam(id: "wsh", name: "Nationals", city: "Washington", abbreviation: "WSH", primaryHex: "#AB0003", secondaryHex: "#14225A"),

        // NL Central
        MLBTeam(id: "chc", name: "Cubs", city: "Chicago", abbreviation: "CHC", primaryHex: "#0E3386", secondaryHex: "#CC3433"),
        MLBTeam(id: "cin", name: "Reds", city: "Cincinnati", abbreviation: "CIN", primaryHex: "#C6011F", secondaryHex: "#000000"),
        MLBTeam(id: "mil", name: "Brewers", city: "Milwaukee", abbreviation: "MIL", primaryHex: "#FFC52F", secondaryHex: "#12284B"),
        MLBTeam(id: "pit", name: "Pirates", city: "Pittsburgh", abbreviation: "PIT", primaryHex: "#27251F", secondaryHex: "#FDB827"),
        MLBTeam(id: "stl", name: "Cardinals", city: "St. Louis", abbreviation: "STL", primaryHex: "#C41E3A", secondaryHex: "#0C2340"),

        // NL West
        MLBTeam(id: "ari", name: "D-backs", city: "Arizona", abbreviation: "ARI", primaryHex: "#A71930", secondaryHex: "#E3D4AD"),
        MLBTeam(id: "col", name: "Rockies", city: "Colorado", abbreviation: "COL", primaryHex: "#33006F", secondaryHex: "#C4CED4"),
        MLBTeam(id: "lad", name: "Dodgers", city: "Los Angeles", abbreviation: "LAD", primaryHex: "#005A9C", secondaryHex: "#A5ACAF"),
        MLBTeam(id: "sd", name: "Padres", city: "San Diego", abbreviation: "SD", primaryHex: "#2F241D", secondaryHex: "#FFC425"),
        MLBTeam(id: "sf", name: "Giants", city: "San Francisco", abbreviation: "SF", primaryHex: "#FD5A1E", secondaryHex: "#27251F"),
    ]
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
