/// A player in the match. `me` is the left button, `them` the right.
enum Player {
    case me, them

    var opponent: Player { self == .me ? .them : .me }
}

/// Points or games won by each player.
struct Tally {
    var me = 0
    var them = 0

    subscript(player: Player) -> Int {
        get { player == .me ? me : them }
        set {
            if player == .me { me = newValue } else { them = newValue }
        }
    }
}

/// A squash match using point-a-rally scoring: games to 11, win by 2.
struct Match {
    enum TapResult {
        case choseFirstServer
        case point
        case gameWon
    }

    /// Who serves next. `nil` until the first tap picks the first server.
    private(set) var server: Player?
    private(set) var points = Tally()
    private(set) var games = Tally()
    /// Final points of each completed game, in order.
    private(set) var completedGames: [Tally] = []

    var hasStarted: Bool { server != nil }

    /// The player with more games won, or `nil` if level.
    var leader: Player? {
        if games.me == games.them { return nil }
        return games.me > games.them ? .me : .them
    }

    mutating func tap(_ player: Player) -> TapResult {
        guard hasStarted else {
            server = player
            return .choseFirstServer
        }

        points[player] += 1
        // The rally winner serves next. That also makes the winner of a game
        // serve first in the following game.
        server = player

        if points[player] >= 11 && points[player] - points[player.opponent] >= 2 {
            games[player] += 1
            completedGames.append(points)
            points = Tally()
            return .gameWon
        }
        return .point
    }
}

extension Match {
    /// This match as recorded in the iPhone's match history.
    var result: MatchResult {
        MatchResult(games: completedGames.map { MatchResult.Game(me: $0.me, them: $0.them) })
    }
}
