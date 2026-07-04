import 'package:sportheroes_mobile/core/config/app_config.dart';
import 'package:sportheroes_mobile/main.dart' as app;

/// Production entrypoint.
///
/// ```sh
/// flutter run -t lib/main_production.dart
/// ```
Future<void> main() => app.startApp(env: Environment.production);
