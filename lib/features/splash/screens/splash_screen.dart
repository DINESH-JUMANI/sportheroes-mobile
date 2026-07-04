import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/core/services/device_location_service.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/app_logger.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    AppLogger.info('Splash screen initializing...');

    await _requestLocationPermission();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final storage = ref.read(localStorageServiceProvider);
    final isOnboarded = storage.isOnboarded;
    final auth = ref.read(authProvider);

    AppLogger.debug(
      'Splash checks - isOnboarded: $isOnboarded, step: ${auth.step}',
    );

    if (!isOnboarded) {
      AppLogger.info('First-time user, navigating to onboarding');
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    if (auth.step == AuthStep.profile) {
      Navigator.pushReplacementNamed(context, AppRoutes.completeProfile);
      return;
    }

    if (auth.step == AuthStep.authenticated && storage.isLoggedIn) {
      AppLogger.info('Session found, navigating to Home');
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    AppLogger.info('Navigating to login');
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Future<void> _requestLocationPermission() async {
    try {
      final service = DeviceLocationService.instance;
      await service.ensurePermission().timeout(const Duration(seconds: 5));
    } on TimeoutException {
      AppLogger.warning(
        'Location permission request timed out after 5s — proceeding',
      );
    } catch (e) {
      AppLogger.error('Location permission request failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_tennis, size: 64, color: AppColors.white),
            SizedBox(height: 16),
            Text(
              'SportHeroes',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
