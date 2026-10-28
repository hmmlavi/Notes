# Changelog

All notable user-facing changes are recorded here. Build artifacts are previews until tested on supported devices.

## 1.1.0 — Cross-platform preview in progress
- Added a Flutter/Dart application alongside the original Android app.
- Added a responsive notes list, search, pinning, archive/trash views, and light/dark appearance.
- Added automated Android APK and Windows desktop build jobs.
- Added an Android emulator screenshot workflow.
- Updated project documentation to distinguish available features from roadmap items.
- This preview still uses lightweight Shared Preferences JSON storage; cloud sync, export/backup, rich-text editing, and end-to-end encryption are not implemented.

## 1.0.0 — Initial native Android foundation
- Kotlin + Jetpack Compose Android project.
- SQLite-backed local notes.
- Create and edit notes.
- Search titles, bodies, and tags.
- Pin, archive, trash, restore, and permanently delete notes.
- Light mode and AMOLED black canvas preference.
- GitHub Actions test/build workflow.
