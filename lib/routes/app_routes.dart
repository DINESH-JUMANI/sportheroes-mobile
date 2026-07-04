import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/features/auth/screens/complete_profile_screen.dart';
import 'package:sportheroes_mobile/features/auth/screens/otp_verification_screen.dart';
import 'package:sportheroes_mobile/features/auth/screens/phone_login_screen.dart';
import 'package:sportheroes_mobile/features/home/screens/home_shell_screen.dart';
import 'package:sportheroes_mobile/features/onboarding/screens/onboarding_screen.dart';
import 'package:sportheroes_mobile/features/splash/screens/splash_screen.dart';
import 'package:sportheroes_mobile/features/teams/screens/teams_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String completeProfile = '/complete-profile';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String teams = '/teams';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const PhoneLoginScreen(),
      otp: (context) => const OtpVerificationScreen(),
      completeProfile: (context) => const CompleteProfileScreen(),
      home: (context) => const HomeShellScreen(),
      teams: (context) => const TeamsScreen(),
    };
  }
}
