import 'package:dio/dio.dart';

/// Shared helpers for parsing SportHeroes API envelopes.
class ApiHelpers {
  ApiHelpers._();

  static Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  /// Returns `body['data']` when present, otherwise the body itself.
  static Map<String, dynamic> extractData(dynamic responseData) {
    final body = asMap(responseData);
    if (body['data'] is Map) return asMap(body['data']);
    return body;
  }

  /// Prefer nested `data[key]`, then top-level `data` when it is the object.
  static Map<String, dynamic> extractObject(
    dynamic responseData, {
    required String key,
  }) {
    final data = extractData(responseData);
    if (data[key] is Map) return asMap(data[key]);
    // Some endpoints return the object directly under data.
    if (data.containsKey('id') || data.containsKey(key)) {
      return data;
    }
    return data;
  }

  static List<Map<String, dynamic>> extractList(
    dynamic responseData, {
    required String key,
  }) {
    final data = extractData(responseData);
    final raw = data[key];
    if (raw is! List) return const [];
    return raw.map((e) => asMap(e)).toList();
  }

  /// Top-level `message` from the unified API envelope.
  static String extractMessage(
    dynamic responseData, {
    String fallback = 'Success',
  }) {
    final body = asMap(responseData);
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    return fallback;
  }

  static bool isSuccess(dynamic responseData) {
    final body = asMap(responseData);
    final success = body['success'];
    if (success is bool) return success;
    return true;
  }

  static String extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }
      final error = data['error'];
      if (error is Map) {
        final details = error['details'];
        if (details is List && details.isNotEmpty) {
          final first = details.first;
          if (first is Map && first['message'] != null) {
            return first['message'].toString();
          }
        }
        final code = error['code'];
        if (code is String && code.isNotEmpty) return code;
      }
      if (error is String && error.isNotEmpty) return error;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Request timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect. Check your network.';
    }
    return e.message ?? 'Something went wrong. Please try again.';
  }

  static String cleanError(Object e) {
    final text = e.toString();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }
    return text;
  }
}
