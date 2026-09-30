# Squash

A tiny Apple Watch app for keeping score of a squash match while you play.
Runs on watchOS 10 or later. Nothing is saved between matches.

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
- The small **flag button** at the bottom middle finishes the match and shows
  the winner (ME or THEM, or DRAW) with the games score. Tap that screen again
  to go back to the start.

## Installing on your watch

You need a Mac with Xcode 15 or later, and the iPhone your watch is paired with.

1. Open `SquashScore.xcodeproj` in Xcode.
2. Select the **SquashScore** target → **Signing & Capabilities** and pick your
   **Team** (a free personal team with your Apple ID works, but the app then
   needs reinstalling every 7 days). If Xcode says the bundle identifier is
   taken, change `com.tonybfox.SquashScore.watchkitapp` to something unique.
3. Plug the iPhone into the Mac. Turn on **Developer Mode** on the iPhone
   (Settings → Privacy & Security) and on the watch (Settings → Privacy &
   Security) when prompted.
4. Choose your Apple Watch as the run destination at the top of the Xcode
   window and press **Run** (⌘R). The app appears on the watch as **Squash**.

### Keeping it on screen during a match

By default the watch goes back to the clock face a couple of minutes after you
lower your wrist. To stop that mid-match, on the watch go to
**Settings → General → Return to Clock** and choose **After 1 hour** (or pick
Squash in the app list there and turn on **Return to App**).
