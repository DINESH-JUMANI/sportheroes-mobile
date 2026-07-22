import 'package:sportheroes_mobile/app.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';

/// Root-level navigation helpers (bypasses nested tab navigators).
class AppNavigator {
  AppNavigator._();

  static void resetToLogin() {
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
  }
}
