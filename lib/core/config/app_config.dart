enum Environment { development, production, local }

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
      case Environment.development:
        _instance = AppConfig(
          environment: Environment.development,
          appName: 'DC OP DEV',
          baseUrl: 'https://hr-api.dev.mydatacrate.com/api',
          debugMode: true,
          bundleId: 'com.mydatacrate.employeepassport.development',
        );
        break;

      case Environment.production:
        _instance = AppConfig(
          environment: Environment.production,
          appName: 'Crate-Employee Passport',
          baseUrl: 'https://hr-api.mydatacrate.com/api',
          debugMode: false,
          bundleId: 'com.mydatacrate.employeepassport',
        );
        break;
      case Environment.local:
        _instance = AppConfig(
          environment: Environment.local,
          appName: 'DC OP LOCAL',
          baseUrl: 'http://localhost:3002/api',
          debugMode: true,
          bundleId: 'com.mydatacrate.employeepassport.local',
        );
        break;
    }
  }

  bool get isLocal => environment == Environment.local;
  bool get isDevelopment => environment == Environment.development;
  bool get isProduction => environment == Environment.production;
}
