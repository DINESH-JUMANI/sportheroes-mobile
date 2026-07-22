import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/app.dart';
import 'package:sportheroes_mobile/core/config/app_config.dart';
import 'package:sportheroes_mobile/core/services/connectivity_service.dart';
import 'package:sportheroes_mobile/core/services/device_location_service.dart';
import 'package:sportheroes_mobile/core/services/local_storage_service.dart';
import 'package:sportheroes_mobile/utils/app_logger.dart';

/// Default entrypoint (`flutter run`) — production API.
/// Prefer `lib/main_local.dart` or `lib/main_production.dart` for an explicit env.
Future<void> main() => startApp(env: Environment.production);

/// Shared app bootstrap used by all entrypoints.
Future<void> startApp({required Environment env}) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.initialize(env);

  assert(() {
    debugPrint(
      'ENVIRONMENT: ${AppConfig.instance.environment.name.toUpperCase()}',
    );
    debugPrint('API: ${AppConfig.instance.baseUrl}');
    return true;
  }());

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  LoggerUtils.configureForEnvironment();
  LoggerUtils.initialize();
  LoggerUtils.logAppStart();

  await LocalStorageService.init();

  runApp(const ProviderScope(child: MyApp()));
  _initNonCriticalServices();
}

void _initNonCriticalServices() {
  unawaited(
    _initSafe(
      'ConnectivityService',
      () => ConnectivityService.init().timeout(const Duration(seconds: 5)),
    ),
  );
  unawaited(
    _initSafe(
      'DeviceLocationService',
      () => DeviceLocationService.init().timeout(const Duration(seconds: 5)),
    ),
  );
}

Future<void> _initSafe(String name, Future<void> Function() init) async {
  try {
    await init();
  } on TimeoutException {
    AppLogger.warning('$name init timed out — skipping');
  } catch (e) {
    AppLogger.error('$name init failed: $e');
  }
}
