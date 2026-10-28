<div align="center">

<img src="assets/notes-by-lavi-logo.svg" alt="Notes By Lavi logo" width="112" />

# Notes By Lavi

### Your thoughts deserve a little space.

A calm, personal place to capture ideas, make sense of your day, and keep the important things close.

<p>
  <a href="https://github.com/hmmlavi/Notes/actions"><img src="https://img.shields.io/github/actions/workflow/status/hmmlavi/Notes/flutter-cross-platform.yml?branch=main&label=build&logo=githubactions&logoColor=white" alt="Build status"></a>
  <img src="https://img.shields.io/badge/Android-early%20preview-3DDC84?logo=android&logoColor=white" alt="Android preview">
  <img src="https://img.shields.io/badge/Windows-in%20development-0078D4?logo=windows&logoColor=white" alt="Windows in development">
  <img src="https://img.shields.io/badge/license-MIT-7569D9" alt="MIT License">
</p>

[**Get the app**](https://github.com/hmmlavi/Notes/releases) · [See the roadmap](#-whats-next) · [Report a bug](https://github.com/hmmlavi/Notes/issues) · [Suggest an idea](https://github.com/hmmlavi/Notes/discussions)

</div>

---

## 🌱 Meet your new thinking space

Some notes are quick reminders. Some are ideas you don't want to lose. Some start as one sentence and turn into something bigger.

**Notes By Lavi is being built to make capturing those thoughts feel simple.** The focus is a clean interface, quick access to your notes, and local-first storage.

> **A quick note about the current stage:** this is an early preview, not the finished version. This README separates what exists today from what is still being built.

## 👀 Take a look

<!-- The Android emulator workflow adds a real screenshot here after it successfully launches the app. -->
<p align="center">
  <img src="docs/screenshots/home-android.png" alt="Notes By Lavi running in the Android emulator" width="300">
</p>
<p align="center"><sub>Real app screenshot from the Android emulator. If the image does not appear yet, the screenshot workflow has not completed successfully.</sub></p>

## ✨ What you can do today

<table>
<tr>
<td width="50%" valign="top">

### ✍️ Capture a thought
Create a note and edit its title and text.

### 🔎 Find it later
Search across note titles, body text, and tags.

### 📌 Keep it close
Pin important notes so they appear before other notes.

</td>
<td width="50%" valign="top">

### 🏷️ Add a little structure
Use comma-separated tags to group related thoughts.

### 🗂️ Clear the clutter
Archive notes you want to keep out of the main list.

### ♻️ Recover a note
Move notes to Trash and restore them when needed.

</td>
</tr>
</table>

### 🎨 Made to feel comfortable

- **Light appearance** for a bright, uncluttered workspace.
- **AMOLED dark appearance** with a true-black canvas option.
- **Soft, rounded surfaces** and gentle shadows in the evolving UI.
- **Responsive layout work** toward a better experience on phones and wider desktop screens.

*The exact experience is still being refined, and some of these design improvements are part of the newer Flutter preview rather than the original Kotlin build.*

## 🛣️ What's next?

The bigger vision is an easy-to-use notes app that works across devices. These items are goals, not promises that the features are already available.

- [ ] **A better editor** — formatting, headings, lists, and checklists.
- [ ] **Your own organisation system** — folders, nested collections, colours, and templates.
- [ ] **Reminders & planning** — tasks, due dates, and a calendar view.
- [ ] **Files with your notes** — images, documents, attachments, and drawing.
- [ ] **Take your data with you** — Markdown/TXT/JSON export and reliable backups.
- [ ] **Windows desktop app** — a shared experience across phone and PC.
- [ ] **Optional sync** — a carefully designed way to access notes on multiple devices.
- [ ] **Writing help** — optional grammar suggestions that never silently rewrite your words.
- [ ] **More accessibility and testing** — keyboard support, UI tests, and real-device checks.

## 🔐 Your notes, your data

The project is being developed with local-first use in mind. Please read these limitations before relying on the preview:

- The original Android app stores notes locally in the app's private storage.
- Account login and cloud sync are **not available yet**.
- Built-in export and backup are **not available yet**.
- End-to-end encryption has **not been implemented or claimed**.
- Uninstalling an app can remove its local data.

**Please keep another copy of anything important.** Do not use this preview as the only place where important notes are stored.

## 📲 Download or try it

<div align="center">

### Want to try the latest build?

[![Open releases](https://img.shields.io/badge/Download-check%20Releases-7569D9?style=for-the-badge&logo=github)](https://github.com/hmmlavi/Notes/releases)
[![Builds](https://img.shields.io/badge/Builds-GitHub%20Actions-24292F?style=for-the-badge&logo=githubactions)](https://github.com/hmmlavi/Notes/actions)

</div>

1. Open **Releases** and check whether a release has been published.
2. If an APK is attached, download it to your Android phone.
3. Open the downloaded file and follow Android's installation prompt. You may need to allow installation from your browser or file manager.
4. If no release is available yet, the latest build may still be running in GitHub Actions.

**Windows:** the desktop build is in development. When a successful Windows artifact is available, download the complete artifact folder and keep its supporting DLLs and files together with the executable.

## 🧑‍🔧 Build from source

### Android — original native app

The original Android implementation uses Kotlin, Jetpack Compose, Gradle, and local SQLite storage.

1. Install Android Studio and JDK 17.
2. Clone this repository.
3. Open the root Android project in Android Studio.
4. Let Gradle sync, then run the `app` configuration on an emulator or connected phone.

### Flutter — cross-platform preview

The `flutter_app/` directory contains the newer Flutter/Dart app being developed toward Android and Windows.

1. Install the Flutter SDK and the platform tools required by Flutter.
2. Open a terminal in `flutter_app/`.
3. Run:

```bash
flutter pub get
flutter analyze
flutter test
```

To build an Android APK:

```bash
flutter build apk --release
```

To build the Windows desktop version, use a Windows machine with the Visual Studio C++ desktop development tools installed:

```bash
flutter build windows --release
```

The automated workflow is intended to test and build both targets. **A successful CI run is not a substitute for checking the app on real hardware.**

## 🧱 How it's built

| Part | Technology | Why it is used |
|---|---|---|
| Original Android app | Kotlin + Jetpack Compose | Native Android UI and platform integration |
| Cross-platform preview | Flutter + Dart | Shared UI code for Android and Windows |
| Original local storage | SQLite | Structured, offline note storage |
| Cross-platform preview storage | Shared Preferences (JSON) | Lightweight prototype persistence; a proper database migration is still needed |
| Automation | GitHub Actions | Repeatable build and test jobs |

The Kotlin app has not magically become Flutter: both implementations are present while the cross-platform version is being validated. The newer preview should not be treated as a stable replacement until its builds, data handling, and user flows have been tested.

## 🗺️ Repository map

```text
.
├── app/                         # Original Kotlin Android app
├── flutter_app/                 # Flutter/Dart cross-platform preview
├── assets/                      # Brand assets and logo
├── docs/screenshots/             # App screenshots
├── .github/workflows/            # Automated build and screenshot workflows
├── CHANGELOG.md                  # Version history
├── CONTRIBUTING.md               # How to contribute
├── SECURITY.md                  # Security reporting guidance
└── LICENSE                       # MIT license
```

## 🤝 Help shape the app

Found something broken? Have an idea that would make note-taking feel better?

- **Bug report:** [Open an issue](https://github.com/hmmlavi/Notes/issues/new)
- **Feature idea or feedback:** [Start a discussion](https://github.com/hmmlavi/Notes/discussions)
- **Contribute code:** read [CONTRIBUTING.md](CONTRIBUTING.md) first.
- **Security concern:** follow [SECURITY.md](SECURITY.md).

Clear reproduction steps and honest feedback are especially helpful.

## 📄 License

Notes By Lavi is released under the [MIT License](LICENSE).

---

<div align="center">

**Built with care by [Lavi](https://github.com/hmmlavi)**

*One thought at a time.*

</div>
