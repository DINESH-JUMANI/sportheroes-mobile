import 'dart:convert';

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
  static const String _keyUserJson = 'userJson';
  static const String _keyMatchScorerPrefix = 'match_scorer_';

  /// User id of whoever started / controls scoring for [matchId].
  String? getMatchScorer(String matchId) {
    if (matchId.isEmpty) return null;
    return _preferences?.getString('$_keyMatchScorerPrefix$matchId');
  }

  Future<bool> setMatchScorer(String matchId, String userId) async {
    if (matchId.isEmpty || userId.isEmpty) return false;
    return await _preferences?.setString(
          '$_keyMatchScorerPrefix$matchId',
          userId,
        ) ??
        false;
  }

  bool get isOnboarded => _preferences?.getBool(_keyIsOnboarded) ?? false;

  Future<bool> setOnboarded(bool value) async {
    return await _preferences?.setBool(_keyIsOnboarded, value) ?? false;
  }

  bool get isLoggedIn =>
      (_preferences?.getBool(_keyIsLoggedIn) ?? false) &&
      (userToken?.isNotEmpty ?? false);

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

  Map<String, dynamic>? get userJson {
    final raw = _preferences?.getString(_keyUserJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> setUserJson(Map<String, dynamic> user) async {
    return await _preferences?.setString(_keyUserJson, jsonEncode(user)) ??
        false;
  }

  Future<bool> removeUserJson() async {
    return await _preferences?.remove(_keyUserJson) ?? false;
  }

  Future<void> saveSession({
    required String accessToken,
    required Map<String, dynamic> user,
  }) async {
    await setUserToken(accessToken);
    await setUserJson(user);
    await setLoggedIn(true);
  }

  Future<void> clearSession() async {
    await removeUserToken();
    await removeUserJson();
    await setLoggedIn(false);
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
