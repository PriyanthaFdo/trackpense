# TrackPense

An offline personal income and expense tracker built with Flutter. It targets Android, Web and Windows.

New to the project? Read [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) first. It covers the architecture, data model, business rules and known issues.

## Setup

Requires [FVM](https://fvm.app). The Flutter version is pinned in `.fvmrc`.

```bash
fvm install
fvm flutter pub get
fvm flutter analyze
fvm flutter test             # unit, widget and database migration tests
fvm flutter run -d windows   # or: -d chrome, or an Android device
```

After changing Drift tables or `lib/core/database/database.dart`, regenerate the database code:

```bash
fvm dart run build_runner build
```

## Tests

See [docs/testing/TEST_PLAN.md](docs/testing/TEST_PLAN.md) for what is tested, how to write tests, the migration workflow for schema changes, and the integration, system and acceptance tests still to build.

### CI checks

Every pull request (and every push to `dev`) runs `.github/workflows/pr-checks.yml`:

| Check | Fix it locally with |
|---|---|
| Formatting (generated `*.g.dart` excluded) | `fvm dart format lib test tool` |
| `flutter analyze` | Fix the reported issues (`fvm dart fix --apply` handles many) |
| Generated code is up to date | `fvm dart run build_runner build --delete-conflicting-outputs` |
| Database schema snapshots match the code | `fvm dart run drift_dev make-migrations` (see the migration workflow in the test plan) |
| Web database files match the pinned versions | `fvm dart run tool/setup_web_db.dart` |
| `flutter test` | `fvm flutter test` |

All checks run even if an earlier one fails, so one run lists every problem.

## Web database files

On the web, Drift needs two extra files in `web/`: `drift_worker.js` and `sqlite3.wasm`. They are committed, so a normal build needs nothing extra. Their versions must match the `drift` and `sqlite3` versions in `pubspec.lock`. Run the setup script:

- after recreating `web/` (for example with `flutter create --platforms=web .`);
- after upgrading `drift` or `sqlite3`.

```bash
fvm dart run tool/setup_web_db.dart          # download the matching files into web/
fvm dart run tool/setup_web_db.dart --check  # verify only; exits with code 1 if out of date
```

Commit the updated files.

## Android signing

Both debug and release builds are signed with the release keystore, so local and CI builds can be installed over each other. Before building for Android:

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Fill it in and point `storeFile` at your keystore.

Both files are git-ignored. Without `key.properties`, every Android build fails.

## Releases

Pushing to `master` builds a release APK and publishes a GitHub Release (see `.github/workflows/android-build-release.yml`).

`dev` is never merged into `master` directly. Each release goes through its own merge branch:

1. On `dev` (through a normal PR), bump `version` in `pubspec.yaml` and add the `CHANGELOG.md` entry.
2. Create the merge branch from `dev`, named after the date: `git switch -c master-merge-YYYYMMDD dev` (add `-2` for a second release the same day), and push it.
3. Open a PR from `master-merge-YYYYMMDD` into `master`. The PR checks run on it; also go through the release checklist in [docs/testing/TEST_PLAN.md](docs/testing/TEST_PLAN.md) §7.
4. Only release fixes go on the merge branch. Bring each one back to `dev` with its own PR.
5. Merge with **Create a merge commit** (not squash), so `dev` and `master` keep a shared history. GitHub then deletes the merge branch.
