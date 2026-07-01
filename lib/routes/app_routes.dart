import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/features/splash/screens/splash_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String home = '/home';

  // Route generator

  // Static routes map for named routing
  static Map<String, WidgetBuilder> get routes {
    return {splash: (context) => const SplashScreen()};
  }
}
