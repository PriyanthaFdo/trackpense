import 'package:flutter/material.dart';

/// Application spacing constants.
class AppSpacing {
  // Base spacing unit
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Edge insets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);

  // Card spacing
  static const double cardPadding = md;
  static const double cardSpacing = sm;

  // List spacing
  static const double listItemSpacing = sm;
  static const double listSectionSpacing = lg;

  // Form spacing
  static const double formFieldSpacing = md;
  static const double formSectionSpacing = lg;

  // Button spacing
  static const double buttonSpacing = sm;
  static const double buttonGroupSpacing = md;

  // Screen padding
  static const double screenPadding = md;
  static const double screenPaddingLarge = lg;
}
