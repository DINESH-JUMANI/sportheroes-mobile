import 'package:dio/dio.dart';
import 'package:sportheroes_mobile/core/constants/api_constants.dart';
import 'package:sportheroes_mobile/core/models/api_result.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/network/dio_client.dart';
import 'package:sportheroes_mobile/features/auth/models/login_response.dart';
import 'package:sportheroes_mobile/features/auth/models/user_model.dart';
import 'package:sportheroes_mobile/utils/app_logger.dart';

class AuthService {
  AuthService(this._dioClient);

  final DioClient _dioClient;

  Dio get _dio => _dioClient.dio;

  /// Exchanges Firebase [idToken] for our app JWT.
  Future<LoginResponse> loginWithIdToken(String idToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.authLogin,
        data: {'idToken': idToken},
      );

      final body = response.data as Map<String, dynamic>;
      final data = Map<String, dynamic>.from(body['data'] as Map? ?? body);
      return LoginResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.authMe);
      return UserModel.fromJson(_extractUserPayload(response.data));
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  /// Returns `false` when the server rejects the JWT (401/403).
  Future<bool> validateAccessToken() async {
    try {
      await _dio.get(ApiConstants.playerProfilesMe);
      return true;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) return false;
      rethrow;
    }
  }

  Future<ApiResult<UserModel>> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _dio.patch(
        ApiConstants.authProfile,
        data: request.toJson(),
      );
      return ApiResult(
        data: UserModel.fromJson(_extractUserPayload(response.data)),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Profile updated',
        ),
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  /// Supports both `{ data: { user: {...} } }` and `{ data: {...user fields} }`.
  Map<String, dynamic> _extractUserPayload(dynamic responseData) {
    final body = Map<String, dynamic>.from(responseData as Map? ?? {});
    final data = Map<String, dynamic>.from(body['data'] as Map? ?? body);
    if (data['user'] is Map) {
      return Map<String, dynamic>.from(data['user'] as Map);
    }
    return data;
  }

  Future<String> logout() async {
    try {
      final response = await _dio.post(ApiConstants.authLogout);
      return ApiHelpers.extractMessage(response.data, fallback: 'Logged out');
    } on DioException catch (e) {
      // Still clear local session even if API fails.
      AppLogger.warning('Logout API failed: ${_extractError(e)}');
      return 'Logged out';
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }
    }
    return e.message ?? 'Something went wrong. Please try again.';
  }
}
