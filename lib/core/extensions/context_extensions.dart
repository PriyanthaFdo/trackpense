import 'package:flutter/material.dart';

/// Extensions on [BuildContext] for common operations.
extension ContextExtensions on BuildContext {
  /// Gets the theme data.
  ThemeData get theme => Theme.of(this);

  /// Gets the text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Gets the color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Gets the media query data.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Gets the screen size.
  Size get screenSize => mediaQuery.size;

  /// Gets the screen width.
  double get screenWidth => screenSize.width;

  /// Gets the screen height.
  double get screenHeight => screenSize.height;

  /// Checks if the screen is mobile size.
  bool get isMobile => screenWidth < 600;

  /// Checks if the screen is tablet size.
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// Checks if the screen is desktop size.
  bool get isDesktop => screenWidth >= 900;

  /// Gets the safe area padding.
  EdgeInsets get safePadding => mediaQuery.padding;

  /// Gets the safe area bottom padding.
  double get safeBottom => safePadding.bottom;

  /// Gets the safe area top padding.
  double get safeTop => safePadding.top;

  /// Shows a snackbar.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: duration,
      action: action,
    );
    return ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  /// Hides the keyboard.
  void hideKeyboard() {
    final currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  /// Shows a dialog.
  Future<T?> showDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      builder: builder,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Shows a bottom sheet.
  Future<T?> showBottomSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      builder: builder,
      isScrollControlled: isScrollControlled,
    );
  }

  /// Navigates to a named route.
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Pops the current route.
  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }
}
