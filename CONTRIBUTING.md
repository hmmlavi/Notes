# Contributing

Thanks for helping make Notes By Lavi easier to use.

## Before you start
1. Open an issue for a bug or a discussion for a larger feature.
2. Keep pull requests focused and explain the user problem being solved.
3. Never commit API keys, signing keys, passwords, private notes, or personal data.

## Flutter preview
From `flutter_app/`, run:

```bash
flutter pub get
flutter analyze
flutter test
```

For a release APK, run `flutter build apk --release`. For a Windows desktop build on Windows with Visual Studio C++ desktop tools installed, run `flutter build windows --release`.

## Original Android app
The `app/` folder is the original Kotlin + Jetpack Compose project. Open it in Android Studio and run the available Gradle unit tests and debug build.

## What to test
When relevant, verify note creation/editing, saving after restart, search, tags, pinning, archive, trash/restore, permanent deletion, theme switching, small phone layouts, and wider desktop layouts.

## Be clear about limitations
If you could not test a platform or device, say so in the pull request. Do not describe preview storage as encrypted or production-ready. Avoid claiming roadmap features are implemented until they are merged and tested.
