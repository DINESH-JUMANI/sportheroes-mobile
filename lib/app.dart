import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/services/theme_service.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  /// Global navigator key for navigation from anywhere
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.themeModeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              // Theme configuration
              theme: ThemeService.lightTheme,
              darkTheme: ThemeService.darkTheme,
              themeMode: themeMode,

              initialRoute: AppRoutes.splash,
              routes: AppRoutes.routes,
              onGenerateRoute: AppRoutes.onGenerateRoute,
            );
          },
        );
      },
    );
  }
}
