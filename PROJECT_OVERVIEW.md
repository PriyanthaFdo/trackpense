# TrackPense — Project Overview

> **Audience:** developers and AI agents picking up this codebase for the first time.
> **Purpose:** explain what the app is, how it is built, what state the code is *actually* in, and where the traps are, so you can be productive without re-reading every file.
>
> Last updated 2026-10-27 (version `1.1.1`, branch `refactor/clean-architecture`). If the code and this document disagree, trust the code and update this file.

---

## 1. What the app is

TrackPense is a small, **offline-only personal income and expense tracker** built with Flutter. A single user records transactions on their own device. There is no backend, no accounts, and no sync. It is maintained as a product with team-style practices (feature branches, PRs, reviews), even though it currently has one developer.

Current user-facing features:

| Feature | Details |
|---|---|
| Transaction list (home) | Newest first. Each transaction is a coloured card: red tint for expenses, green for income. A card shows the day, date, month, time, description, the first line of the notes, and the amount. |
| Create a transaction | Description (required, max 200 chars), amount (required, > 0, thousands separators, 2 dp), an Income/Expense switch, date and time, and optional multi-line notes. |
| Edit a transaction | Tap a card. The same form opens, pre-filled. |
| Date edit window | The date picker only allows dates within the last 7 days. For a transaction older than that, the date and time are shown read-only. |

Not implemented: deleting from the UI (the use case exists but no UI calls it), categories, accounts, budgets, reports, search, attachments, export, settings, theming, or dark mode.

**Target platforms:** Android (the main target, released through CI), Web, and Windows. There is no iOS, macOS, or Linux.

**Design direction:** [design_images/mobile.png](design_images/mobile.png) and [design_images/desktop.png](design_images/desktop.png) are mock-ups of a redesigned "Create Transaction" form. It has Income/Expense toggle buttons, separate date and time fields, notes, an **attachments** upload, a purple accent colour, and a two-column dialog layout on desktop. **This redesign is not implemented yet.** The current UI is plain Material defaults.

---

## 2. Project history

1. **Original app (up to commit `1d28933`).** A simple, working app with a flat structure (`lib/data/`, `lib/src/`) and a `Kjp` naming prefix.
2. **AI refactor (`ff53846`).** An AI agent ("Cascade AI", i.e. Windsurf) started a move to a **feature-based Clean Architecture**: a `core/` layer, a transactions feature with domain/data/presentation layers, and get_it dependency injection. Its planning documents are archived in [docs/archive/](docs/archive/). They describe an aspirational end state, **not** the current code.
3. **Stabilization (the commits after `ff53846`).** This pass fixed four behaviour regressions from the AI refactor:
   - form validation was skipped;
   - the list had lost its newest-first ordering;
   - notes could not be cleared when editing;
   - the home screen ran UI side effects inside `build`.

   It also finished moving the UI into the feature folders and deleted unused scaffolding.

To inspect the pre-refactor code, run `git show 1d28933:<path>`, for example `git show 1d28933:lib/data/blocs/payment_bloc.dart`.

**Verification status:** `flutter analyze` is clean. There are **no automated tests yet**. Manual testing on a device, including upgrading over an existing 1.1.1 install, is still pending.

---

## 3. Tech stack

| Concern | Choice | Notes |
|---|---|---|
| Flutter / Dart | Flutter **3.44.5** (pinned in `.fvmrc` and in `pubspec.yaml` `environment.flutter`) | Uses [FVM](https://fvm.app). Prefer `fvm flutter ...`. |
| State management | `flutter_bloc` | Two BLoCs: `TransactionBloc` (feature) and `UiBloc` (app-wide loading and error UI). |
| Persistence | `drift` + `drift_flutter` (SQLite) | Code generation through `drift_dev` + `build_runner`. Native platforms (Android, Windows) use the native SQLite bundled by `sqlite3_flutter_libs`. Web uses `web/sqlite3.wasm` + `web/drift_worker.js`, which must match the locked `sqlite3`/`drift` versions (see `tool/setup_web_db.dart`). |
| Routing | `go_router` | One `ShellRoute` with two child routes. |
| Dependency injection | `get_it` | Registrations live in `lib/core/di/service_locator.dart`. |
| Misc | `intl`, `uuid`, `loading_indicator`, `path_provider` | |
| Lints | `flutter_lints` + strict extra rules in [analysis_options.yaml](analysis_options.yaml) | Notable rules: `always_use_package_imports`, `directives_ordering`, `require_trailing_commas`, `prefer_single_quotes`, `avoid_print`, `unawaited_futures`. Formatter page width is 200. |

---

## 4. Getting started

See [README.md](README.md) for setup commands, Android signing and the release process. Key points:

- `fvm flutter pub get`, then `fvm flutter run -d windows` (or `chrome`, or an Android device).
- After changing Drift tables, run `fvm dart run build_runner build`. Never edit `database.g.dart` by hand.
- After recreating `web/` or upgrading `drift`/`sqlite3`, run `fvm dart run tool/setup_web_db.dart` to download the matching web database files. Commit the result.
- **Android builds, debug included, need `android/key.properties`.** Both build types are signed with the release keystore (see [android/app/build.gradle.kts](android/app/build.gradle.kts)). Without that file, Gradle fails.
- **A debug build on your own phone replaces the installed release app.** Both use the same app ID and key, so the debug build runs database migrations on your real data. Until dev/prod flavors exist, test risky changes on Windows, web, or an emulator.
- **Merging to `master` publishes a release.** CI ([.github/workflows/android-build-release.yml](.github/workflows/android-build-release.yml)) builds a signed APK and creates a GitHub Release tagged `v<version>_<run_number>`. Day-to-day work goes to `dev` through feature branches.

---

## 5. Directory map

```
lib/
├── main.dart                          runApp(App())
├── app/
│   └── app.dart                       App: awaits DI init, provides BLoCs, MaterialApp.router
├── core/                              shared, feature-agnostic code
│   ├── config/app_config.dart         constants: DB name, Uuid instance, max description length, decimal digits, edit window (7 days)
│   ├── database/                      Drift AppDatabase, Payment table, generated code
│   ├── di/service_locator.dart        get_it registrations
│   ├── error/failures.dart            Failure hierarchy returned by repositories
│   ├── extensions/                    Color darken/lighten, DateTime.format, double.toCommaString, String.toCleanDouble/toSentenceCase
│   ├── logging/app_logger.dart        thin wrapper over dart:developer log
│   ├── navigation/                    GoRouter (app_router.dart) + RouteNames
│   ├── presentation/blocs/ui_bloc.dart   app-wide loading/error state, rendered by the ShellRoute
│   ├── theme/app_colors.dart          colour palette (primary #0C4776, expense red, income green)
│   ├── utils/formatters/              DecimalTextInputFormatter, CommaSeparatedInputFormatter
│   ├── utils/validators/              DescriptionValidator, AmountValidator (used by the form)
│   └── widgets/common/                AppTextFormField, LoadingOverlay, EmptyStateWidget
└── features/
    └── transactions/
        ├── domain/                    pure Dart, no Flutter or Drift imports
        │   ├── entities/transaction.dart
        │   ├── repositories/transaction_repository.dart   abstract repo + a home-made Either<L, R>
        │   └── usecases/              Create/Update/Delete/WatchTransaction(s): thin pass-throughs
        ├── data/
        │   ├── models/transaction_model.dart   maps PaymentData/PaymentCompanion <-> Transaction
        │   └── repositories/transaction_repository_impl.dart   wraps AppDatabase, returns Either<Failure, T>
        └── presentation/
            ├── blocs/transaction_bloc.dart
            ├── pages/transaction_list_page.dart   home screen
            ├── pages/transaction_form_page.dart   create/edit form (the most complex UI file)
            └── widgets/transaction_card.dart
```

Other top-level items:
- [docs/archive/](docs/archive/): the AI's original audit, target architecture and migration plan (historical).
- `web/`: web entry point, including `sqlite3.wasm` and `drift_worker.js` for Drift on the web. These are managed by `tool/setup_web_db.dart`, so don't edit or replace them by hand.
- `tool/`: developer scripts. `setup_web_db.dart` downloads the Drift web files that match `pubspec.lock` (`--check` verifies them).
- `windows/`, `android/`: platform runners.
- `test/`: empty so far.
- `design_images/`: UI mock-ups.

**Rule of thumb:** code is added when a feature uses it. Don't create placeholder features or speculative services. Add them when there is an issue to implement.

---

## 6. Runtime architecture

### 6.1 Startup

```
main() → App (StatefulWidget)
  initState → initServiceLocator()          // registers everything in get_it
  while initializing: MaterialApp with a CircularProgressIndicator
  then: MultiBlocProvider[ UiBloc, TransactionBloc ] → MaterialApp.router(routerConfig: router)
```

If DI initialization throws, the error is logged and rethrown, and the app **stays on the spinner forever**. There is no error screen yet.

### 6.2 Dependency graph (get_it)

```
AppDatabase                                     lazy singleton
TransactionRepository → TransactionRepositoryImpl(AppDatabase)   factory
Create/Update/Delete/WatchTransaction(s) → (TransactionRepository)   factories
TransactionBloc(create, update, delete, watch)  factory (created once, by the BlocProvider in App)
UiBloc                                          factory (created once, by the BlocProvider in App)
```

Both BLoCs are **app-global**. They are provided above the router, so every screen shares the same `TransactionBloc` instance.

### 6.3 Layers in the transactions feature

```
UI (TransactionListPage / TransactionFormPage)
   │  add(Event)                      ▲ TransactionState
   ▼                                  │
TransactionBloc ──calls──► UseCase.call() ──► TransactionRepository (abstract)
                                                   ▲ implements
                                    TransactionRepositoryImpl ──► AppDatabase (Drift)
                                         │ maps with TransactionModel
                                         ▼
                              Either<Failure, T> / Stream<List<Transaction>>
```

`Either` is a minimal home-made class defined in `transaction_repository.dart`. It is not from `dartz` or `fpdart`. Use `fold(ifLeft, ifRight)`.

### 6.4 State flow

**TransactionBloc**

| Event | Behaviour | Emits |
|---|---|---|
| `TransactionLoadEvent` (dispatched by `TransactionListPage.initState`) | Subscribes to `watchAllTransactions()` through `emit.forEach` and stays subscribed. | `Loading`, then `Loaded(list)` on every DB change, or `Error(msg)` |
| `TransactionCreateEvent` / `TransactionUpdateEvent` / `TransactionDeleteEvent` | Calls the use case. | `Ready` on success, `Error(failure.message)` on failure |

Bloc's default event transformer is concurrent, so the Load subscription keeps running while writes are handled. After a successful write, the state goes `Ready` → (the DB stream fires) → `Loaded`.

**How the UI reacts**

- `TransactionListPage` uses a `BlocConsumer`:
  - The **listener** maps `Loading` → `UiLoadingEvent`, `Error` → `UiErrorEvent`, and anything else → `UiReadyEvent`.
  - The **builder** only rebuilds on `Loading`/`Loaded` (`buildWhen`), so the last list stays visible during and after a save.
- `TransactionFormPage` validates the form, dispatches Create or Update, and pops itself when it sees `TransactionReadyState`. On failure it stays open, and the error dialog appears on top.
- The `ShellRoute` in [app_router.dart](lib/core/navigation/app_router.dart) listens to `UiBloc`. `Loading` shows `LoadingOverlay`, other states dismiss it, and `Error` shows an `AlertDialog`.
- `LoadingOverlay` is a singleton. It stays visible for at least 1 s once shown, and it throws if it is still showing after 5 minutes.

### 6.5 Navigation

| Route name / path | Screen | `extra` |
|---|---|---|
| `RouteNames.home` = `/` | `TransactionListPage` | none |
| `RouteNames.transactionForm` = `/transaction-form` | `TransactionFormPage(transaction: Transaction?)` | a `Transaction` for edit, `null` for create |

Route names are the same strings as their paths. Use `context.pushNamed(...)` from go_router. Because the entity is passed through `extra`, deep links to the edit form cannot work.

---

## 7. Data model and persistence

The Drift database is [lib/core/database/database.dart](lib/core/database/database.dart) with file name `trackpense.db`. Native platforms store it in `getApplicationSupportDirectory()`.

**Table `payment`** ([payment_table.dart](lib/core/database/tables/payment_table.dart)). The generated row class is `PaymentData` and the companion is `PaymentCompanion`:

| Column | Type | Constraints |
|---|---|---|
| `uuid` | TEXT | **primary key**; client default `Uuid().v4()` (the form also generates one) |
| `date` | DATETIME | required (Drift's default storage: Unix seconds) |
| `description` | TEXT | required, length 1–200 |
| `amount` | REAL | required, always positive; the sign comes from `is_expense` |
| `is_expense` | BOOL | required |
| `notes` | TEXT | nullable (added in schema v2) |

- **Schema version: 2.** The v1 → v2 migration adds `notes`. If you change a table, bump `schemaVersion`, add a branch to `onUpgrade`, and re-run `build_runner`. **Real user data exists on installed devices, so a broken migration is the worst bug this app can have.** Migration tests are planned (Drift schema dumps plus generated migration tests).
- **Naming:** the domain says **Transaction**; the database layer still says **Payment** (`Payment` table, `PaymentData`, `createPayment`…). `TransactionModel` translates between them. Renaming the SQL table would need a migration, so the names were left as they are on purpose.
- `AppDatabase` exposes `createPayment`, `updatePayment` (WHERE uuid, write), `deletePayment`, `getPayment`, and `watchAllPayments` (ordered by `date DESC`).
- `amount` is a `double`. There is no currency or value object. The display format is `#,##0.00`.

---

## 8. Business rules

| Rule | Location |
|---|---|
| Description required, not blank, max 200 chars | `DescriptionValidator` in the form; `AppTextFormField` counter and `maxLength`; DB length constraint |
| Amount required, > 0, max 2 decimals | `AmountValidator` in the form. While typing, `DecimalTextInputFormatter(decimalDigits: 2)` and `CommaSeparatedInputFormatter` shape the input. It is parsed with `String.toCleanDouble()`. |
| Dates can be picked only within the last `AppConfig.transactionEditWindowDays` (7) days | `showDatePicker(firstDate: …)` in `transaction_form_page.dart` |
| Transactions older than the window: date and time are read-only | `_dateTimeSelectors` in `transaction_form_page.dart` |
| Income vs expense | `isExpense` bool; defaults to expense |

These rules live in the presentation layer. Moving them into the domain (use cases or entity validation) is a reasonable future step once they have tests.

---

## 9. Known issues and technical debt

1. **Generic error messages.** The repository wraps every exception in `DatabaseFailure('Failed to … transaction')`. `UiBloc` has special formatting for Drift `InvalidDataException`, but that path can no longer trigger. Form validation now catches the common cases first.
2. **Shared global `TransactionBloc`.** The form pops on any `TransactionReadyState`, and the list reacts to every state. Adding more screens or features to this BLoC will cause cross-talk. Consider a separate form cubit, or scoping the BLoC per route.
3. **Delete is unreachable.** `DeleteTransaction` and `TransactionDeleteEvent` exist, but there is no UI for them.
4. **No theme.** `MaterialApp.router` gets no `theme`. Only `AppColors` exists. The redesign will introduce a proper theme.
5. **No startup error screen.** If DI init fails, the app stays on the spinner.
6. **No length limit on notes.**
7. **No dev/prod separation.** Debug and release share an app ID and signing key (see §4).
8. **No tests**, and no CI checks on pull requests. CI only builds releases on `master`.

---

## 10. Conventions

- **Imports:** always `package:trackpense/...`, sorted (both lint enforced; `dart fix --apply` sorts them).
- **Naming:** files use `snake_case`. Shared widgets and constants use the `App*` prefix (`AppColors`, `AppConfig`, `AppTextFormField`). Feature classes are named after the domain (`TransactionListPage`, `TransactionCard`). One leftover old name: the extension `KbDateTimeFormatting`.
- **Feature layout:** `features/<name>/{domain/{entities,repositories,usecases}, data/{models,repositories}, presentation/{blocs,pages,widgets}}`. Domain must not import Flutter or Drift. Code shared across features goes in `core/`.
- **Errors:** repositories catch exceptions and return `Either.left(SomeFailure(...))`. BLoCs `fold` the result into states.
- **Constants** go in `AppConfig`. **Colours** go in `AppColors`.
- **Commits:** [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `refactor:`, `chore:`, `docs:`), one logical change per commit.
- **Branches:** `master` holds releases, `dev` is for integration, and short-lived `feat/…`, `fix/…`, `refactor/…` branches merge into `dev` through PRs.
- **Releases:** bump the `version` in `pubspec.yaml`, add a `CHANGELOG.md` entry, then merge `dev` → `master`.

---

## 11. Roadmap

1. **Stabilize (this branch).** Fix regressions, finish the folder migration, prune unused code. Remaining: a manual device test, including an upgrade over an existing 1.1.1 install.
2. **Safety net.**
   - Unit tests for the repository (in-memory Drift: `AppDatabase(NativeDatabase.memory())`), mappers, use cases, validators and formatters.
   - `bloc_test` for the BLoCs, plus widget tests for the form.
   - Drift migration tests.
   - Dev/prod build flavors with separate app IDs.
3. **Team workflow.**
   - PR checks in CI: format, analyze, test, build.
   - Branch protection on `dev` and `master`.
   - Releases triggered by tags.
   - PR and issue templates, `CONTRIBUTING.md`, architecture decision records in `docs/adr/`.
   - Dependabot, pre-commit hooks, VS Code launch configs, and a GitHub Projects board.
4. **Product work.**
   - The redesigned form with a real theme.
   - Delete in the UI.
   - Attachments (schema v3).
   - Later: localization, crash reporting, backup and export.
