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
    /// Who served first, and every rally winner since, in order. Kept so a
    /// point can be taken back by replaying the match without it.
    private var firstServer: Player?
    private var rallies: [Player] = []

    var hasStarted: Bool { server != nil }

    /// The player with more games won, or `nil` if level.
    var leader: Player? {
        if games.me == games.them { return nil }
        return games.me > games.them ? .me : .them
    }

    mutating func tap(_ player: Player) -> TapResult {
        guard hasStarted else {
            server = player
            firstServer = player
            return .choseFirstServer
        }

        rallies.append(player)
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

    /// Whether `removePoint(from:)` has anything to take back.
    func canRemovePoint(from player: Player) -> Bool {
        rallies.isEmpty ? server == player : indexOfPointToRemove(from: player) != nil
    }

    /// Takes back the last point `player` won in this game, as if that rally
    /// never happened, so the score and server go back to how they were.
    /// At 0–0 it takes back the point that won the previous game, if `player`
    /// won it. Before any points it undoes picking `player` as first server.
    mutating func removePoint(from player: Player) -> Bool {
        guard canRemovePoint(from: player) else { return false }
        guard let firstServer, let index = indexOfPointToRemove(from: player) else {
            self = Match()
            return true
        }

        var replayed = Match()
        _ = replayed.tap(firstServer)
        for (i, winner) in rallies.enumerated() where i != index {
            _ = replayed.tap(winner)
        }
        self = replayed
        return true
    }

    private func indexOfPointToRemove(from player: Player) -> Int? {
        let isNewGame = points.me == 0 && points.them == 0
        guard points[player] > 0 || (isNewGame && rallies.last == player) else { return nil }
        return rallies.lastIndex(of: player)
    }
}

extension Match {
    /// This match as recorded in the iPhone's match history.
    var result: MatchResult {
        MatchResult(games: completedGames.map { MatchResult.Game(me: $0.me, them: $0.them) })
    }
}
