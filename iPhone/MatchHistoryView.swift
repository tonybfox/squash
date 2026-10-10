import SwiftUI

struct MatchHistoryView: View {
    @ObservedObject var history: MatchHistory

    var body: some View {
        NavigationStack {
            List {
                if history.results.isEmpty {
                    ContentUnavailableView(
                        "No matches yet",
                        systemImage: "applewatch",
                        description: Text("Finish a match on your watch with the flag button and it will appear here.")
                    )
                } else {
                    Section {
                        RecordSummary(results: history.results)
                    }

                    Section("Matches") {
                        ForEach(history.results) { result in
                            MatchRow(result: result)
                        }
                        .onDelete(perform: history.delete)
                    }
                }

                Section("Watch app") {
                    Text("To install Squash on your watch, open the Watch app on this iPhone, scroll down to Available Apps and tap Install.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Squash")
        }
    }
}

/// Matches won, lost and drawn.
private struct RecordSummary: View {
    let results: [MatchResult]

    var body: some View {
        HStack {
            Stat(title: "Won", value: count(.won), color: .blue)
            Stat(title: "Lost", value: count(.lost), color: .red)
            if count(.drawn) > 0 {
                Stat(title: "Drawn", value: count(.drawn), color: .gray)
            }
        }
        .padding(.vertical, 4)
    }

    private func count(_ outcome: MatchResult.Outcome) -> Int {
        results.filter { $0.outcome == outcome }.count
    }
}

private struct Stat: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MatchRow: View {
    let result: MatchResult

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 52, height: 28)
                .background(color, in: RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(result.gamesWonByMe) – \(result.gamesWonByThem)")
                    .font(.headline)
                    .monospacedDigit()
                // Word joiners stop a game's score wrapping at the dash.
                Text(result.games.map { "\($0.me)\u{2060}–\u{2060}\($0.them)" }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Spacer()

            Text(result.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private var label: String {
        switch result.outcome {
        case .won: "WIN"
        case .lost: "LOSS"
        case .drawn: "DRAW"
        }
    }

    private var color: Color {
        switch result.outcome {
        case .won: .blue
        case .lost: .red
        case .drawn: .gray
        }
    }
}
