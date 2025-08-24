import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:trackpense/core/extensions/color_extension.dart';
import 'package:trackpense/data/constants/kjp_colors.dart';

/// Utility class for managing a loading indicator using Overlay.
class LoadingOverlay {
  static void show(
    OverlayState overlayState, {
    Duration showDuration = const Duration(seconds: 1),
  }) {
    _LoadingIndicatorHandler.instance.show(
      overlayState,
      showDuration: showDuration,
    );
  }

  static Future<void> dismiss() async => await _LoadingIndicatorHandler.instance.dismiss();
}

/// Singleton handler for the loading overlay.
class _LoadingIndicatorHandler {
  _LoadingIndicatorHandler._internal();

  static final _LoadingIndicatorHandler instance = _LoadingIndicatorHandler._internal();

  OverlayEntry? _overlayEntry;
  bool _isShowing = false;
  Completer? _showTimer;
  Timer? _timeoutTimer;

  /// Displays the loading indicator overlay.
  void show(
    OverlayState overlayState, {
    Duration timeout = const Duration(minutes: 5),
    Duration showDuration = const Duration(milliseconds: 500),
  }) {
    if (_isShowing) return;
    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(color: Colors.black.withValues(alpha: 0.5), dismissible: false),
          loading(null),
        ],
      ),
    );

    overlayState.insert(_overlayEntry!);

    _showTimer = Completer();
    Future.delayed(showDuration, () {
      _showTimer!.complete();
    });

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(timeout, () {
      if (_isShowing && _overlayEntry != null) {
        dismiss();
        throw 'Loading not removed after $timeout';
      }
    });
  }

  /// Dismisses the loading indicator overlay.
  Future<void> dismiss() async {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    if (_isShowing && _overlayEntry != null) {
      await _showTimer!.future;
      _showTimer = null;
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }
}

/// Returns the loading widget.
Widget loading([String? loadingMessage]) {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: 50,
          child: LoadingIndicator(
            indicatorType: Indicator.ballScaleMultiple,
            colors: [
              KjpColors.primary.lighten(0.5),
              KjpColors.primary,
              KjpColors.primary.darken(0.2),
              KjpColors.primary.darken(0.75),
            ],
          ),
        ),
        if (loadingMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              loadingMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: KjpColors.primary,
                fontSize: 24,
              ),
            ),
          ),
      ],
    ),
  );
}
