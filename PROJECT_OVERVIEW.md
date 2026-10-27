# TrackPense — Project Overview

> **Audience:** developers and AI agents picking up this codebase for the first time.
> **Purpose:** explain what the app is, how it is built, what state the code is *actually* in, and where the traps are, so you can be productive without re-reading every file.
>
> Written 2026-10-27 against branch `dev` (version `1.1.1`), with the AI-driven refactor **staged but not yet committed**. If you're reading this later, check `git log` to see whether that refactor has since been committed, changed, or reverted.

---

## 1. What the app is

TrackPense is a small, **offline-only personal income and expense tracker** built with Flutter. A single user records transactions on their own device. There is no backend, no accounts, and no sync.

Current user-facing features:

| Feature | Details |
|---|---|
| Transaction list (home) | Shows every transaction as a coloured card: red tint for expenses, green for income. Each card shows the day, date, month, time, description, the first line of the notes, and the amount. |
| Create a transaction | Description (required, max 200 chars), amount (decimal input with thousands separators, 2 dp), an Income/Expense switch, date and time, and optional multi-line notes. |
| Edit a transaction | Tap a card. The same form opens, pre-filled. |
| 7-day date rule | The date picker only allows dates within the last 7 days. For a transaction older than 7 days, the date and time are shown read-only. |

Not implemented: deleting from the UI (the use case exists but no UI calls it), categories, accounts, budgets, reports, search, attachments, export, settings, theming, or dark mode.

**Target platforms:** Android (the main target, released through CI), Web, and Windows. Those are the only platform folders. There is no iOS, macOS, or Linux.

**Design direction:** [design_images/mobile.png](design_images/mobile.png) and [design_images/desktop.png](design_images/desktop.png) are mock-ups of a redesigned "Create Transaction" form. It has Income/Expense toggle buttons, separate date and time fields, notes, an **attachments** upload, a purple accent colour, and a two-column dialog layout on desktop. **None of this redesign is implemented yet.** The current UI is plain Material defaults.

---

## 2. Project history (important context)

1. **Original app (commits up to `1d28933`, the `HEAD` of `dev`).** A simple, working app with a "flat" structure: `lib/data/` (blocs, constants, database, models, repositories) and `lib/src/` (app, router, views, widgets). The project's own naming prefix was `Kjp` (for example `KjpColors` and `KjpTextFormField`).
2. **AI refactor (staged in the git index, uncommitted, untested on a device).** An AI agent ("Cascade AI", i.e. Windsurf) audited the app and started moving it to a **feature-based Clean Architecture**. It wrote three planning documents:
   - [ARCHITECTURE_AUDIT.md](ARCHITECTURE_AUDIT.md): critique of the original code.
   - [TARGET_ARCHITECTURE.md](TARGET_ARCHITECTURE.md): the planned end state. It is very ambitious: 12+ features, `app/`, `shared/`, localization, network layer, and more.
   - [MIGRATION_STRATEGY.md](MIGRATION_STRATEGY.md): an 8-phase plan. Its tracking tables still say "Pending" for everything, so they are **not** a reliable status record.

   **The refactor is only partly done.** Roughly: the core layer was created, the transactions feature got domain and data layers plus a new BLoC, and the old `PaymentBloc`, `PaymentRepo`, `PaymentModel` and `Kjp*` constants were deleted. The UI files (`lib/src/views`, `lib/src/widgets`) and `UiBloc` (`lib/data/blocs`) were **not** moved. Nothing from Phases 5–7 exists: no dashboard, no placeholder features, no `app/` or `shared/` folders, no tests, no theme wiring.

To see exactly what the refactor changed:

```bash
git diff --cached --stat -M          # file-level summary
git diff --cached -M -- lib/         # full code diff
git show HEAD:lib/data/blocs/payment_bloc.dart   # view any pre-refactor file
```

**Verification status:** `flutter analyze --no-pub` (Flutter 3.44.5) reports **no issues**. The app has **not** been run on a device or emulator since the refactor, and there are **no automated tests**. The `test/core` and `test/features` folders are empty.

---

## 3. Tech stack

| Concern | Choice | Notes |
|---|---|---|
| Flutter / Dart | Flutter **3.44.5** (pinned in `.fvmrc` and in `pubspec.yaml` `environment.flutter`), Dart `^3.9.0` | Uses [FVM](https://fvm.app). Prefer `fvm flutter ...`. |
| State management | `flutter_bloc` ^9.1.1 | Two BLoCs: `TransactionBloc` and `UiBloc`. |
| Persistence | `drift` ^2.28.1 + `drift_flutter` (SQLite) | Code generation through `drift_dev` + `build_runner`. On web it uses `sqlite3.wasm` + `drift_worker.js` from `web/`. |
| Routing | `go_router` ^16.1.0 | One `ShellRoute` with two child routes. |
| Dependency injection | `get_it` ^7.6.4 | Added by the refactor. |
| Misc | `intl` (formatting), `uuid` (primary keys), `loading_indicator` (overlay spinner), `path_provider` (DB location), `shared_preferences` (added by the refactor, unused at runtime) | |
| Lints | `flutter_lints` + strict extra rules in [analysis_options.yaml](analysis_options.yaml) | Notable rules: `always_use_package_imports`, `require_trailing_commas`, `prefer_single_quotes`, `avoid_print`, `unawaited_futures`. Formatter page width is 200. |

---

## 4. Getting started

```bash
fvm install                      # installs Flutter 3.44.5 per .fvmrc
fvm flutter pub get
fvm dart run build_runner build  # regenerate Drift code after changing tables or database.dart
fvm flutter analyze
fvm flutter run -d windows       # or: -d chrome, or an Android device
```

### Android signing (read this before your first Android build)

[android/app/build.gradle.kts](android/app/build.gradle.kts) signs **both debug and release** builds with the `release` signing config. That config reads `android/key.properties`.

- If `android/key.properties` is missing, **every Android build fails**, including debug. The script casts missing properties with `as String`, so Gradle throws.
- Copy [android/key.properties.example](android/key.properties.example) to `android/key.properties` and point `storeFile` at a keystore. Both files are git-ignored by `android/.gitignore`.
- This setup is intentional (see CHANGELOG 1.1.1): local and CI builds share one keystore, so builds can be installed over each other.
- The root [README.md](README.md) still says "debug keystore password: `android`". That is **stale**. The old `build_keys/shared-debug.keystore` has been deleted (staged).

### CI / release

[.github/workflows/android-build-release.yml](.github/workflows/android-build-release.yml) runs on **every push to `master`**. It:

1. Reads the Flutter version from `pubspec.yaml`. The comment in the file says `.fvmrc`, but the workflow actually uses `pubspec.yaml`.
2. Rebuilds the keystore and `key.properties` from repository secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`.
3. Builds a release APK.
4. Publishes a GitHub Release tagged `v<version>_<run_number>`.

Day-to-day work happens on `dev`. **Merging to `master` publishes a release.** Bump `version:` in `pubspec.yaml` and update `CHANGELOG.md` before you merge.

---

## 5. Directory map: what is live and what is scaffolding

"Live" means the file is reachable from `main.dart` at runtime. Much of the refactor's output is scaffolding that nothing imports yet.

```
lib/
├── main.dart                          LIVE   runApp(App())
├── src/                               LIVE   ⚠ legacy location, not yet migrated
│   ├── app.dart                              App: awaits DI init, provides BLoCs, MaterialApp.router
│   ├── views/home_view.dart                  transaction list screen
│   ├── views/payment_form_view.dart          create/edit form (the most complex UI file)
│   └── widgets/item_card.dart                one transaction card
├── data/blocs/ui_bloc.dart            LIVE   ⚠ legacy location; global loading/error UI state
├── features/transactions/             LIVE   new Clean Architecture slice
│   ├── domain/entities/transaction.dart      Transaction entity (immutable, copyWith, ==)
│   ├── domain/repositories/transaction_repository.dart   abstract repo + a home-made Either<L,R>
│   ├── domain/usecases/{create,update,delete,watch}_transaction(s).dart   thin pass-throughs
│   ├── data/models/transaction_model.dart    maps PaymentData/PaymentCompanion <-> Transaction
│   ├── data/repositories/transaction_repository_impl.dart   wraps AppDatabase, returns Either<Failure, T>
│   └── presentation/blocs/transaction_bloc.dart   events/states/BLoC
└── core/
    ├── config/app_config.dart         LIVE   constants (DB name, Uuid instance, limits, breakpoints, pref keys)
    ├── database/                      LIVE   Drift AppDatabase + Payment table + generated code
    ├── di/service_locator.dart        LIVE   get_it registrations
    ├── navigation/                    LIVE   GoRouter + RouteNames
    ├── logging/app_logger.dart        LIVE   wraps dart:developer log, used during startup only
    ├── error/failures.dart            LIVE   Failure hierarchy (only DatabaseFailure is produced)
    ├── error/exceptions.dart, error_handler.dart   scaffolding, not used by the feature
    ├── extensions/{color,datetime,double,string}_extensions.dart   LIVE
    ├── extensions/context_extensions.dart   UNUSED  (⚠ has bugs, see §9)
    ├── theme/app_colors.dart          LIVE   palette (primary #0C4776, expense red, income green)
    ├── theme/{app_spacing,app_typography,app_border_radius}.dart   UNUSED (no ThemeData is built)
    ├── storage/preferences_service.dart, secure_storage_service.dart   registered in DI, never used
    ├── storage/storage_service.dart   UNUSED
    ├── utils/formatters/              LIVE   DecimalTextInputFormatter, CommaSeparatedInputFormatter
    ├── utils/helpers/{currency,date}_helper.dart   UNUSED
    ├── utils/validators/{amount,date,description}_validator.dart   UNUSED (the form uses inline validators)
    └── widgets/
        ├── common/inputs/app_text_field.dart       LIVE   AppTextFormField (char counter, outline option)
        ├── common/loading/loading_overlay.dart     LIVE   global Overlay spinner
        ├── common/loading/loading_indicator.dart   UNUSED
        ├── common/feedback/{empty_state,error}_widget.dart   UNUSED (⚠ the class named ErrorWidget shadows Flutter's)
        ├── common/dialogs/confirmation_dialog.dart UNUSED
        └── layout/responsive_builder.dart          UNUSED (still named KjpViewBuilder)
```

Other top-level items:
- `assets/` contains copies of `sqlite3.wasm` and `drift_worker.js`, but they are **not declared** in `pubspec.yaml`. Web loads the copies in `web/`.
- `test/` contains empty `core/` and `features/` folders.
- `build/`, `.dart_tool/`, `.fvm/`, `.idea/`, `trackpense.iml` are tooling artifacts.

---

## 6. Runtime architecture

### 6.1 Startup

```
main() → App (StatefulWidget)
  initState → initServiceLocator()          // registers everything in get_it
  while initializing: MaterialApp with a CircularProgressIndicator
  then: MultiBlocProvider[ UiBloc, TransactionBloc ] → MaterialApp.router(routerConfig: router)
```

If DI initialization throws, the error is logged and rethrown, and the app **stays on the spinner forever**.

### 6.2 Dependency graph (get_it)

```
AppDatabase                (lazy singleton)
TransactionRepository  →  TransactionRepositoryImpl(AppDatabase)   (factory)
Create/Update/Delete/WatchTransaction(s)  →  (TransactionRepository)  (factories)
TransactionBloc(create, update, delete, watch)   (factory, but created once by the BlocProvider in App)
UiBloc                      (factory, created once by the BlocProvider in App)
PreferencesService, SecureStorageService(InMemory)   (lazy singletons, never resolved)
```

Both BLoCs are **app-global**. They are provided above the router, so every screen shares the same `TransactionBloc` instance.

### 6.3 Layers in the transactions feature

```
UI (HomeView / PaymentFormView)
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

### 6.4 State machines

**TransactionBloc**

| Event | Behaviour | Emits |
|---|---|---|
| `TransactionLoadEvent` (dispatched by `HomeView.initState`) | Subscribes to `watchAllTransactions()` through `emit.forEach` and stays subscribed. | `Loading`, then `Loaded(list)` on every DB change, or `Error(msg)` |
| `TransactionCreateEvent(tx)` / `TransactionUpdateEvent(tx)` / `TransactionDeleteEvent(uuid)` | Calls the use case. | `Ready` on success, `Error(failure.message)` on failure |

Bloc's default event transformer is concurrent, so the long-running Load subscription keeps running while create and update events are handled. After a successful write, the state goes `Ready` → (the DB stream fires) → `Loaded`.

**UiBloc** (global UI chrome)

- States: `UiReadyState`, `UiLoadingState`, `UiErrorState(message, title)`.
- The `ShellRoute` builder in [app_router.dart](lib/core/navigation/app_router.dart) listens to it. `Loading` shows `LoadingOverlay`, any other state dismisses it, and `Error` shows an `AlertDialog`.
- `HomeView` dispatches `UiLoadingEvent`, `UiReadyEvent` and `UiErrorEvent` **from inside its `BlocBuilder.builder`**, depending on the `TransactionBloc` state.
- `LoadingOverlay` is a singleton. It stays visible for at least 1 s once shown, and it throws if it is still showing after 5 minutes.

### 6.5 Navigation

| Route name / path | Screen | `extra` |
|---|---|---|
| `RouteNames.home` = `/` | `HomeView` | none |
| `RouteNames.paymentForm` = `/payment-form` | `PaymentFormView(payment: Transaction?)` | a `Transaction` for edit, `null` for create |

Route names are the same strings as their paths. Navigation uses `context.pushNamed(...)` from go_router. Passing the entity through `extra` means deep links to the edit form cannot work.

The form closes itself through a `BlocListener` that calls `context.pop()` when it sees `TransactionReadyState`.

---

## 7. Data model and persistence

The Drift database is [lib/core/database/database.dart](lib/core/database/database.dart) with file name `trackpense.db`. Native platforms store it in `getApplicationSupportDirectory()`; web uses a WASM worker.

**Table `payment`** ([payment_table.dart](lib/core/database/tables/payment_table.dart)). The generated row class is `PaymentData` and the companion is `PaymentCompanion`:

| Column | Type | Constraints |
|---|---|---|
| `uuid` | TEXT | **primary key**; client default `Uuid().v4()` |
| `date` | DATETIME | required (Drift's default storage: Unix seconds) |
| `description` | TEXT | required, length 1–200 |
| `amount` | REAL | required, always positive; the sign comes from `is_expense` |
| `is_expense` | BOOL | required |
| `notes` | TEXT | nullable (added in schema v2) |

- **Schema version: 2.** The v1 → v2 migration adds `notes`. If you change a table, bump `schemaVersion`, add a branch to `onUpgrade`, and re-run `build_runner`. Real user data exists on installed devices, so never break migrations.
- The domain uses the name **Transaction**, but the database and UI still say **Payment** (`Payment` table, `PaymentFormView`, the `payment` param, `/payment-form`). Treat them as the same thing.
- The refactor added CRUD helpers on `AppDatabase`: `createPayment`, `updatePayment` (WHERE uuid = …, write), `deletePayment`, `getPayment`, and `watchAllPayments`.
- `amount` is stored as a `double`. There is no currency or value object. The display format is `#,##0.00`.

---

## 8. Business rules (where they live today)

| Rule | Location |
|---|---|
| Description required, max 200 chars | DB constraint, plus the `AppTextFormField` counter and `maxLength` (default `AppConfig.maxDescriptionLength`), plus an inline validator in the form |
| Amount: digits plus one `.`, at most 2 decimals, comma-grouped while typing | `DecimalTextInputFormatter(decimalDigits: 2)` followed by `CommaSeparatedInputFormatter`; parsed with `String.toCleanDouble()` (strips commas, falls back to `0.0`) |
| New or editable dates must be within the last 7 days | `showDatePicker(firstDate: now − 7d, lastDate: now)` in `payment_form_view.dart` |
| Transactions older than 7 days: date and time are read-only | `now.difference(date).inDays > 7` in `_dateTimeSelectors` |
| Income vs expense | `isExpense` bool; defaults to expense |

`AppConfig.transactionEditWindowDays` (7) and `AppConfig.maxNotesLength` (1000) exist but are **not used**. The 7 is still hardcoded, and notes have no length limit.

---

## 9. Known issues and refactor regressions (verify these first)

These were found by reading the code and comparing it with the pre-refactor `HEAD`. None has been confirmed on a device. Items 1–4 are **behaviour regressions** introduced by the refactor.

1. **Form validation is skipped.** The old Save button called `formKey.currentState!.validate()`. The new `_submitForm()` does not, so:
   - an empty amount is saved as `0.0`;
   - an empty description reaches Drift, which throws `InvalidDataException`; the user only sees a generic "Failed to create transaction" dialog.

   `formKey` is also re-created on every `build`. It should be a `State` field.
2. **List ordering was lost.** The old repo ordered by `date DESC`. `AppDatabase.watchAllPayments()` has no `orderBy`, so the order is whatever SQLite returns.
3. **Notes cannot be cleared on edit.** `TransactionModel.toPaymentCompanion()` uses `Value.absent()` when notes are `null`. An update that clears the notes field leaves the old notes in place. The old code wrote `Value(null)`.
4. **Error detail was lost.** The repository wraps every exception in `DatabaseFailure('Failed to … transaction')`. `UiBloc`'s special formatting for Drift `InvalidDataException` (field-level messages) can no longer trigger.
5. **Side effects inside `build`.** `HomeView` dispatches `UiBloc` events from `BlocBuilder.builder`. The pre-refactor version correctly used `BlocConsumer.listener`. The new version also renders an empty body for `Ready` and `Error` states. A failed save leaves the home list **blank** until the DB changes again, because the old states carried the list and the new ones don't.
6. **Shared global `TransactionBloc`.** The form pops on any `TransactionReadyState`, and the home screen reacts to every state. Adding more screens or features to this BLoC will cause cross-talk. Consider a separate form cubit, or scoping the BLoC per route.
7. **Delete is unreachable.** `DeleteTransaction` and `TransactionDeleteEvent` exist, but there is no UI for them.
8. **`watchTransactionsByDateRange`** filters in memory with exclusive bounds and is unused.
9. **`ContextExtensions` (unused) is buggy.** Its `showDialog` calls itself, which recurses forever. Its `pushNamed` and `pop` clash with go_router's `BuildContext` extensions, so importing both causes ambiguity errors. Fix it or delete it before using it.
10. **`core/widgets/common/feedback/error_widget.dart` declares `class ErrorWidget`**, which shadows Flutter's own `ErrorWidget`. Rename it, for example to `AppErrorWidget`, before using it.
11. **No theme.** `MaterialApp.router` gets no `theme`, and `AppTypography`, `AppSpacing` and `AppBorderRadius` are unused.
12. **Placeholder services.** `SecureStorageService` is registered as `InMemorySecureStorageService`, which is not persistent. `PreferencesService` is never used.
13. **Stale docs.** The root `README.md` mentions a deleted debug keystore. The tracking tables in `MIGRATION_STRATEGY.md` are not updated.

---

## 10. Conventions

- **Imports:** always `package:trackpense/...` (lint enforced). Keep directives sorted.
- **Naming:** files use `snake_case`. The `Kjp`/`Kb` prefixes are being phased out in favour of `App*` (`AppColors`, `AppConfig`, `AppTextFormField`). Leftovers: `KjpViewBuilder` and the extension name `KbDateTimeFormatting`.
- **Feature layout** (from `TARGET_ARCHITECTURE.md`): `features/<name>/{domain/{entities,repositories,usecases}, data/{models,repositories,datasources}, presentation/{blocs|pages|widgets}}`. Domain must not import Flutter or Drift.
- **Errors:** repositories catch exceptions and return `Either.left(SomeFailure(...))`. BLoCs `fold` the result into states.
- **Constants:** put them in `AppConfig`. Colours go in `AppColors`.
- **Generated code:** never edit `database.g.dart` by hand. Run `dart run build_runner build`.
- **Releases:** bump `pubspec.yaml` `version`, add a `CHANGELOG.md` entry, then merge `dev` → `master` (CI releases the APK).

---

## 11. Suggested next steps

1. **Smoke-test the refactor** on Android, Windows and Web: create, edit, the 7-day rule, notes, and an upgrade from an existing v1.1.1 install so you know the existing DB still opens.
2. **Fix regressions 1–5 in §9.** They are small and local: restore `validate()`, add `orderBy(date desc)`, use `Value(notes)`, move the UiBloc dispatches into a listener, and keep the last list in state.
3. **Add tests.** Start with `TransactionRepositoryImpl` against an in-memory Drift DB (`AppDatabase(NativeDatabase.memory())`; the constructor already accepts an executor), then the mappers, the BLoC (`bloc_test`), and the formatters and validators.
4. **Finish the migration (Phase 4 of the plan) or simplify it.** Move `src/views` and `src/widgets` into `features/transactions/presentation/{pages,widgets}`, move `UiBloc` into `core/`, and delete the unused scaffolding or wire it in (validators, theme). The full target in `TARGET_ARCHITECTURE.md`, with 12 features, network and sync, is far beyond what this app needs today. Treat it as a menu, not a mandate.
5. **Build the redesigned form** from `design_images/`. Attachments will need a new table, a schema v3 migration, and file storage.
6. **Update `README.md`** with real setup instructions, or point it to this file.
