import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sportheroes_mobile/core/constants/api_constants.dart';
import 'package:sportheroes_mobile/core/services/local_storage_service.dart';
import 'package:sportheroes_mobile/utils/app_logger.dart';

class DioClient {
  DioClient._internal(String baseUrl) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    AppLogger.info('DioClient initialized with base URL: $baseUrl');
    _setupInterceptors();
  }

  late Dio _dio;

  static DioClient? _instance;

  static DioClient get instance {
    _instance ??= DioClient._internal(ApiConstants.baseUrl);
    return _instance!;
  }

  /// Call after [AppConfig.initialize] if the environment may change.
  static void reset() {
    _instance = null;
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          try {
            final token = LocalStorageService.instance.userToken;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {
            // LocalStorage may not be ready during early init.
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.data is FormData) {
              final fields = (options.data as FormData).fields
                  .map((e) => '${e.key}: ${e.value}')
                  .join(', ');
              AppLogger.info(
                'REQUEST[${options.method}] => PATH: ${options.path}\n'
                'FormData fields: {$fields}\n'
                '(file data omitted)',
              );
            }
            handler.next(options);
          },
          onResponse: (response, handler) {
            if (response.requestOptions.responseType == ResponseType.bytes ||
                response.data is List<int>) {
              final size = response.data is List
                  ? (response.data as List).length
                  : 0;
              AppLogger.info(
                'RESPONSE[${response.statusCode}] => '
                'PATH: ${response.requestOptions.path}\n'
                '(binary data: $size bytes omitted)',
              );
            }
            handler.next(response);
          },
        ),
      );
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          filter: (options, args) {
            if (!args.isResponse && options.data is FormData) return false;
            if (args.isResponse &&
                (options.responseType == ResponseType.bytes ||
                    args.data is List<int>)) {
              return false;
            }
            return true;
          },
        ),
      );
    }
  }
}
