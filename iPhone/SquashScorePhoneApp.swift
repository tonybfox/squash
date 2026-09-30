import SwiftUI

/// The iPhone app only exists to carry the watch app, so it can be installed
/// on the watch through the Watch app on the iPhone.
@main
struct SquashScorePhoneApp: App {
    var body: some Scene {
        WindowGroup {
            InstallInstructionsView()
        }
    }
}

struct InstallInstructionsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "applewatch")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("Squash")
                .font(.largeTitle.bold())

            Text("This app is only here to put Squash on your Apple Watch.")
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                Label("Open the Watch app on this iPhone.", systemImage: "1.circle.fill")
                Label("Scroll down to Available Apps.", systemImage: "2.circle.fill")
                Label("Tap Install next to Squash.", systemImage: "3.circle.fill")
            }
        }
        .padding(32)
    }
}

#Preview {
    InstallInstructionsView()
}
