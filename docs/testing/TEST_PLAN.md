# TrackPense Test Plan

> **Audience:** anyone changing TrackPense: developers, reviewers and AI agents.
> **Purpose:** what is tested today, how to run it, and which integration, system and acceptance tests still need to be built, in priority order.
>
> Last updated 2026-10-27. Keep this file in sync when you add or retire tests: tick the checkboxes and update the IDs' status.

---

## 1. Test levels at a glance

| Level | Question it answers | Runs where | Status |
|---|---|---|---|
| **Unit** | Does this class or function behave correctly on its own? | `flutter test`, on any host | ✅ In place (§3) |
| **Widget** | Does this screen or widget render and react correctly, with fakes behind it? | `flutter test`, on any host | ✅ In place (§3) |
| **Migration** | Does every schema upgrade keep existing user data intact? | `flutter test`, on any host | ✅ In place (§3) |
| **Integration** | Do the real parts (router, DI, BLoCs, Drift on disk, overlay and dialogs) work together inside the running app? | `integration_test` on a device, desktop or browser | ❌ To build (§4) |
| **System** | Does the *built, installed* app work on each real platform: install, upgrade, persistence, performance, accessibility? | Release builds on real devices | ❌ To build (§5) |
| **Acceptance** | Does the app do what the user needs? Is a release ready to ship? | Manual checklist before each release, partly automated | ❌ To build (§6) |

Rule of thumb: push every check to the **lowest** level that can catch the problem. Unit and widget tests are fast and run on every PR. System and acceptance testing is slow and mostly manual, so it is reserved for what can only be verified on a real install.

---

## 2. Running the tests

```bash
fvm flutter test                       # everything under test/ (≈105 tests, a few seconds)
fvm flutter test test/drift            # only the database migration tests
fvm flutter test --plain-name "notes"  # tests whose name contains "notes"
fvm flutter test --coverage            # writes coverage/lcov.info
```

Tests use a **real in-memory SQLite database** where the database matters (`AppDatabase(NativeDatabase.memory())`). On Windows and macOS hosts this works out of the box. On Linux CI it needs `libsqlite3`, which GitHub's `ubuntu-latest` image already includes.

---

## 3. What exists today

The `test/` tree mirrors `lib/`:

```
test/
├── helpers/                         shared test code
│   ├── fake_transaction_repository.dart   in-memory TransactionRepository; set `failure` to make writes fail
│   ├── transaction_bloc_factory.dart      TransactionBloc wired to real use cases over a repository
│   └── transaction_fixtures.dart          buildTransaction(...) with sensible defaults
├── core/
│   ├── extensions/                  string, double, DateTime and Color extensions
│   ├── presentation/blocs/          UiBloc, including Drift validation-error formatting
│   └── utils/                       validators and the amount input formatters
├── features/transactions/
│   ├── domain/                      entity equality/copyWith; use cases delegate to the repository
│   ├── data/                        TransactionModel mapping; repository against in-memory SQLite
│   └── presentation/                TransactionBloc (bloc_test); list page, form page and card widget tests
└── drift/app_database/              migration tests + generated schema helpers (do not edit generated/)
```

**Regression tests.** These guard bugs that have already happened once. Each is marked with a `// Regression:` comment and was confirmed to fail on the buggy code:

| Bug | Guarded by |
|---|---|
| Form saved without validating | `transaction_form_page_test.dart`: "does not save while required fields are empty" |
| List not ordered newest first | `transaction_repository_impl_test.dart`: "lists transactions newest first" |
| Notes could not be cleared on edit | `transaction_model_test.dart`, `transaction_repository_impl_test.dart`, `transaction_form_page_test.dart` |
| List went blank after a failed save | `transaction_list_page_test.dart`: "keeps showing the list and reports the error when a save fails" |
| Card date column overflowed at large text sizes | `transaction_card_test.dart`: "lays out without overflow at a large system text size" |
| A broken v1 → v2 migration would lose data | `test/drift/app_database/migration_test.dart` |

### Conventions for writing tests
- **One behaviour per test.** Name it as a sentence about behaviour ("rejects a zero amount"), not about implementation.
- **Use `buildTransaction(...)`** and override only the fields the test is about.
- **Dates in database tests must have whole seconds.** Drift stores `DateTime` with second precision.
- **Widget tests: let `BlocProvider(create: ...)` own blocs.** Closing a bloc from `addTearDown` hangs the test, because widget tests run in a fake-async zone.
- **Add a `// Regression:` test for every bug you fix,** and check that it fails without the fix.

### Changing the database schema (migration workflow)
Before any table change, for example adding attachments in schema v3:
1. Change the tables, bump `schemaVersion` in `lib/core/database/database.dart`, and run `fvm dart run build_runner build`.
2. Run `fvm dart run drift_dev make-migrations`. This snapshots the new version into `drift_schemas/`, regenerates `test/drift/.../generated/`, and generates `lib/core/database/database.steps.dart`.
3. Write the migration with `stepByStep(from2To3: ...)` from the generated steps file. It uses frozen snapshots of each version, so later table changes can't break old migrations.
4. Add a data-integrity test for v2 → v3 in `migration_test.dart`, modelled on the v1 → v2 one, and run `fvm flutter test test/drift`.
5. Commit the new snapshot JSON together with the migration. **Never edit or delete old snapshots.**

---

## 4. Integration tests (to build)

**Scope:** the real app running in-process on a device, desktop or browser, with real routing, DI, BLoCs, overlay and dialogs, and Drift on a real database file. The aim is to catch wiring problems that unit and widget tests can't see, because those tests replace collaborators with fakes.

**Tooling:** the `integration_test` package (Flutter SDK). Tests live in `integration_test/` and run with:
```bash
fvm flutter test integration_test -d windows     # or an Android emulator, or -d chrome
```

**Prerequisites in the app code:**
- [ ] **Injectable database.** `initServiceLocator()` always creates `AppDatabase()` on the default file, so tests can't isolate their data or start from a fixture. Let it accept an optional `QueryExecutor`/`AppDatabase` (or register overrides before init).
- [ ] **Injectable clock.** The 7-day rule reads `DateTime.now()` directly, so date behaviour can't be tested deterministically. Introduce a `Clock` (e.g. `package:clock`) and use it in the form.
- [ ] **Stable widget keys** on the form fields and buttons (`ValueKey('transaction-form.amount')`, …). Widget tests currently find fields by index, which breaks if the field order changes.

| ID | Scenario | Expected result | Priority |
|---|---|---|---|
| INT-01 | Cold start with an empty database | DI initialises, the spinner disappears, the list shows "No transactions yet" | High |
| INT-02 | Tap **+**, fill the form, Save | The app returns to the list; the new card is at the top; the loading overlay appears and is dismissed | High |
| INT-03 | Tap a card, change description and amount, Save | The list shows the updated values; no duplicate is created | High |
| INT-04 | Edit a transaction, clear its notes, Save, restart the app | Notes are still empty after the restart (persisted on disk, not only in memory) | High |
| INT-05 | Save with empty fields | Validation messages appear; no navigation; nothing written to the database | Medium |
| INT-06 | Database write fails (inject a failing repository) | The error dialog from the `ShellRoute` listener appears; dismissing it returns to the form | Medium |
| INT-07 | Persistence: add data, close the database, reopen the same file | All rows are present, newest first | High |
| INT-08 | **Upgrade from a real v1 database file:** start the app on a fixture `.sqlite` file created by v1.0.x | The app opens, shows every old transaction, and notes are empty; new transactions can be added | High |
| INT-09 | Web: run on Chrome | `drift_worker.js` and `sqlite3.wasm` load; data survives a page reload (IndexedDB). Also run `dart run tool/setup_web_db.dart --check` in CI. | Medium |
| INT-10 | Date window with an injected clock: transactions 6 days, 7 days 10 hours, and 8 days old | Date pickers are shown only within the window, and opening the picker never throws (see finding F-1) | High (after the clock exists) |
| INT-11 | Back navigation: open the form, press Cancel or system back | Returns to the list with nothing saved | Low |

---

## 5. System tests (to build)

**Scope:** the **release build installed on real platforms**, tested as a user would get it from the GitHub Release or a local release build. These checks can't be done in-process: installation, upgrades signed with the real key, OS settings, performance on real hardware, and platform storage.

**Tooling:** mostly a manual checklist per release (§7). Later, consider automating the Android part with [Patrol](https://patrol.leancode.co/) on an emulator in CI, or Firebase Test Lab.

### 5.1 Install and upgrade

| ID | Scenario | Expected result |
|---|---|---|
| SYS-01 | Fresh install of the release APK on Android (minSdk 26 → latest) | Installs and opens on the empty state |
| SYS-02 | **Upgrade over the previous GitHub release that has data** (e.g. 1.1.1 → next) | Installs without uninstalling (same signing key); all data is kept; the migration runs once |
| SYS-03 | Upgrade from the oldest release still in use (v1 schema, before notes) | Data is kept and notes are empty |
| SYS-04 | Install a CI-built APK over a locally built one, and vice versa | Accepted (shared keystore, see CHANGELOG 1.1.1) |
| SYS-05 | Windows release build from a clean folder | Starts; the database is created under `%APPDATA%\com.kjp\trackpense\` |
| SYS-06 | Web release build served over HTTPS | Loads and persists data in IndexedDB across reloads and browser restarts |

### 5.2 Platform behaviour

| ID | Scenario | Expected result |
|---|---|---|
| SYS-07 | Kill the app right after Save; reopen | The transaction was saved |
| SYS-08 | Device reboot, or OS low-memory kill | Data intact |
| SYS-09 | Airplane mode | The app works fully (it is offline-only) |
| SYS-10 | Change the device **time zone**, then view and edit existing transactions | Times display in the new local zone; editing doesn't shift the stored instant unexpectedly (dates are stored as Unix seconds) |
| SYS-11 | Clock change around a DST boundary or midnight | The 7-day rule and date display stay consistent |
| SYS-12 | Rotation, small and large phones, tablet; Windows window resizing | No overflow; the form scrolls; the buttons stay reachable |
| SYS-13 | Web on Chrome, Edge and Firefox; a private window; two tabs open at once | Works; in a private window data may not persist (expected); two tabs don't corrupt data |

### 5.3 Non-functional

| ID | Scenario | Expected result |
|---|---|---|
| SYS-14 | **Large data set:** 5,000 and 20,000 transactions | The list scrolls smoothly; cold start is under 2 s on a mid-range phone. Note that `watchAllPayments()` loads every row with no pagination, so this test decides whether pagination is needed. |
| SYS-15 | **Accessibility:** largest system font size and display size | No overflow anywhere (the card fix covers the list; check the form and dialogs) |
| SYS-16 | **Screen reader** (TalkBack, Narrator) | Every control has a meaningful label; the Income/Expense switch announces its state |
| SYS-17 | Dark mode on the OS | Readable (the app currently ignores dark mode; record the result) |
| SYS-18 | APK size and startup time, compared with the previous release | No unexplained regression |

---

## 6. Acceptance tests (to build)

**Scope:** user-visible behaviour described as user scenarios. Together they are the **definition of done for a release**: a version ships only when every acceptance test for its features passes. They are written in Given/When/Then form so they can be run by hand now and automated as integration tests later (the ✱ column marks which integration test covers each one).

### Feature: record a transaction

| ID | Given / When / Then | ✱ |
|---|---|---|
| AT-01 | **Given** the list is open, **when** I tap +, enter "Lunch" and "1250", keep *Expense*, and tap Save, **then** I'm back on the list and "Lunch – 1,250.00" is at the top, tinted red. | INT-02 |
| AT-02 | **When** I turn the switch to *Income* and save "Salary 150000", **then** the card is tinted green. | INT-02 |
| AT-03 | **When** I tap Save with an empty description or amount, **then** I see "Description is required" / "Amount is required" and nothing is saved. | INT-05 |
| AT-04 | **When** I enter an amount of 0, **then** I see "Amount must be greater than 0". | — |
| AT-05 | **When** I type `1234567.891` in Amount, **then** the field shows `1,234,567.89`. | — |
| AT-06 | **When** I type in Description, **then** a counter shows the characters used out of 200, and I can't enter more than 200. | — |
| AT-07 | **When** I open the date picker on a new transaction, **then** only today and the previous 7 days can be chosen, and future dates can't. | INT-10 |
| AT-08 | **When** I write multi-line notes and save, **then** the card shows only the first line followed by " .....". | — |

### Feature: edit a transaction

| ID | Given / When / Then | ✱ |
|---|---|---|
| AT-09 | **Given** a transaction, **when** I tap its card, **then** the form opens titled "Edit Transaction" with all fields filled in. | INT-03 |
| AT-10 | **When** I change the values and save, **then** the card shows the new values and no duplicate appears. | INT-03 |
| AT-11 | **When** I clear the notes and save, **then** the card shows no notes, including after restarting the app. | INT-04 |
| AT-12 | **Given** a transaction older than 7 days, **when** I open it, **then** its date and time are shown but can't be changed, while the other fields still can. | INT-10 |

### Feature: browse transactions

| ID | Given / When / Then | ✱ |
|---|---|---|
| AT-13 | **Given** no transactions, **then** the list shows "No transactions yet". | INT-01 |
| AT-14 | **Given** several transactions, **then** they are listed newest first, by date and time. | INT-07 |
| AT-15 | **Given** a failed save, **then** an error dialog explains it and the list is still visible afterwards. | INT-06 |

### Feature: my data is safe

| ID | Given / When / Then | ✱ |
|---|---|---|
| AT-16 | **Given** I have transactions, **when** I close and reopen the app, **then** they are all still there. | INT-07 |
| AT-17 | **Given** I have the previous release with data, **when** I install the new release over it, **then** all my transactions are still there. | SYS-02 |

### Not yet accepted (features without acceptance tests)
These features don't exist yet. Write their acceptance tests when the feature is planned, before building it: deleting a transaction, attachments, categories, totals/summaries, search, export/backup, dark mode.

---

## 7. Release checklist

Run before merging `dev` → `master` (which publishes a release):

- [ ] CI green: `dart format`, `flutter analyze`, `flutter test` (and `setup_web_db.dart --check` once wired in)
- [ ] Integration tests pass on Windows and an Android emulator (once §4 exists)
- [ ] SYS-01, SYS-02, SYS-05 and SYS-15 checked by hand on real hardware
- [ ] Every acceptance test for changed features passes (§6)
- [ ] `version` bumped in `pubspec.yaml`; `CHANGELOG.md` updated
- [ ] If the schema changed: new snapshot committed in `drift_schemas/`, and migration tests added and passing

---

## 8. Findings from testing (to resolve)

Found while writing the tests; not fixed yet. Give each one an issue and remove it from this list once fixed and covered by a test.

| ID | Finding | Impact | Suggested fix |
|---|---|---|---|
| F-1 | **Date picker can fail for transactions about 7–8 days old.** The form treats a transaction as editable while fewer than 8 full 24-hour periods have passed (`inDays > 7` is false), but `showDatePicker` compares calendar days and asserts that the initial date is not before `firstDate`. Example: a transaction 7 days and 10 hours old whose calendar day is before the first allowed day. Tapping the calendar icon then fails the assertion: a crash in debug builds, an out-of-range picker in release builds. | Medium: a crash or odd picker in a narrow window | Use one definition of the window based on calendar days, e.g. `DateUtils.dateOnly(now).difference(DateUtils.dateOnly(date)).inDays > 7`, for both the read-only rule and `firstDate`. Cover it with INT-10 once a clock is injectable. |
| F-2 | **A future time can be chosen for today.** The date picker stops at today, but the time picker doesn't stop at the current time. | Low: a transaction can be dated a few hours ahead | Validate on Save that the date/time is not in the future. |
| F-3 | **v1 descriptions of 201–255 characters can't be re-saved.** v1 allowed 255 characters, v2 allows 200. Such rows load fine (migration test), but they can't be saved again unchanged: the field and validator only accept 200. | Low: only affects very old, very long entries | Accept, or truncate during a future migration. Document whichever is chosen. |
| F-4 | **`Transaction.copyWith` can't clear notes.** `copyWith(notes: null)` keeps the old notes, because `null` means "unchanged". | Low today (the form builds a new `Transaction` instead) | Use a sentinel or a `ValueGetter<String?>` parameter if `copyWith` starts being used for edits. |
| F-5 | **No clock or database injection** (see §4 prerequisites). | Blocks deterministic integration tests | Add both before writing integration tests. |
| F-6 | **Ten source files don't match `dart format`** (with the project's 200-column setting), most from the AI refactor. | Blocks a CI format check | One `dart format lib` commit when the CI format check is added. |
