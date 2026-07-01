import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/core/services/device_location_service.dart';
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

    // Request location permission (not mandatory - if denied, we skip)
    await _requestLocationPermission();

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final storage = ref.read(localStorageServiceProvider);
    final isOnboarded = storage.isOnboarded;
    final isLoggedIn = storage.isLoggedIn;

    AppLogger.debug('Splash checks - isOnboarded: $isOnboarded, ');

    if (!isOnboarded) {
      await storage.setOnboarded(true);
      AppLogger.info('First-time user, navigating to onboarding');
      AppLogger.navigation('Splash Screen', 'Onboarding Screen');
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
      return;
    }

    if (!isLoggedIn) {
      AppLogger.info('User has completed onboarding, navigating to login');
      AppLogger.navigation('Splash Screen', 'Login Screen');
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    AppLogger.info('Session integrity validated, navigating to Dashboard');
    AppLogger.navigation('Splash Screen', 'Dashboard Screen');
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  /// Requests location permission at app startup. Not mandatory —
  /// if the user denies, we simply skip GPS collection later.
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF2D31A6),
        body: SizedBox.expand(
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                height: screenHeight * .60,
                width: screenWidth,
                child: const Center(child: Text('Sport Heroes')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
