import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, critical }

class AppLogger {
  static bool _isEnabled = true;
  static LogLevel _minimumLevel = LogLevel.debug;

  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  static void setLogLevel(LogLevel level) {
    _minimumLevel = level;
  }

  static bool _shouldLog(LogLevel level) {
    return _isEnabled && level.index >= _minimumLevel.index;
  }

  static String _formatMessage(
    LogLevel level,
    String message, [
    dynamic error,
  ]) {
    final timestamp = DateTime.now().toIso8601String();
    final emoji = _getEmoji(level);
    final levelName = level.name.toUpperCase();

    final buffer = StringBuffer();
    buffer.write('$emoji [$levelName] $timestamp - $message');

    if (error != null) {
      buffer.write('\n  Error: $error');
    }

    return buffer.toString();
  }

  static String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '💥';
    }
  }

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog(LogLevel.debug)) return;

    final formattedMessage = _formatMessage(LogLevel.debug, message, error);
    dev.log(
      formattedMessage,
      name: 'AppLogger',

      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      debugPrint(formattedMessage);
    }
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog(LogLevel.info)) return;

    final formattedMessage = _formatMessage(LogLevel.info, message, error);
    dev.log(
      formattedMessage,
      name: 'AppLogger',

      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      debugPrint(formattedMessage);
    }
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog(LogLevel.warning)) return;

    final formattedMessage = _formatMessage(LogLevel.warning, message, error);
    dev.log(
      formattedMessage,
      name: 'AppLogger',

      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      debugPrint(formattedMessage);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog(LogLevel.error)) return;

    final formattedMessage = _formatMessage(LogLevel.error, message, error);
    dev.log(
      formattedMessage,
      name: 'AppLogger',

      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      debugPrint(formattedMessage);
      if (stackTrace != null) {
        debugPrint('Stack Trace:\n$stackTrace');
      }
    }
  }

  static void critical(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (!_shouldLog(LogLevel.critical)) return;

    final formattedMessage = _formatMessage(LogLevel.critical, message, error);
    dev.log(
      formattedMessage,
      name: 'AppLogger',

      error: error,
      stackTrace: stackTrace,
    );

    debugPrint(formattedMessage);
    if (stackTrace != null) {
      debugPrint('Stack Trace:\n$stackTrace');
    }
  }

  static void networkRequest(
    String url,
    String method, {
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    final requestInfo = {
      'url': url,
      'method': method,
      'headers': headers,
      'body': body,
    };
    debug('🌐 Network Request', requestInfo);
  }

  static void networkResponse(
    String url,
    int statusCode, {
    dynamic data,
    Duration? duration,
  }) {
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final responseInfo = {
      'url': url,
      'statusCode': statusCode,
      'data': data,
      'duration_ms': duration?.inMilliseconds,
    };

    if (isSuccess) {
      debug('✅ Network Success', responseInfo);
    } else {
      warning('❌ Network Error', responseInfo);
    }
  }

  static void themeChange(String from, String to) {
    info('🎨 Theme Changed: $from → $to');
  }

  static void userAction(String action, {Map<String, dynamic>? metadata}) {
    final actionInfo = {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      ...?metadata,
    };
    info('👤 User Action', actionInfo);
  }

  static void navigation(String from, String to) {
    debug('🧭 Navigation: $from → $to');
  }

  static void performance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    final isSlowOperation = duration.inMilliseconds > 1000;
    final performanceInfo = {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      ...?metadata,
    };

    if (isSlowOperation) {
      warning('🐌 Slow Performance', performanceInfo);
    } else {
      debug('⚡ Performance', performanceInfo);
    }
  }

  static void appLifecycle(String event) {
    info('🔄 App Lifecycle: $event');
  }
}

extension LoggingExtension on Object {
  void logDebug([String? message]) {
    if (kDebugMode) {
      AppLogger.debug('$runtimeType: ${message ?? toString()}');
    }
  }

  void logInfo([String? message]) {
    if (kDebugMode) {
      AppLogger.info('$runtimeType: ${message ?? toString()}');
    }
  }

  void logError([String? message, dynamic error, StackTrace? stackTrace]) {
    AppLogger.error(
      '$runtimeType: ${message ?? toString()}',
      error,
      stackTrace,
    );
  }
}

class LoggerUtils {
  static void initialize() {
    AppLogger.info('🚀 App Logger Initialized');
  }

  static void logAppStart() {
    AppLogger.appLifecycle('App Started');
  }

  static void logAppPause() {
    AppLogger.appLifecycle('App Paused');
  }

  static void logAppResume() {
    AppLogger.appLifecycle('App Resumed');
  }

  static void logAppDetached() {
    AppLogger.appLifecycle('App Detached');
  }

  static void configureForEnvironment() {
    if (kReleaseMode) {
      AppLogger.setLogLevel(LogLevel.error);
    } else if (kProfileMode) {
      AppLogger.setLogLevel(LogLevel.warning);
    } else {
      AppLogger.setLogLevel(LogLevel.debug);
    }
  }

  static void logAppTerminate() {
    AppLogger.appLifecycle('App Terminated');
  }

  static void logMemoryUsage() {
    AppLogger.info('📊 Memory Usage Check');
  }

  static void logDeviceInfo(Map<String, dynamic> deviceInfo) {
    AppLogger.info('📱 Device Info', deviceInfo);
  }

  static void logFeatureUsage(
    String feature, {
    Map<String, dynamic>? metadata,
  }) {
    AppLogger.userAction('Feature Used: $feature', metadata: metadata);
  }

  static void logErrorWithContext(
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    AppLogger.error('Error in $operation', error, stackTrace);
  }
}
