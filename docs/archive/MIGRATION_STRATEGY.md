# TrackPense Migration Strategy

**Date:** July 27, 2026  
**Author:** Cascade AI  
**Project:** TrackPense v1.1.1

---

## Overview

This document outlines the step-by-step migration strategy for refactoring TrackPense from its current architecture to a feature-based Clean Architecture. The migration will be performed incrementally to ensure the application remains functional throughout the process.

---

## Migration Principles

1. **Incremental Migration:** Never perform a "big bang" rewrite
2. **Continuous Functionality:** App must build and run after each phase
3. **Test-Driven:** Write tests before refactoring where possible
4. **Backward Compatibility:** Maintain old code until new code is verified
5. **Feature Isolation:** Migrate one feature at a time
6. **Verification:** Run flutter analyze and tests after each step

---

## Migration Phases

### Phase 0: Preparation

**Objective:** Set up infrastructure for migration

**Tasks:**
1. Create backup of current codebase
2. Update pubspec.yaml with new dependencies (get_it)
3. Create new folder structure (empty folders with READMEs)
4. Set up test directory structure
5. Create migration tracking document

**Deliverables:**
- Backup commit
- Updated pubspec.yaml
- Empty folder structure
- Test directory structure
- Migration tracking spreadsheet

**Verification:**
- `flutter pub get` succeeds
- Project builds without errors

---

### Phase 1: Core Layer Foundation

**Objective:** Establish core infrastructure

**Tasks:**

#### 1.1 Error Handling
- Create `core/error/failures.dart`
- Create `core/error/exceptions.dart`
- Create `core/error/error_handler.dart`
- Write unit tests for error handling

**Files to Create:**
```
lib/core/error/failures.dart
lib/core/error/exceptions.dart
lib/core/error/error_handler.dart
test/core/error/failures_test.dart
test/core/error/exceptions_test.dart
test/core/error/error_handler_test.dart
```

**Files to Modify:** None

**Verification:**
- Tests pass
- flutter analyze passes

#### 1.2 Database Abstraction
- Move `lib/data/database/` to `lib/core/database/`
- Create `core/database/migrations/` folder
- Extract migration logic to separate files
- Create database provider for DI

**Files to Move:**
```
lib/data/database/database.dart → lib/core/database/database.dart
lib/data/database/database.g.dart → lib/core/database/database.g.dart
lib/data/database/tables/payment.dart → lib/core/database/tables/payment_table.dart
```

**Files to Create:**
```
lib/core/database/migrations/migration_strategy.dart
lib/core/database/migrations/migration_v1_to_v2.dart
lib/core/di/core_providers.dart
```

**Files to Modify:**
```
lib/data/blocs/payment_bloc.dart (update imports)
lib/data/repositories/payment_repo.dart (update imports)
lib/src/app.dart (update imports)
```

**Verification:**
- Project builds
- Database migrations work
- flutter analyze passes

#### 1.3 Storage Services
- Create `core/storage/storage_service.dart`
- Create `core/storage/secure_storage_service.dart`
- Create `core/storage/preferences_service.dart`
- Write unit tests

**Files to Create:**
```
lib/core/storage/storage_service.dart
lib/core/storage/secure_storage_service.dart
lib/core/storage/preferences_service.dart
test/core/storage/storage_service_test.dart
```

**Files to Modify:** None

**Verification:**
- Tests pass
- flutter analyze passes

#### 1.4 Utilities Organization
- Move existing utils to `core/utils/formatters/`
- Create `core/utils/validators/` folder
- Create `core/utils/helpers/` folder
- Standardize naming

**Files to Move:**
```
lib/core/utils/decimal_text_input_formatter.dart → lib/core/utils/formatters/decimal_input_formatter.dart
lib/core/utils/comma_separated_decimal_text_input_formatter.dart → lib/core/utils/formatters/currency_formatter.dart
```

**Files to Create:**
```
lib/core/utils/validators/amount_validator.dart
lib/core/utils/validators/date_validator.dart
lib/core/utils/validators/description_validator.dart
lib/core/utils/helpers/date_helper.dart
lib/core/utils/helpers/currency_helper.dart
```

**Files to Modify:**
```
lib/src/views/payment_form_view.dart (update imports)
```

**Verification:**
- Project builds
- All imports resolved
- flutter analyze passes

#### 1.5 Extensions Organization
- Standardize extension naming
- Add missing extensions
- Document each extension

**Files to Rename:**
```
lib/core/extensions/datetime_extension.dart → lib/core/extensions/datetime_extensions.dart
lib/core/extensions/color_extension.dart → lib/core/extensions/color_extensions.dart
lib/core/extensions/double_extension.dart → lib/core/extensions/double_extensions.dart
lib/core/extensions/string_extension.dart → lib/core/extensions/string_extensions.dart
```

**Files to Create:**
```
lib/core/extensions/context_extensions.dart
```

**Files to Modify:**
```
All files using extensions (update imports if needed)
```

**Verification:**
- Project builds
- flutter analyze passes

#### 1.6 Theme System
- Move colors to `core/theme/`
- Create spacing system
- Create typography system
- Create border radius system

**Files to Move:**
```
lib/data/constants/kjp_colors.dart → lib/core/theme/app_colors.dart
```

**Files to Create:**
```
lib/core/theme/app_spacing.dart
lib/core/theme/app_typography.dart
lib/core/theme/app_border_radius.dart
```

**Files to Modify:**
```
lib/src/views/payment_form_view.dart (update imports)
lib/src/widgets/item_card.dart (update imports)
lib/src/widgets/loading.dart (update imports)
lib/core/extensions/color_extensions.dart (update imports)
```

**Verification:**
- Project builds
- Theme works correctly
- flutter analyze passes

#### 1.7 Shared Widgets
- Move reusable widgets to `core/widgets/`
- Organize by type
- Standardize naming

**Files to Move:**
```
lib/src/widgets/loading.dart → lib/core/widgets/common/loading/loading_overlay.dart
lib/src/widgets/kjp_widgets/kjp_text_form_field.dart → lib/core/widgets/common/inputs/app_text_field.dart
lib/src/widgets/kjp_widgets/kjp_view_builder.dart → lib/core/widgets/layout/responsive_builder.dart
```

**Files to Create:**
```
lib/core/widgets/common/buttons/primary_button.dart
lib/core/widgets/common/buttons/secondary_button.dart
lib/core/widgets/common/cards/app_card.dart
lib/core/widgets/common/loading/loading_indicator.dart
lib/core/widgets/common/feedback/error_widget.dart
lib/core/widgets/common/feedback/empty_state_widget.dart
lib/core/widgets/common/dialogs/confirmation_dialog.dart
lib/core/widgets/common/dialogs/error_dialog.dart
```

**Files to Modify:**
```
lib/src/views/payment_form_view.dart (update imports)
lib/src/views/home_view.dart (update imports)
lib/src/router.dart (update imports)
```

**Verification:**
- Project builds
- Widgets render correctly
- flutter analyze passes

#### 1.8 Navigation
- Create `core/navigation/` folder
- Extract navigation logic
- Create navigation service

**Files to Create:**
```
lib/core/navigation/navigation_service.dart
lib/core/navigation/route_guard.dart
```

**Files to Move:**
```
lib/src/router.dart → lib/core/navigation/app_router.dart
lib/src/router/route_names.dart → lib/app/constants/route_constants.dart
```

**Files to Modify:**
```
lib/src/app.dart (update imports)
lib/main.dart (update imports)
```

**Verification:**
- Navigation works
- Deep linking supported
- flutter analyze passes

#### 1.9 Logging
- Create logging infrastructure
- Add log levels
- Integrate with error handling

**Files to Create:**
```
lib/core/logging/logger.dart
lib/core/logging/log_level.dart
```

**Files to Modify:**
```
lib/data/blocs/ui_bloc.dart (use new logger)
```

**Verification:**
- Logging works
- flutter analyze passes

#### 1.10 Configuration
- Create app configuration
- Create environment configuration
- Create feature flags

**Files to Create:**
```
lib/core/config/app_config.dart
lib/core/config/env_config.dart
lib/core/config/feature_flags.dart
```

**Files to Modify:**
```
lib/data/constants/kjp_miscellaneous.dart → move constants to appropriate config files
```

**Verification:**
- Configuration loads correctly
- flutter analyze passes

**Phase 1 Deliverables:**
- Complete core layer
- All tests passing
- Project builds successfully
- Documentation updated

**Phase 1 Verification:**
- `flutter analyze` passes with no warnings
- `flutter test` passes
- App runs without errors

---

### Phase 2: App Layer

**Objective:** Set up app-level configuration

**Tasks:**

#### 2.1 App Structure
- Create `app/` folder structure
- Move app.dart to app/
- Create app theme configuration
- Create localization setup

**Files to Move:**
```
lib/src/app.dart → lib/app/app.dart
```

**Files to Create:**
```
lib/app/theme/app_theme.dart
lib/app/theme/app_colors.dart
lib/app/theme/app_text_theme.dart
lib/app/theme/dark_theme.dart
lib/app/localization/app_localizations.dart
lib/app/localization/strings/en.dart
lib/app/constants/app_constants.dart
lib/app/constants/storage_constants.dart
```

**Files to Modify:**
```
lib/main.dart (update imports)
```

**Verification:**
- App builds
- Theme loads
- flutter analyze passes

#### 2.2 Dependency Injection Setup
- Add get_it dependency
- Create DI container
- Register core services
- Wire up in main.dart

**Files to Modify:**
```
pubspec.yaml (add get_it)
lib/app/dependency_injection.dart (create)
lib/main.dart (call setupDependencyInjection)
```

**Files to Create:**
```
lib/app/dependency_injection.dart
```

**Verification:**
- DI container initializes
- Services are registered
- flutter analyze passes

**Phase 2 Deliverables:**
- App layer structure
- DI container working
- Theme system working
- Localization setup

**Phase 2 Verification:**
- `flutter analyze` passes
- App runs without errors
- DI services resolve correctly

---

### Phase 3: Shared Layer

**Objective:** Extract shared functionality

**Tasks:**

#### 3.1 Shared Presentation
- Create shared widgets
- Create shared providers
- Create shared dialogs
- Create shared bottom sheets

**Files to Create:**
```
lib/shared/presentation/widgets/dialogs/app_dialog.dart
lib/shared/presentation/widgets/dialogs/confirmation_dialog.dart
lib/shared/presentation/widgets/bottom_sheets/app_bottom_sheet.dart
lib/shared/presentation/widgets/bottom_sheets/filter_bottom_sheet.dart
lib/shared/presentation/widgets/snackbars/app_snackbar.dart
lib/shared/presentation/widgets/snackbars/error_snackbar.dart
lib/shared/presentation/providers/ui_provider.dart
```

**Files to Modify:**
```
lib/src/router.dart (use shared dialogs)
lib/data/blocs/ui_bloc.dart → migrate to ui_provider
```

**Verification:**
- Shared components work
- flutter analyze passes

#### 3.2 Shared Domain
- Create shared entities
- Create shared value objects

**Files to Create:**
```
lib/shared/domain/entities/ui_state.dart
```

**Verification:**
- flutter analyze passes

#### 3.3 Shared Data
- Create shared data sources
- Create shared models

**Files to Create:**
```
lib/shared/data/datasources/ui_local_datasource.dart
```

**Verification:**
- flutter analyze passes

**Phase 3 Deliverables:**
- Shared layer complete
- UI state management refactored
- Shared components working

**Phase 3 Verification:**
- `flutter analyze` passes
- Shared components work correctly

---

### Phase 4: Transactions Feature (First Feature Migration)

**Objective:** Migrate transactions feature to Clean Architecture

**Tasks:**

#### 4.1 Domain Layer
- Create transaction entity
- Create repository interface
- Create use cases
- Create value objects

**Files to Create:**
```
lib/features/transactions/domain/entities/transaction.dart
lib/features/transactions/domain/repositories/transaction_repository.dart
lib/features/transactions/domain/usecases/get_transactions.dart
lib/features/transactions/domain/usecases/get_transaction_by_id.dart
lib/features/transactions/domain/usecases/create_transaction.dart
lib/features/transactions/domain/usecases/update_transaction.dart
lib/features/transactions/domain/usecases/delete_transaction.dart
lib/features/transactions/domain/usecases/search_transactions.dart
lib/features/transactions/domain/value_objects/amount.dart
lib/features/transactions/domain/value_objects/description.dart
lib/features/transactions/domain/value_objects/transaction_date.dart
test/features/transactions/domain/entities/transaction_test.dart
test/features/transactions/domain/usecases/get_transactions_test.dart
test/features/transactions/domain/usecases/create_transaction_test.dart
test/features/transactions/domain/usecases/update_transaction_test.dart
```

**Files to Modify:** None

**Verification:**
- Domain layer compiles
- Tests pass
- flutter analyze passes

#### 4.2 Data Layer
- Create data source
- Create models
- Create mappers
- Implement repository

**Files to Create:**
```
lib/features/transactions/data/datasources/transaction_local_datasource.dart
lib/features/transactions/data/models/transaction_model.dart
lib/features/transactions/data/mappers/transaction_mapper.dart
lib/features/transactions/data/repositories/transaction_repository_impl.dart
test/features/transactions/data/datasources/transaction_local_datasource_test.dart
test/features/transactions/data/models/transaction_model_test.dart
test/features/transactions/data/mappers/transaction_mapper_test.dart
test/features/transactions/data/repositories/transaction_repository_impl_test.dart
```

**Files to Modify:** None

**Verification:**
- Data layer compiles
- Tests pass
- flutter analyze passes

#### 4.3 Presentation Layer
- Create pages
- Create widgets
- Create providers
- Wire up routing

**Files to Create:**
```
lib/features/transactions/presentation/pages/transactions_list_page.dart
lib/features/transactions/presentation/pages/transaction_detail_page.dart
lib/features/transactions/presentation/pages/transaction_form_page.dart
lib/features/transactions/presentation/widgets/transaction_card.dart
lib/features/transactions/presentation/widgets/transaction_filter_chip.dart
lib/features/transactions/presentation/widgets/transaction_search_bar.dart
lib/features/transactions/presentation/widgets/amount_input_widget.dart
lib/features/transactions/presentation/providers/transaction_list_provider.dart
lib/features/transactions/presentation/providers/transaction_form_provider.dart
lib/features/transactions/presentation/providers/transaction_detail_provider.dart
test/features/transactions/presentation/providers/transaction_list_provider_test.dart
test/features/transactions/presentation/widgets/transaction_card_test.dart
```

**Files to Move:**
```
lib/src/views/home_view.dart → lib/features/transactions/presentation/pages/transactions_list_page.dart
lib/src/views/payment_form_view.dart → lib/features/transactions/presentation/pages/transaction_form_page.dart
lib/src/widgets/item_card.dart → lib/features/transactions/presentation/widgets/transaction_card.dart
```

**Files to Modify:**
```
lib/core/navigation/app_router.dart (update routes)
lib/app/dependency_injection.dart (register transaction providers)
```

**Verification:**
- Presentation layer compiles
- Pages render correctly
- Navigation works
- flutter analyze passes

#### 4.4 Integration
- Wire up DI for transactions
- Update routing
- Remove old code
- Test end-to-end

**Files to Modify:**
```
lib/app/dependency_injection.dart (register transaction dependencies)
lib/core/navigation/app_router.dart (use new pages)
lib/data/blocs/payment_bloc.dart (delete after verification)
lib/data/models/payment_model.dart (delete after verification)
lib/data/repositories/payment_repo.dart (delete after verification)
```

**Verification:**
- App builds
- Transactions feature works
- All CRUD operations work
- flutter analyze passes

**Phase 4 Deliverables:**
- Transactions feature migrated
- Old payment code removed
- All tests passing
- Feature working correctly

**Phase 4 Verification:**
- `flutter analyze` passes
- `flutter test` passes
- Manual testing of transactions feature
- No old payment code remaining

---

### Phase 5: Dashboard Feature

**Objective:** Create dashboard feature

**Tasks:**

#### 5.1 Domain Layer
- Create dashboard summary entity
- Create repository interface
- Create use cases

**Files to Create:**
```
lib/features/dashboard/domain/entities/dashboard_summary.dart
lib/features/dashboard/domain/repositories/dashboard_repository.dart
lib/features/dashboard/domain/usecases/get_dashboard_summary.dart
lib/features/dashboard/domain/usecases/get_recent_transactions.dart
test/features/dashboard/domain/usecases/get_dashboard_summary_test.dart
```

**Verification:**
- Domain layer compiles
- Tests pass
- flutter analyze passes

#### 5.2 Data Layer
- Create data source
- Create models
- Create mappers
- Implement repository

**Files to Create:**
```
lib/features/dashboard/data/datasources/dashboard_local_datasource.dart
lib/features/dashboard/data/models/dashboard_summary_model.dart
lib/features/dashboard/data/mappers/dashboard_summary_mapper.dart
lib/features/dashboard/data/repositories/dashboard_repository_impl.dart
test/features/dashboard/data/repositories/dashboard_repository_impl_test.dart
```

**Verification:**
- Data layer compiles
- Tests pass
- flutter analyze passes

#### 5.3 Presentation Layer
- Create dashboard page
- Create widgets
- Create provider

**Files to Create:**
```
lib/features/dashboard/presentation/pages/dashboard_page.dart
lib/features/dashboard/presentation/widgets/summary_card.dart
lib/features/dashboard/presentation/widgets/recent_transactions_widget.dart
lib/features/dashboard/presentation/widgets/quick_actions_widget.dart
lib/features/dashboard/presentation/providers/dashboard_provider.dart
test/features/dashboard/presentation/providers/dashboard_provider_test.dart
test/features/dashboard/presentation/widgets/summary_card_test.dart
```

**Verification:**
- Presentation layer compiles
- Dashboard renders
- flutter analyze passes

#### 5.4 Integration
- Wire up DI
- Update routing
- Set as home page

**Files to Modify:**
```
lib/app/dependency_injection.dart (register dashboard dependencies)
lib/core/navigation/app_router.dart (set dashboard as home)
```

**Verification:**
- Dashboard loads on app start
- Summary displays correctly
- flutter analyze passes

**Phase 5 Deliverables:**
- Dashboard feature complete
- Home page updated
- All tests passing

**Phase 5 Verification:**
- `flutter analyze` passes
- `flutter test` passes
- Dashboard displays correctly
- Navigation works

---

### Phase 6: Placeholder Features

**Objective:** Create placeholder features for future development

**Tasks:**

For each placeholder feature (accounts, categories, budgets, reports, settings, attachments, search, sync, notifications, backup, export):

1. Create folder structure
2. Create README.md with feature description
3. Create placeholder Dart files with TODOs
4. Create placeholder test files

**Files to Create:**
```
lib/features/accounts/README.md
lib/features/accounts/domain/entities/account.dart
lib/features/accounts/domain/repositories/account_repository.dart
lib/features/accounts/domain/usecases/get_accounts.dart
lib/features/accounts/data/datasources/account_local_datasource.dart
lib/features/accounts/data/models/account_model.dart
lib/features/accounts/data/repositories/account_repository_impl.dart
lib/features/accounts/presentation/pages/accounts_list_page.dart
lib/features/accounts/presentation/providers/account_provider.dart
test/features/accounts/domain/usecases/get_accounts_test.dart

[Repeat for each placeholder feature]
```

**Verification:**
- All placeholder files compile
- README files are complete
- flutter analyze passes

**Phase 6 Deliverables:**
- All placeholder features created
- README files complete
- Project compiles

**Phase 6 Verification:**
- `flutter analyze` passes
- All placeholder files compile
- README files reviewed

---

### Phase 7: Cleanup and Finalization

**Objective:** Clean up old code and finalize

**Tasks:**

#### 7.1 Remove Old Code
- Delete old `lib/data/` folder (except what's moved)
- Delete old `lib/src/` folder (except what's moved)
- Delete unused files
- Clean up imports

**Files to Delete:**
```
lib/data/blocs/
lib/data/constants/
lib/data/models/
lib/data/repositories/
lib/src/widgets/
lib/src/views/
```

**Verification:**
- Project builds
- No broken imports
- flutter analyze passes

#### 7.2 Update Documentation
- Update README.md
- Create ARCHITECTURE.md
- Create CONTRIBUTING.md
- Update CHANGELOG.md

**Files to Create:**
```
ARCHITECTURE.md
CONTRIBUTING.md
```

**Files to Modify:**
```
README.md
CHANGELOG.md
```

**Verification:**
- Documentation is accurate
- Links work
- flutter analyze passes

#### 7.3 Final Testing
- Run full test suite
- Manual testing of all features
- Performance testing
- Lint check

**Commands:**
```bash
flutter analyze
flutter test
flutter test --integration
flutter build apk
flutter build windows
```

**Verification:**
- All tests pass
- No lint warnings
- Builds succeed
- Manual testing passes

**Phase 7 Deliverables:**
- Clean codebase
- Complete documentation
- All tests passing
- Builds successful

**Phase 7 Verification:**
- `flutter analyze` passes with zero warnings
- `flutter test` passes with 100% coverage (where possible)
- Manual testing checklist complete
- All builds successful

---

## Migration Tracking

### File Migration Log

| Original Path | New Path | Status | Phase |
|--------------|----------|--------|-------|
| lib/data/database/database.dart | lib/core/database/database.dart | Pending | 1.2 |
| lib/data/blocs/payment_bloc.dart | (deleted) | Pending | 4.4 |
| lib/src/views/home_view.dart | lib/features/transactions/presentation/pages/transactions_list_page.dart | Pending | 4.3 |
| [Add all files] | | | |

### Feature Migration Status

| Feature | Domain | Data | Presentation | Tests | Status |
|---------|--------|------|--------------|-------|--------|
| Transactions | Pending | Pending | Pending | Pending | Phase 4 |
| Dashboard | Pending | Pending | Pending | Pending | Phase 5 |
| Accounts | Placeholder | Placeholder | Placeholder | Placeholder | Phase 6 |
| Categories | Placeholder | Placeholder | Placeholder | Placeholder | Phase 6 |
| Budgets | Placeholder | Placeholder | Placeholder | Placeholder | Phase 6 |
| Reports | Placeholder | Placeholder | Placeholder | Placeholder | Phase 6 |
| Settings | Placeholder | Placeholder | Placeholder | Placeholder | Phase 6 |
| Attachments | Placeholder | Placeholder | Placeholder | Placeholder | Phase 6 |
| Search | Placeholder | Placeholder | Placeholder | Placeholder | Phase 6 |
| Sync | Placeholder | Placeholder | Placeholder | Placeholder | Phase 6 |
| Notifications | Placeholder | Placeholder | Placeholder | Placeholder | Phase 6 |
| Backup | Placeholder | Placeholder | Placeholder | Placeholder | Phase 6 |
| Export | Placeholder | Placeholder | Placeholder | Placeholder | Phase 6 |

---

## Risk Mitigation

### Risks

1. **Breaking Changes:** Risk of breaking existing functionality
   - **Mitigation:** Incremental migration, continuous testing

2. **Import Errors:** Risk of broken imports during migration
   - **Mitigation:** Update imports immediately after file moves

3. **Data Loss:** Risk of database schema changes causing data loss
   - **Mitigation:** Test migrations thoroughly, backup database

4. **Time Overrun:** Risk of migration taking longer than expected
   - **Mitigation:** Detailed planning, regular checkpoints

5. **Test Coverage:** Risk of insufficient test coverage
   - **Mitigation:** Write tests before refactoring

### Rollback Strategy

If a phase fails:
1. Revert to last known good commit
2. Analyze failure
3. Fix issue
4. Retry phase

---

## Success Criteria

### Phase Completion Criteria

Each phase is complete when:
- All tasks in phase are done
- All tests pass
- `flutter analyze` passes with no warnings
- App builds successfully
- Manual verification of affected features

### Overall Success Criteria

Migration is successful when:
- All phases complete
- All features work as before
- Code follows Clean Architecture
- Test coverage > 80%
- Zero lint warnings
- Documentation complete
- Team trained on new architecture

---

## Timeline Estimate

- **Phase 0:** 0.5 days
- **Phase 1:** 3-4 days
- **Phase 2:** 1 day
- **Phase 3:** 1-2 days
- **Phase 4:** 3-4 days
- **Phase 5:** 2-3 days
- **Phase 6:** 1-2 days
- **Phase 7:** 1-2 days

**Total:** 12.5-18.5 days

---

## Next Steps

1. Review this migration strategy
2. Get approval from stakeholders
3. Begin Phase 0: Preparation
4. Execute phases sequentially
5. Continuous verification
6. Final documentation

---

## Notes

- This migration will be done incrementally
- Each phase must be verified before proceeding
- Old code is only deleted after new code is verified
- Tests should be written before refactoring
- Documentation should be updated continuously
- Regular checkpoints with team recommended
