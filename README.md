# DAILY GAMBIT ANDROID

Independent Android release channel for `Daily Gambit`, an offline-first premium-casual chess MVP.

## What This Repo Is

- Standalone Flutter workspace for Android testing and GitHub Releases
- Safe to keep separate from every other repo/worktree
- Intended as the phone-install path: build -> GitHub Release -> APK download

## Current Product Slice

- Offline engine matches with 5 difficulty levels
- Daily puzzle flow with bundled local puzzle pack
- Local progression: streaks, missions, achievements, theme unlocks
- Monetization shell: rewarded hint/analysis hooks, capped interstitial rules, IAP stubs

## Phone Testing Flow

1. Open the repo's `Releases` page on your phone.
2. Download the latest `.apk` asset from the release.
3. Allow installation from the browser/files app if Android asks.
4. Tap the APK and install.

## Release Automation

- Manual release: run the `Android Release` GitHub Actions workflow and enter a version like `v1.0.1`.
- Tag release: push a tag matching `v*` and the workflow will build + publish the APK to GitHub Releases.

The workflow uploads `app-release.apk` as the release asset so phone testing stays simple.

## Local Commands

```bash
flutter analyze
flutter test
flutter build apk --release
```

## Notes

- Android is the active distribution target for this repo.
- Release builds currently use the debug signing config, which is fine for direct device testing but must be replaced before Play Store shipping.
