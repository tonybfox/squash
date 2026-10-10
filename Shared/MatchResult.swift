import Foundation

/// A finished match, sent from the watch to the iPhone for the match history.
struct MatchResult: Codable, Identifiable, Equatable {
    /// Points scored in one completed game.
    struct Game: Codable, Equatable {
        var me: Int
        var them: Int
    }

    var id = UUID()
    var date = Date()
    /// Completed games in the order they were played.
    var games: [Game]

    var gamesWonByMe: Int { games.filter { $0.me > $0.them }.count }
    var gamesWonByThem: Int { games.count - gamesWonByMe }
}

// MARK: - Watch Connectivity payload

extension MatchResult {
    private static let userInfoKey = "matchResult"

    var userInfo: [String: Any] {
        [Self.userInfoKey: (try? JSONEncoder().encode(self)) ?? Data()]
    }

    init?(userInfo: [String: Any]) {
        guard let data = userInfo[Self.userInfoKey] as? Data,
              let result = try? JSONDecoder().decode(MatchResult.self, from: data)
        else { return nil }
        self = result
    }
}
