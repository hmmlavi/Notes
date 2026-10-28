<div align="center">

<img src="assets/notes-by-lavi-logo.svg" alt="Notes By Lavi app icon" width="112" />

# Notes By Lavi

### A little space for big ideas.

Capture thoughts, collect little plans, and keep everyday notes in one calm workspace — designed with soft clay-inspired surfaces and a simple, distraction-light layout.

<p>
  <a href="https://github.com/hmmlavi/Notes/actions/workflows/flutter-cross-platform.yml"><img src="https://img.shields.io/github/actions/workflow/status/hmmlavi/Notes/flutter-cross-platform.yml?branch=main&label=Cross-platform%20build&logo=githubactions&logoColor=white" alt="Cross-platform build status"></a>
  <img src="https://img.shields.io/badge/Android-preview-3DDC84?logo=android&logoColor=white" alt="Android preview">
  <img src="https://img.shields.io/badge/Windows-preview%20in%20progress-0078D4?logo=windows&logoColor=white" alt="Windows preview in progress">
  <img src="https://img.shields.io/badge/Flutter-Dart-02569B?logo=flutter&logoColor=white" alt="Flutter and Dart">
  <img src="https://img.shields.io/badge/license-MIT-7569D9" alt="MIT License">
</p>

[**Get the latest release**](https://github.com/hmmlavi/Notes/releases) · [Roadmap](#-the-roadmap) · [Report a bug](https://github.com/hmmlavi/Notes/issues/new) · [Share an idea](https://github.com/hmmlavi/Notes/discussions)

</div>

---

## 💭 Why Notes By Lavi?

A useful note app should get out of your way. Whether it's a sudden idea, a small to-do, or something you want to remember later, Notes By Lavi is being built around three simple principles:

- **Quick to use** — get a thought down without fighting the interface.
- **Easy to find** — search notes and keep important ones pinned.
- **Comfortable to look at** — a light theme, true-black dark canvas, and soft rounded surfaces.

> **Current status:** this is an early preview. The project has an original native Android implementation and a newer Flutter/Dart app being developed for Android and Windows. Features marked as planned are not available yet.

## 👀 A look inside

<p align="center">
  <img src="docs/screenshots/home-android.png" alt="Notes By Lavi running in the Android emulator" width="300">
</p>
<p align="center"><sub>Captured from the Android emulator by the project workflow, when the screenshot job succeeds.</sub></p>

If the image is not visible yet, the automated screenshot has not been committed successfully. No mockup is presented as a real app screenshot.

## ✨ Features in the current preview

<table>
<tr>
<td width="50%" valign="top">

### ✍️ Write
Create notes with a title, body, and comma-separated tags.

### 🔎 Search
Find text across note titles, note bodies, and tags.

### 📌 Pin
Keep important notes near the top of your list.

</td>
<td width="50%" valign="top">

### 🗂️ Archive
Move notes out of your main list without losing them.

### ♻️ Trash & restore
Recover trashed notes or permanently remove them from Trash.

### 🎨 Choose a look
Use a bright light appearance or a true-black AMOLED canvas.

</td>
</tr>
</table>

**Storage note:** the Flutter preview currently uses local app preferences to store note data. It is a lightweight prototype storage layer, not yet the robust database system planned for a mature notes app. Keep a separate copy of important information.

## 📥 Try it

<div align="center">

[![Releases](https://img.shields.io/badge/Download-Open%20Releases-7569D9?style=for-the-badge&logo=github)](https://github.com/hmmlavi/Notes/releases)
[![Actions](https://img.shields.io/badge/Builds-View%20GitHub%20Actions-24292F?style=for-the-badge&logo=githubactions)](https://github.com/hmmlavi/Notes/actions)

</div>

1. Open **Releases** and check for the latest successful preview.
2. If an APK is attached, download it on your Android phone.
3. Open the APK and follow Android's installation instructions. Android may ask you to allow installs from your browser or file manager.
4. If no release is available, open **Actions** and check whether a build is still running.

**Windows:** the Windows desktop target is being built and verified. Wait for a successful workflow and a Windows artifact before treating the PC version as ready. Keep the downloaded release folder intact; the app may need files beside its executable.

## 🧭 The roadmap

These are planned improvements, not claims about features already shipped.

- [ ] **A richer editor** — headings, bold/italic, lists, checklists, links, and undo/redo.
- [ ] **Flexible organisation** — custom folders, nested groups, colours, and templates.
- [ ] **Tasks and reminders** — due dates, recurring reminders, and calendar views.
- [ ] **Attachments** — images, documents, audio, and a drawing canvas.
- [ ] **Reliable backup and export** — Markdown, TXT, JSON, and attachments.
- [ ] **Windows desktop release** — a polished and tested PC experience.
- [ ] **Optional cross-device sync** — a transparent sync model with conflict handling.
- [ ] **Writing assistance** — optional suggestions that never silently replace your original words.
- [ ] **Privacy and accessibility improvements** — clearer data controls, keyboard support, and more device testing.

## 🔐 Privacy, storage, and limitations

We want your notes to remain yours. Here is what the current preview does — and does not — provide:

| Capability | Current status |
|---|---|
| Local note storage | Available in the preview |
| Search, pin, archive | Available in the preview |
| Account login | Not implemented |
| Cloud sync | Not implemented |
| Built-in backup/export | Not implemented |
| End-to-end encryption | Not implemented |
| Production-grade database in Flutter app | Not implemented yet |

Uninstalling the app or clearing its storage can remove local notes. **Please do not use this preview as the only copy of important information.** No encryption or cloud security guarantees are being claimed.

## 🛠️ Build from source

### Flutter app (Android and Windows)

You need the Flutter SDK. For Windows builds, you also need Windows desktop support and the Visual Studio C++ desktop development tools.

From the repository root:

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter test
```

Build an Android APK:

```bash
flutter build apk --release
```

Build the Windows desktop app on Windows:

```bash
flutter build windows --release
```

### Original native Android app

The repository also contains the original Kotlin + Jetpack Compose app under `app/`, using local SQLite storage. Open the repository in Android Studio, let Gradle sync, and run the Android `app` configuration on an emulator or connected phone.

The Kotlin and Flutter apps currently coexist. The cross-platform preview will only replace the older implementation once its functionality, storage, builds, and user flows have been checked.

## 🧱 Technology

| Area | Technology | Purpose |
|---|---|---|
| Cross-platform UI | Flutter + Dart | Shared Android and Windows interface |
| Original Android UI | Kotlin + Jetpack Compose | Native Android implementation |
| Original Android storage | SQLite | Structured local note storage |
| Flutter preview storage | Shared Preferences + JSON | Lightweight prototype persistence |
| Build and screenshot automation | GitHub Actions | Repeatable builds and emulator screenshot capture |

## 🗺️ Project structure

```text
.
├── app/                                  # Original Kotlin Android app
├── flutter_app/
│   ├── lib/main.dart                     # Flutter app entry and UI
│   ├── test/                             # Flutter tests
│   └── pubspec.yaml                      # Flutter dependencies and version
├── assets/notes-by-lavi-logo.svg         # Project logo
├── docs/screenshots/                     # Real app screenshots, when captured
├── .github/workflows/                    # CI, build, and screenshot workflows
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

## 🤝 Contribute or send feedback

You don't need to contribute code to help. Tell us what feels confusing, what broke, or what would make note-taking more comfortable.

- **Bug:** [Open an issue](https://github.com/hmmlavi/Notes/issues/new)
- **Feature suggestion:** [Start a discussion](https://github.com/hmmlavi/Notes/discussions)
- **Code contributions:** read [CONTRIBUTING.md](CONTRIBUTING.md)
- **Security reports:** read [SECURITY.md](SECURITY.md)

Please include clear steps to reproduce a bug and mention which build or device you used.

## 📄 License

This project is available under the [MIT License](LICENSE).

---

<div align="center">

**Made with care by [Lavi](https://github.com/hmmlavi)**

*One thought at a time.*

</div>
