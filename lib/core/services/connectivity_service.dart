import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  // Private constructor
  ConnectivityService._() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  static ConnectivityService? _instance;
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// Get singleton instance
  static ConnectivityService get instance {
    if (_instance == null) {
      throw Exception(
        'ConnectivityService not initialized. Call ConnectivityService.init() first.',
      );
    }
    return _instance!;
  }

  /// Initialize the service (call this in main.dart)
  static Future<void> init() async {
    _instance = ConnectivityService._();
    await _instance!._initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      _isConnected = false;
      _connectionStatusController.add(false);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;

    // Check if any result indicates connection
    _isConnected = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    // Only emit if status changed
    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
    }
  }

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
