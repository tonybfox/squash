import WatchConnectivity

/// Sends finished matches to the iPhone app, which keeps the match history.
///
/// Uses `transferUserInfo`, which queues each result and delivers it the next
/// time the iPhone app runs, so the phone doesn't need to be nearby.
final class MatchResultSender: NSObject, WCSessionDelegate {
    static let shared = MatchResultSender()

    /// Results waiting for the session to finish activating.
    private var pending: [MatchResult] = []

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func send(_ result: MatchResult) {
        pending.append(result)
        flush()
    }

    private func flush() {
        guard WCSession.default.activationState == .activated else { return }
        for result in pending {
            WCSession.default.transferUserInfo(result.userInfo)
        }
        pending.removeAll()
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async { self.flush() }
    }
}
