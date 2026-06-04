# Tetris Release Checklist

## Product readiness
- [ ] Classic, Sprint, Endless run without crashes on iPhone and iPad.
- [ ] Hold, next queue, hard drop, soft movement, pause/resume verified.
- [ ] Onboarding appears once on first launch.
- [ ] Settings persist (theme, music, SFX, haptics).

## Visual and UX polish
- [ ] Neon, Retro, Minimal Dark themes reviewed on real devices.
- [ ] Text contrast and Dynamic Type usability verified.
- [ ] Main interactions have haptic and visual feedback.
- [ ] Game over and sprint completion flows are clear and non-blocking.

## Online services
- [ ] Game Center authentication works.
- [ ] Leaderboards submit for all three modes.
- [ ] Achievements report progress and show completion banners.
- [ ] Offline fallback retains local stats and retries on next session.

## Performance and quality
- [ ] Smoke checks pass (`EngineSelfTests.runSmokeChecks()` in Debug).
- [ ] 15-minute endurance run without memory growth spikes.
- [ ] Background/foreground transitions keep app stable.
- [ ] Audio session behaves correctly with interruptions.

## App Store Connect prep
- [ ] App icon, screenshots (iPhone + iPad), optional app preview ready.
- [ ] Description, keywords, support URL, privacy policy URL complete.
- [ ] Version/build numbers updated for release.
- [ ] Signing and capabilities verified for Release build.
