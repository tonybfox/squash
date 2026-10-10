# Squash

A tiny Apple Watch app for keeping score of a squash match while you play.
Runs on watchOS 10 or later. The watch starts fresh for every match, and the
iPhone app keeps a history of finished matches.

## Using it

- The screen is split in two: **blue on the left is me**, **red on the right is them**.
  Both start as `-`.
- **First tap** picks who serves first: a dot appears at the top of their side
  and both scores go to `0`.
- **Every tap after that** gives a point to that side. The serve dot follows
  the server — whoever won the last rally.
- Games use normal point-a-rally scoring: first to 11, but you must win by 2,
  so it can go past 11 (12–10, 15–13, …).
- When someone wins a game, a dot is added to the bottom of their side, the
  scores reset to `0`, and the game winner serves first in the next game.
  After 5 games a side shows a dot and a number instead of more dots.
- Tapped the wrong side? The small **minus button** in the top outer corner of
  each side takes that side's last point back, and the serve dot goes back to
  who was serving before it. At `0–0` it can take back the point that just won
  a game, and before any points it undoes picking the first server. It's
  dimmed when that side has nothing to take back.
- The small **flag button** at the bottom middle finishes the match and shows
  the winner (ME or THEM, or DRAW) with the games score. Tap that screen again
  to go back to the start.

## Match history

When you finish a match with the flag button, the watch sends the result to
the **Squash** app on your iPhone. It shows your won/lost record and every
match with its date, games score and each game's points. Swipe left on a match
to delete it. The phone doesn't need to be nearby: results are queued and
arrive the next time you open the iPhone app. Matches finished before a single
game was completed aren't recorded.

## Installing on your watch

You need a Mac with Xcode 15 or later, and the iPhone your watch is paired with.

The watch app is carried inside a small iPhone app, so Xcode only has to talk
to the iPhone over its cable. The iPhone then hands the app to the watch.

1. Open `SquashScore.xcodeproj` in Xcode.
2. For **both** targets, **SquashScore** and **SquashScore Watch App**, open
   **Signing & Capabilities** and pick your **Team** (a free personal team with
   your Apple ID works, but the app then needs reinstalling every 7 days). If
   Xcode says a bundle identifier is taken, change `com.tonybfox` in both
   bundle identifiers and in `SquashScore/Info.plist` to something unique.
3. Plug the iPhone into the Mac, unlock it, and make sure **Developer Mode** is
   on (Settings → Privacy & Security → Developer Mode).
4. At the top of the Xcode window pick the **SquashScore** scheme and your
   **iPhone** as the run destination, then press **Run** (⌘R). A "Squash"
   screen with install instructions opens on the phone. If the phone says the
   developer isn't trusted, go to Settings → General → VPN & Device Management,
   trust your Apple ID, and press Run again.
5. On the iPhone, open the **Watch** app, scroll down to **Available Apps**, and
   tap **Install** next to **Squash**. It can take a minute or two to appear on
   the watch.
6. Open Squash on the watch. If it says Developer Mode is required, go to
   **Settings → Privacy & Security → Developer Mode** on the watch, turn it on,
   and let the watch restart.

If Xcode can connect to your watch directly, you can instead pick the
**SquashScore Watch App** scheme with the watch as the run destination.

### Keeping it on screen during a match

By default the watch goes back to the clock face a couple of minutes after you
lower your wrist. To stop that mid-match, on the watch go to
**Settings → General → Return to Clock** and choose **After 1 hour** (or pick
Squash in the app list there and turn on **Return to App**).
