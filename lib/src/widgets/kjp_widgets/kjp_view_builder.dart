import 'package:flutter/material.dart';

class KjpViewBuilder extends StatelessWidget {
  const KjpViewBuilder({
    super.key,
    this.mobileView,
    this.desktopView,
  }) : assert(mobileView != null || desktopView != null, 'Both mobile and desktop views cannot be null');

  final Widget? mobileView;
  final Widget? desktopView;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallView = width < 600;

    if (mobileView != null && desktopView != null) {
      return isSmallView ? mobileView! : desktopView!;
    } else {
      return mobileView ?? desktopView!;
    }
  }
}
