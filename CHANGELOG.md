## Unreleased
- Fixed the notes text field showing its character count twice
- Upgraded Flutter 3.44.5 -> 3.50.1
  - Migrated from deprecated `flutter/material.dart` imports to the `material_ui` package
  - Updated `drift_flutter` to 0.3.1 and refreshed Drift web database files
  - Fixed Android build issues (Gradle wrapper and plugin updates)
- Web debug launch now runs on fixed port 8080
- Added tests for notes text sanitization
- Added Dependabot for weekly pub, Gradle and GitHub Actions dependency updates (targeting `dev`)

## 2.1.0 
- Text in notes field will now be sanitized before being stored during create and update. Sanitization steps are as follows;
    1. All text will be split into 3 groups - 'pre-text', 'text', 'post-text'.
    2. 'pre-text' is all white space before the first non white space character. If this contains at least one `\n` character, this group will be reduced to a single `\n` character. Else this entire group will be discarded.
    3. 'text' is all text from the first non white space character up to the last non white character. This group will be preserved as-is.
    4. 'post-text' is all white space characters after the last non white space character. This group will be discarded regardless of what is contained.

# 2.0.0
- Major refactor to feature-based clean architecture
- Migrated codebase to clean architecture with feature-based organization
- Added project overview documentation for new developers and agents
- Updated README and archived AI planning docs
- Added build tool script to fetch Drift web database files
- Fixed Drift web files to match pinned versions
- Removed unused scaffolding from the refactor
- Bug fixes:
  - Restored form validation before saving transactions
  - Fixed transaction list to show newest first
  - Allow clearing notes when editing transactions
  - Moved UI side effects out of build on home screen
  - Fixed card date column overflowing at large text sizes 

<hr />

## 1.1.1
 - Debug and release build versions from local and GitHub will now use same keystore. Therefore do not need to uninstall current app in any case when switching between release builds

## 1.1.0
 - Income/Expense is now selected with a switch instead of radio buttons.
 - Date and time can now be set to any day within the last 7 days.
 - Improved styling on cards
 - Added new field to include any required notes
 - Cannot edit dateTime of entries older than 7 days