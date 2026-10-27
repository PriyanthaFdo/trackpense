import 'package:flutter/material.dart';

/// Application typography constants.
class AppTypography {
  // Font sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXXXL = 32.0;

  // Font weights
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;

  // Line heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightLoose = 1.8;

  /// Get text theme based on color scheme.
  static TextTheme getTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: fontSizeXXXL,
        fontWeight: fontWeightBold,
        letterSpacing: letterSpacingTight,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: fontSizeXXL,
        fontWeight: fontWeightBold,
        letterSpacing: letterSpacingTight,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: fontSizeXL,
        fontWeight: fontWeightSemiBold,
        letterSpacing: letterSpacingNormal,
        color: colorScheme.onSurface,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: fontSizeXXL,
        fontWeight: fontWeightSemiBold,
        letterSpacing: letterSpacingNormal,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: fontSizeXL,
        fontWeight: fontWeightSemiBold,
        letterSpacing: letterSpacingNormal,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: fontSizeLG,
        fontWeight: fontWeightMedium,
        letterSpacing: letterSpacingNormal,
        color: colorScheme.onSurface,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: fontSizeLG,
        fontWeight: fontWeightMedium,
        letterSpacing: letterSpacingNormal,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: fontSizeMD,
        fontWeight: fontWeightMedium,
        letterSpacing: letterSpacingNormal,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: fontSizeMD,
        fontWeight: fontWeightMedium,
        letterSpacing: letterSpacingWide,
        color: colorScheme.onSurface,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: fontSizeLG,
        fontWeight: fontWeightRegular,
        letterSpacing: letterSpacingNormal,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: fontSizeMD,
        fontWeight: fontWeightRegular,
        letterSpacing: letterSpacingNormal,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: fontSizeSM,
        fontWeight: fontWeightRegular,
        letterSpacing: letterSpacingNormal,
        color: colorScheme.onSurfaceVariant,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: fontSizeMD,
        fontWeight: fontWeightMedium,
        letterSpacing: letterSpacingNormal,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: fontSizeSM,
        fontWeight: fontWeightMedium,
        letterSpacing: letterSpacingWide,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: fontSizeXS,
        fontWeight: fontWeightMedium,
        letterSpacing: letterSpacingWide,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
