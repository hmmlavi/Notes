<div align="center">

<img src="assets/notes-by-lavi-logo.svg" alt="Notes By Lavi app icon" width="104" />

# Notes By Lavi

### A little space for big ideas.

A clean, local-first notes app for capturing thoughts, keeping useful notes close, and finding them again without clutter.

<p>
  <a href="https://github.com/hmmlavi/Notes/actions/workflows/flutter-cross-platform.yml"><img src="https://img.shields.io/github/actions/workflow/status/hmmlavi/Notes/flutter-cross-platform.yml?branch=main&label=Build%20and%20test&logo=githubactions&logoColor=white" alt="Build and test status"></a>
  <img src="https://img.shields.io/badge/Flutter-Dart-02569B?logo=flutter&logoColor=white" alt="Flutter and Dart">
  <img src="https://img.shields.io/badge/Android-APK-3DDC84?logo=android&logoColor=white" alt="Android APK">
  <img src="https://img.shields.io/badge/license-MIT-7569D9" alt="MIT License">
</p>

[Download APK](https://github.com/hmmlavi/Notes/releases) · [Builds and test results](https://github.com/hmmlavi/Notes/actions) · [Report a bug](https://github.com/hmmlavi/Notes/issues/new)

</div>

---

## Overview

Notes By Lavi is a personal note-taking app built with Flutter and Dart. It is designed around a quiet interface, quick capture, and straightforward organisation. The same Flutter codebase targets Android and Windows.

> **Status:** Early preview. The Android APK is built by GitHub Actions. Check the latest workflow run or release before installing; a successful source change does not mean a build has passed until the workflow confirms it.

## Features

- **Create and edit notes** with a title, body, and comma-separated tags.
- **Search** note titles, body text, and tags.
- **Pin notes** to keep important items near the top.
- **Archive notes** without deleting them.
- **Trash and restore** notes, with a separate permanent-delete action.
- **Light and AMOLED dark themes**, with dark card surfaces and readable text.
- **Responsive layout** with compact navigation on phones and a navigation rail on wider screens.
- **Local storage** so notes remain available on the same device between launches.

## Screenshots

The screenshot in `docs/screenshots/home-android.png` is intended to be captured from an Android emulator by CI. If it is missing or out of date, use the workflow artifact rather than assuming a mockup represents the current build.

## Install on Android

1. Open [GitHub Releases](https://github.com/hmmlavi/Notes/releases).
2. Download the APK attached to the latest successful preview release.
3. Open the downloaded APK on your Android device. If prompted, allow your browser or file manager to install apps from that source.
4. Follow Android's installation prompt, then open **Notes By Lavi**.

If no APK is attached to a release, open [GitHub Actions](https://github.com/hmmlavi/Notes/actions), select the latest successful **Flutter Android and Windows builds** run, and download the **Notes-By-Lavi-Android-APK** artifact. Artifacts expire after their configured retention period.

### Important storage limitation

Notes are stored locally using the app's preferences store. This is a lightweight preview implementation, not a database-backed sync service. There is currently no account, cloud sync, built-in export/backup, or end-to-end encryption. Clearing app storage or uninstalling the app can permanently remove notes. Keep a separate copy of anything important.

## Build from source

### Requirements

- Flutter SDK on the stable channel
- Android SDK and an Android toolchain for APK builds
- Windows desktop support and Visual Studio's **Desktop development with C++** workload for Windows builds

### Run locally

From the repository root:

```bash
cd flutter_app
flutter doctor
flutter pub get
flutter analyze
flutter test
flutter run
```

### Build an Android APK

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

The APK is written to:

```text
flutter_app/build/app/outputs/flutter-apk/app-release.apk
```

The automated preview uses the default debug signing configuration. Treat it as a testing build, not a Play Store release.

### Build for Windows

Run these commands on Windows with the desktop toolchain installed:

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

The Windows app bundle is written under `flutter_app/build/windows/x64/runner/Release/`. Keep the full Release directory together when moving or distributing the app; the executable may depend on files alongside it.

## Automated checks

The GitHub Actions workflow builds and checks the Flutter project on changes to the Flutter app or workflow:

1. Installs the stable Flutter SDK.
2. Generates the Android and Windows runner projects.
3. Resolves dependencies.
4. Runs `flutter analyze` and `flutter test`.
5. Builds the release APK and Windows desktop bundle.
6. Uploads build artifacts.
7. On pushes to `main`, publishes or updates the preview APK release.

A separate Android-emulator job builds and launches the app to capture a real emulator screenshot. Check the [workflow run](https://github.com/hmmlavi/Notes/actions/workflows/flutter-cross-platform.yml) for the actual result; this README does not imply a build has passed when it has not.

## Project layout

```text
.
├── app/                                      # Original native Kotlin/Compose app
├── flutter_app/
│   ├── lib/main.dart                         # Flutter application
│   ├── test/                                 # Dart and widget tests
│   ├── android/                              # Android runner (generated/configured)
│   ├── windows/                              # Windows runner (generated/configured)
│   └── pubspec.yaml                           # Dependencies and version
├── assets/notes-by-lavi-logo.svg
├── docs/screenshots/
├── .github/workflows/flutter-cross-platform.yml
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

The repository currently contains both the original native Android implementation and the newer Flutter implementation. The Flutter app is the cross-platform preview and the source used by the automated Android APK build.

## Roadmap

Planned ideas—not yet available features—include:

- [ ] A richer editor with formatting, checklists, links, and undo/redo
- [ ] Folders, custom colours, and note templates
- [ ] Reliable export and backup, including Markdown and JSON
- [ ] Attachments and drawing support
- [ ] Optional cross-device sync with clear conflict handling
- [ ] Reminders and calendar views
- [ ] Accessibility improvements and broader device testing

## Privacy

The preview does not require an account and does not implement cloud sync. Notes are stored on the device through local app storage. There are no claims of encryption or server-side backup. Please review the storage limitations above before keeping sensitive or irreplaceable information in the app.

## Contributing and support

Bug reports and feature suggestions are welcome.

- [Open an issue](https://github.com/hmmlavi/Notes/issues/new)
- [Read contribution guidance](CONTRIBUTING.md)
- [Read the security policy](SECURITY.md)

For a useful bug report, include your device or operating system, the installed app version, steps to reproduce the issue, and any relevant error message. Do not attach private note contents.

## License

Released under the [MIT License](LICENSE).

---

<div align="center">

**Made with care by [Lavi](https://github.com/hmmlavi)**

*One thought at a time.*

</div>
