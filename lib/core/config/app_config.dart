enum Environment { production, local }

class AppConfig {
  AppConfig({
    required this.environment,
    required this.appName,
    required this.baseUrl,
    required this.debugMode,
    required this.bundleId,
  });
  final Environment environment;
  final String appName;
  final String baseUrl;
  final bool debugMode;
  final String bundleId;

  static AppConfig? _instance;
  static AppConfig get instance {
    if (_instance == null) {
      throw Exception(
        'AppConfig not initialized. Call AppConfig.initialize() first..',
      );
    }
    return _instance!;
  }

  static void initialize(Environment environment) {
    switch (environment) {
      case Environment.production:
        _instance = AppConfig(
          environment: Environment.production,
          appName: 'Sport Heroes',
          baseUrl: 'https://sport-heroes-api.mydatacrate.com/api',
          debugMode: false,
          bundleId: 'com.sportheroes.app',
        );
        break;
      case Environment.local:
        _instance = AppConfig(
          environment: Environment.local,
          appName: 'Sport Heroes Local',
          baseUrl: 'http://localhost:3000/api',
          debugMode: true,
          bundleId: 'com.sportheroes.app.local',
        );
        break;
    }
  }

  bool get isLocal => environment == Environment.local;
  bool get isProduction => environment == Environment.production;
}
