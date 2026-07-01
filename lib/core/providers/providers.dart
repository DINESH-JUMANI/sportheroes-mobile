// Core Providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportheroes_mobile/core/network/dio_client.dart';
import 'package:sportheroes_mobile/core/services/connectivity_service.dart';
import 'package:sportheroes_mobile/core/services/device_location_service.dart';
import 'package:sportheroes_mobile/core/services/local_storage_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

// Local Storage Service Provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

// DioClient Providers for different microservices
final userDioClientProvider = Provider<DioClient>((ref) {
  return DioClient.userInstance;
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});

final deviceLocationServiceProvider = Provider<DeviceLocationService>((ref) {
  return DeviceLocationService.instance;
});
