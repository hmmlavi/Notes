# Security and data handling

Thank you for helping keep Notes By Lavi and its users safe.

## Reporting a vulnerability
Please do not publish exploit details or sensitive user data in a public issue. Contact the repository owner through the contact options on the GitHub profile and include the affected version, impact, and safe reproduction steps.

## Current preview limitations
- The original native Android app uses a local SQLite database in app-private storage.
- The Flutter preview currently stores notes as JSON in Shared Preferences.
- Login, cloud sync, encrypted backups, and end-to-end encryption are not implemented.
- Local app storage is not a substitute for a dedicated encrypted vault.
- Clearing app storage or uninstalling can delete locally stored notes.

Please avoid storing highly sensitive information in preview builds and keep independent copies of important notes. Security features will only be described as available after implementation and testing.
