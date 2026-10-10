import SwiftUI
import WatchKit

struct ContentView: View {
    @State private var match = Match()
    @State private var isShowingResult = false

    var body: some View {
        GeometryReader { proxy in
            let insets = proxy.safeAreaInsets

            ZStack(alignment: .bottom) {
                HStack(spacing: 4) {
                    PlayerButton(player: .me, match: match, insets: insets,
                                 action: { tap(.me) }, removePoint: { removePoint(from: .me) })
                    PlayerButton(player: .them, match: match, insets: insets,
                                 action: { tap(.them) }, removePoint: { removePoint(from: .them) })
                }

                if match.hasStarted {
                    FinishButton(action: finish)
                        .padding(.bottom, insets.bottom + 4)
                }
            }
        }
        .ignoresSafeArea()
        .overlay {
            if isShowingResult {
                ResultView(match: match, action: startOver)
                    .ignoresSafeArea()
            }
        }
    }

    private func tap(_ player: Player) {
        switch match.tap(player) {
        case .choseFirstServer:
            WKInterfaceDevice.current().play(.start)
        case .point:
            WKInterfaceDevice.current().play(.directionUp)
        case .gameWon:
            WKInterfaceDevice.current().play(.success)
        }
    }

    private func removePoint(from player: Player) {
        if match.removePoint(from: player) {
            WKInterfaceDevice.current().play(.directionDown)
        }
    }

    private func finish() {
        if !match.completedGames.isEmpty {
            MatchResultSender.shared.send(match.result)
        }
        WKInterfaceDevice.current().play(.stop)
        isShowingResult = true
    }

    private func startOver() {
        match = Match()
        isShowingResult = false
    }
}

extension Player {
    var color: Color { self == .me ? .blue : .red }
    var name: String { self == .me ? "ME" : "THEM" }
}

/// One half of the screen: serve dot at the top, points in the middle,
/// games won at the bottom, and a minus button in the outer top corner.
private struct PlayerButton: View {
    let player: Player
    let match: Match
    let insets: EdgeInsets
    let action: () -> Void
    let removePoint: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Circle()
                    .frame(width: 12, height: 12)
                    .opacity(match.server == player ? 1 : 0)

                Spacer(minLength: 0)

                Text(match.hasStarted ? "\(match.points[player])" : "-")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)

                Spacer(minLength: 0)

                GameTally(count: match.games[player])
            }
            .foregroundStyle(.white)
            .padding(.top, insets.top + 4)
            .padding(.bottom, insets.bottom + 12)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(player.color, in: RoundedRectangle(cornerRadius: 10))
            .contentShape(Rectangle())
        }
        .buttonStyle(DimWhenPressed())
        // Overlaid rather than inside the label, so tapping it never also
        // scores a point.
        .overlay(alignment: player == .me ? .topLeading : .topTrailing) {
            if match.hasStarted {
                MinusButton(isActive: match.canRemovePoint(from: player), action: removePoint)
                    // Level with the serve dot.
                    .padding(.top, insets.top + 10 - MinusButton.size / 2)
            }
        }
    }
}

/// Takes a point back off one side. Dimmed when there is nothing to take
/// back, but still swallows taps so they don't score a point underneath.
private struct MinusButton: View {
    static let size: CGFloat = 32

    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "minus")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.black.opacity(0.3), in: Circle())
                .opacity(isActive ? 1 : 0.35)
                .frame(width: Self.size, height: Self.size)
                .contentShape(Rectangle())
        }
        .buttonStyle(DimWhenPressed())
    }
}

/// A dot per game won, or a dot and a number once there are too many to fit.
private struct GameTally: View {
    let count: Int

    var body: some View {
        HStack(spacing: 3) {
            if count > 5 {
                dot
                Text("\(count)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            } else {
                ForEach(0..<count, id: \.self) { _ in
                    dot
                }
            }
        }
        .frame(height: 13)
    }

    private var dot: some View {
        Circle().frame(width: 7, height: 7)
    }
}

private struct FinishButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Color.black, in: Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.7), lineWidth: 1.5))
        }
        .buttonStyle(DimWhenPressed())
    }
}

/// Full-screen match result. Tapping it starts a new match.
private struct ResultView: View {
    let match: Match
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(match.leader == nil ? "DRAW" : "WINNER")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .opacity(0.85)

                if let winner = match.leader {
                    Text(winner.name)
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }

                Text(gamesLine)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text("Tap to start again")
                    .font(.footnote)
                    .opacity(0.8)
                    .padding(.top, 8)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(match.leader?.color ?? Color(white: 0.25))
            .contentShape(Rectangle())
        }
        .buttonStyle(DimWhenPressed())
    }

    /// Games won, winner's first.
    private var gamesLine: String {
        let first = match.leader ?? .me
        return "\(match.games[first]) – \(match.games[first.opponent])"
    }
}

private struct DimWhenPressed: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
    }
}

#Preview {
    ContentView()
}
