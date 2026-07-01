import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sportheroes_mobile/core/models/device_location_data.dart';
import 'package:sportheroes_mobile/utils/app_logger.dart';

/// Reason a GPS location could not be obtained, used to drive UI prompts.
enum LocationAvailabilityStatus {
  /// Service enabled and permission granted.
  available,

  /// Device location services (GPS) are turned off.
  serviceDisabled,

  /// Runtime location permission has not been granted yet (can be requested).
  permissionDenied,

  /// Permission permanently denied — must be enabled from app settings.
  permissionDeniedForever,
}

class DeviceLocationService {
  DeviceLocationService._();

  static DeviceLocationService? _instance;
  String? _cachedDeviceInfo;

  /// Get singleton instance
  static DeviceLocationService get instance {
    if (_instance == null) {
      throw Exception(
        'DeviceLocationService not initialized. Call DeviceLocationService.init() first.',
      );
    }
    return _instance!;
  }

  /// Initialize the service and cache device info
  static Future<void> init() async {
    _instance = DeviceLocationService._();
    await _instance!._loadDeviceInfo();
  }

  /// Load and cache device info (model, OS, manufacturer)
  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfoPlugin.androidInfo;
        _cachedDeviceInfo =
            '${info.manufacturer} ${info.model} (Android ${info.version.release})';
      } else if (Platform.isIOS) {
        final info = await deviceInfoPlugin.iosInfo;
        _cachedDeviceInfo =
            '${info.name} ${info.model} (iOS ${info.systemVersion})';
      }
      AppLogger.info('Device info cached: $_cachedDeviceInfo');
    } catch (e) {
      AppLogger.error('Failed to load device info: $e');
      _cachedDeviceInfo = 'Unknown device';
    }
  }

  /// Check if device GPS / location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Open device location / GPS settings
  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  /// Open the OS app-settings page for this app (used when permission is
  /// permanently denied and the user must grant it manually).
  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  /// Check and request location permission. Returns true if granted.
  Future<bool> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      try {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 5),
        );
      } on TimeoutException {
        AppLogger.warning('Geolocator.requestPermission timed out after 5s');
        return false;
      }
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Inspect the current state of the device's location service and runtime
  /// permission without showing any UI. When [requestPermissionIfDenied] is
  /// `true`, a permission denied result will trigger the system permission
  /// dialog before returning.
  Future<LocationAvailabilityStatus> checkAvailability({
    bool requestPermissionIfDenied = false,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAvailabilityStatus.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermissionIfDenied) {
      try {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 5),
        );
      } on TimeoutException {
        AppLogger.warning(
          'Geolocator.requestPermission timed out after 5s in checkAvailability',
        );
        return LocationAvailabilityStatus.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationAvailabilityStatus.permissionDeniedForever;
    }
    if (permission == LocationPermission.denied) {
      return LocationAvailabilityStatus.permissionDenied;
    }
    return LocationAvailabilityStatus.available;
  }

  /// Collect GPS position, reverse-geocoded address, and device info.
  /// Never throws — returns partial data on failure.
  Future<DeviceLocationData> collectData() async {
    double? latitude;
    double? longitude;
    double? accuracy;
    String? address;

    try {
      final hasPermission = await ensurePermission();
      if (!hasPermission) {
        AppLogger.warning('Location permission not granted');
        return DeviceLocationData(deviceInfo: _cachedDeviceInfo);
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.warning('Location services are disabled');
        return DeviceLocationData(deviceInfo: _cachedDeviceInfo);
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            // First-fix can take longer than 10s after GPS was just turned on.
            timeLimit: Duration(seconds: 20),
          ),
        );
        latitude = position.latitude;
        longitude = position.longitude;
        accuracy = position.accuracy;

        AppLogger.info(
          'GPS position acquired: $latitude, $longitude (accuracy: $accuracy)',
        );
      } catch (e) {
        AppLogger.warning('getCurrentPosition failed, will try last known: $e');
      }

      // Fallback: if we couldn't get a fresh fix (cold start, slow GPS, etc.)
      // accept the most recent cached position so the user can still submit.
      if (latitude == null) {
        try {
          final last = await Geolocator.getLastKnownPosition();
          if (last != null) {
            latitude = last.latitude;
            longitude = last.longitude;
            accuracy = last.accuracy;
            AppLogger.info('Using last known position: $latitude, $longitude');
          }
        } catch (e) {
          AppLogger.warning('getLastKnownPosition failed: $e');
        }
      }
    } catch (e) {
      AppLogger.error('Failed to get GPS position: $e');
    }

    // Reverse geocode
    if (latitude != null && longitude != null) {
      try {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
            p.postalCode,
            p.country,
          ].where((s) => s != null && s.isNotEmpty);
          address = parts.join(', ');
        }
      } catch (e) {
        AppLogger.error('Reverse geocoding failed: $e');
      }
    }

    return DeviceLocationData(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      address: address,
      deviceInfo: _cachedDeviceInfo,
    );
  }
}
