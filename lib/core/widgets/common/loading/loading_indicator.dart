import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:trackpense/core/theme/app_colors.dart';

/// A reusable loading indicator widget.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 50,
    this.colors,
  });

  final double size;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: LoadingIndicator(
        indicatorType: Indicator.ballScaleMultiple,
        colors: colors ??
            [
              AppColors.primaryLight,
              AppColors.primary,
              AppColors.primaryDark,
            ],
      ),
    );
  }
}
