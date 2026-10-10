import SwiftUI

@main
struct SquashScoreApp: App {
    init() {
        MatchResultSender.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
