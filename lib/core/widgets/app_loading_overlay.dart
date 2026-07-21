import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/app_logo_loader.dart';

/// Full-screen blurred overlay with rotating logo. Use via [AppLoader].
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: AppColors.black.withValues(alpha: 0.28),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AppLogoLoader(
                size: 64,
                message: message ?? 'Please wait…',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Global imperative loader: blur background + rotating logo.
class AppLoader {
  AppLoader._();

  static OverlayEntry? _entry;

  static bool get isShowing => _entry != null;

  static void show(BuildContext context, {String? message}) {
    if (_entry != null) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (_) => AppLoadingOverlay(message: message),
    );
    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }

  /// Shows loader while [action] runs, then hides it.
  static Future<T> during<T>(
    BuildContext context,
    Future<T> Function() action, {
    String? message,
  }) async {
    show(context, message: message);
    try {
      return await action();
    } finally {
      hide();
    }
  }
}

/// Wraps a screen and shows blur+logo when [isLoading] is true.
class AppLoadingBarrier extends StatelessWidget {
  const AppLoadingBarrier({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AppLoadingOverlay(message: message),
          ),
      ],
    );
  }
}
