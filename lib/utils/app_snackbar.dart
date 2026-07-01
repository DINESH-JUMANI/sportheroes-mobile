import 'package:flutter/material.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  static void success(BuildContext context, String message) {
    _show(context, message: message, type: SnackbarType.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message: message, type: SnackbarType.error);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message: message, type: SnackbarType.warning);
  }

  static void info(BuildContext context, String message) {
    _show(context, message: message, type: SnackbarType.info);
  }

  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
  }) {
    _show(context, message: message, type: type);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
  }) {
    final color = _getColor(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  static Color _getColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Colors.green;
      case SnackbarType.error:
        return Colors.red;
      case SnackbarType.warning:
        return Colors.orange;
      case SnackbarType.info:
        return Colors.blue;
    }
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning;
      case SnackbarType.info:
        return Icons.info;
    }
  }
}
