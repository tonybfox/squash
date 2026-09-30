import SwiftUI
import WatchConnectivity

/// Finished matches received from the watch, newest first, saved on the iPhone.
final class MatchHistory: NSObject, ObservableObject, WCSessionDelegate {
    @Published private(set) var results: [MatchResult] = []

    private let fileURL = URL.documentsDirectory.appending(path: "match-history.json")

    override init() {
        super.init()
        if let data = try? Data(contentsOf: fileURL),
           let saved = try? JSONDecoder().decode([MatchResult].self, from: data) {
            results = saved
        }
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func delete(at offsets: IndexSet) {
        results.remove(atOffsets: offsets)
        save()
    }

    private func add(_ result: MatchResult) {
        guard !results.contains(where: { $0.id == result.id }) else { return }
        results.append(result)
        results.sort { $0.date > $1.date }
        save()
    }

    private func save() {
        try? JSONEncoder().encode(results).write(to: fileURL, options: .atomic)
    }

    // MARK: WCSessionDelegate

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        guard let result = MatchResult(userInfo: userInfo) else { return }
        DispatchQueue.main.async { self.add(result) }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // Reactivate so results still arrive after switching watches.
        session.activate()
    }
}

extension MatchResult {
    enum Outcome {
        case won, lost, drawn
    }

    var outcome: Outcome {
        if gamesWonByMe == gamesWonByThem { return .drawn }
        return gamesWonByMe > gamesWonByThem ? .won : .lost
    }
}
