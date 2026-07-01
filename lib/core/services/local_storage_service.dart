import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  static LocalStorageService get instance {
    if (_instance == null) {
      throw Exception(
        'LocalStorageService not initialized. Call LocalStorageService.init() first.',
      );
    }
    return _instance!;
  }

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    _instance = LocalStorageService._();
  }

  static const String _keyIsOnboarded = 'isOnboarded';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserToken = 'userToken';
  static const String _keyUserEmail = 'userEmail';

  bool get isOnboarded => _preferences?.getBool(_keyIsOnboarded) ?? false;

  Future<bool> setOnboarded(bool value) async {
    return await _preferences?.setBool(_keyIsOnboarded, value) ?? false;
  }

  bool get isLoggedIn => _preferences?.getBool(_keyIsLoggedIn) ?? false;

  Future<bool> setLoggedIn(bool value) async {
    return await _preferences?.setBool(_keyIsLoggedIn, value) ?? false;
  }

  String? get userToken => _preferences?.getString(_keyUserToken);

  Future<bool> setUserToken(String token) async {
    return await _preferences?.setString(_keyUserToken, token) ?? false;
  }

  Future<bool> removeUserToken() async {
    return await _preferences?.remove(_keyUserToken) ?? false;
  }

  String? get userEmail => _preferences?.getString(_keyUserEmail);

  Future<bool> setUserEmail(String email) async {
    return await _preferences?.setString(_keyUserEmail, email) ?? false;
  }

  Future<bool> clearAll() async {
    return await _preferences?.clear() ?? false;
  }

  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }

  Set<String> getAllKeys() {
    return _preferences?.getKeys() ?? {};
  }
}
