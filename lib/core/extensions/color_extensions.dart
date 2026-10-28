import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Darkens the color by blending it with black.
  /// [percent] must be between 0.0 and 1.0.
  Color darken(double percent) {
    assert(percent >= 0.0 && percent <= 1.0, 'Percent must be between 0 and 1');
    return Color.lerp(this, Colors.black, percent)!;
  }

  /// Lightens the color by blending it with white.
  /// [percent] must be between 0.0 and 1.0.
  Color lighten(double percent) {
    assert(percent >= 0.0 && percent <= 1.0, 'Percent must be between 0 and 1');
    return Color.lerp(this, Colors.white, percent)!;
  }
}
