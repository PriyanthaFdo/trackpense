# TrackPense

An offline personal income and expense tracker built with Flutter. It targets Android, Web and Windows.

New to the project? Read [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) first. It covers the architecture, data model, business rules and known issues.

## Setup

Requires [FVM](https://fvm.app). The Flutter version is pinned in `.fvmrc`.

```bash
fvm install
fvm flutter pub get
fvm flutter analyze
fvm flutter run -d windows   # or: -d chrome, or an Android device
```

After changing Drift tables or `lib/core/database/database.dart`, regenerate the database code:

```bash
fvm dart run build_runner build
```

## Android signing

Both debug and release builds are signed with the release keystore, so local and CI builds can be installed over each other. Before building for Android:

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Fill it in and point `storeFile` at your keystore.

Both files are git-ignored. Without `key.properties`, every Android build fails.

## Releases

Pushing to `master` builds a release APK and publishes a GitHub Release (see `.github/workflows/android-build-release.yml`). Before merging to `master`, bump `version` in `pubspec.yaml` and update `CHANGELOG.md`.
