// lib/core/constants/api_constants.dart

class ApiConstants {
  // Microservice Base URLs (environment-aware)
  static const String baseUrl = 'https://api.sportheroes.com';

  // Authentication Endpoints
  static const String authLoginInit = '/auth/login/init';
  static const String authSetPassword = '/auth/set-password';
  static const String authLogin = '/auth/login';
  static const String authOtpVerify = '/auth/otp/verify';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authVerifyForgotOtp = '/auth/verify-forgot-otp';
  static const String authResetPassword = '/auth/reset-password';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authOtpResend = '/auth/otp/resend';
  static const String authMe = '/auth/me';
  static const String authMicrosoft = '/auth/microsoft/mobile';
  static const String authMicrosoftCallbackMobile =
      '/auth/microsoft/callback/mobile';

  // Language Endpoints
  static const String languages = '/languages';
  static String languageById(String value) => '/languages/$value';

  // Country Endpoints
  static const String countries = '/countries';
  static String countryById(String value) => '/countries/$value';

  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
}
