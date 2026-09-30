import SwiftUI

/// Carries the watch app and keeps the history of matches finished on the watch.
@main
struct SquashScorePhoneApp: App {
    @StateObject private var history = MatchHistory()

    var body: some Scene {
        WindowGroup {
            MatchHistoryView(history: history)
        }
    }
}
