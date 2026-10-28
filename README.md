# Notes By Lavi

A native Android notes app built with Kotlin and Jetpack Compose. The initial version is offline-first and stores notes locally in SQLite.

## Implemented in this initial version
- Native Android app (not an HTML wrapper).
- Create, edit, and automatically save notes locally.
- Search note title, body, and tags.
- Pin/unpin notes.
- Archive notes and move notes to Trash.
- Restore trashed notes and permanently delete them.
- Comma-separated tags and word count.
- Light mode and AMOLED black canvas mode.
- GitHub Actions builds and uploads a debug APK.

## Project status
This is an initial functional foundation, not a claim that every planned feature is already implemented. Cloud sync, account login, end-to-end encryption, file attachments, reminders, drawing, import/export, and grammar checking are not implemented in this version.

## Requirements
- Android Studio and Android SDK 35
- JDK 17
- Gradle 8.9

Minimum Android version: Android 8.0 (API 26).

## Build
From the repository root:
```bash
gradle testDebugUnitTest
gradle assembleDebug
```
APK output: `app/build/outputs/apk/debug/app-debug.apk`.

Install to a connected device:
```bash
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

## Download from GitHub Actions
1. Open the repository's Actions tab.
2. Open the latest successful Android CI run.
3. Download the `Notes-By-Lavi-debug-apk` artifact.
4. Extract the ZIP and install `app-debug.apk` on your Android device.

This is a debug APK for testing, not a Play Store production-signed build.

## GitHub release
After the CI workflow passes, create and push a version tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```
The release workflow tests, builds, and attaches the APK to a GitHub Release.

## Storage and privacy
Notes are stored in the app's private SQLite database on the device. The app does not currently upload notes to a server. Uninstalling the app normally removes its private data. Since export/backup is not yet implemented, do not keep the only copy of important notes in this initial build.

## License
MIT. See [LICENSE](LICENSE).

Made with care by **Lavi**.
