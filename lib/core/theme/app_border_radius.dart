import 'package:flutter/material.dart';

/// Application border radius constants.
class AppBorderRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double circle = 999.0;

  // Border radius objects
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(xxl));

  // Specific component border radii
  static const double buttonRadius = sm;
  static const double cardRadius = md;
  static const double dialogRadius = lg;
  static const double bottomSheetRadius = xl;
  static const double chipRadius = xxl;

  // BorderRadius objects for components
  static final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(buttonRadius),
  );

  static final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(cardRadius),
  );

  static final RoundedRectangleBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(dialogRadius),
  );

  static const RoundedRectangleBorder bottomSheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(bottomSheetRadius),
    ),
  );
}
