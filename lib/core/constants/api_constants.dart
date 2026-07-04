import 'package:sportheroes_mobile/core/config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  /// Environment-aware base URL (includes `/api` suffix).
  static String get baseUrl => AppConfig.instance.baseUrl;

  // ── Auth (Firebase idToken exchange + profile) ──────────────────────────
  static const String authLogin = '/v1/auth/login';
  static const String authMe = '/v1/auth/me';
  static const String authProfile = '/v1/auth/profile';
  static const String authLogout = '/v1/auth/logout';

  // ── HTTP Status Codes ───────────────────────────────────────────────────
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
}
