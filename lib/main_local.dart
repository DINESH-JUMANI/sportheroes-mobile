import 'package:sportheroes_mobile/core/config/app_config.dart';
import 'package:sportheroes_mobile/main.dart' as app;

/// Local development entrypoint.
///
/// ```sh
/// flutter run -t lib/main_local.dart
/// ```
Future<void> main() => app.startApp(env: Environment.local);
