import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sportheroes_mobile/core/constants/api_constants.dart';
import 'package:sportheroes_mobile/core/models/api_result.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/network/dio_client.dart';
import 'package:sportheroes_mobile/core/utils/image_picker_helper.dart';
import 'package:sportheroes_mobile/features/auth/models/login_response.dart';
import 'package:sportheroes_mobile/features/auth/models/user_model.dart';
import 'package:sportheroes_mobile/utils/app_logger.dart';

class AuthApiException implements Exception {
  AuthApiException(this.message, {this.code});

  final String message;
  final String? code;

  bool get isPasswordNotSet =>
      (code ?? '').toUpperCase() == 'PASSWORD_NOT_SET';

  bool get isUserNotFound {
    final c = (code ?? '').toUpperCase();
    if (c == 'USER_NOT_FOUND' ||
        c == 'NOT_FOUND' ||
        c == 'USER_DOES_NOT_EXIST' ||
        c == 'ACCOUNT_NOT_FOUND') {
      return true;
    }
    final m = message.toLowerCase();
    return m.contains('not found') ||
        m.contains('does not exist') ||
        m.contains('no account') ||
        m.contains('unknown user') ||
        m.contains('user does not');
  }

  bool get isInvalidCredentials {
    final c = (code ?? '').toUpperCase();
    if (c == 'INVALID_CREDENTIALS' ||
        c == 'WRONG_PASSWORD' ||
        c == 'INVALID_PASSWORD' ||
        c == 'UNAUTHORIZED' ||
        c == 'AUTH_FAILED') {
      return true;
    }
    final m = message.toLowerCase();
    return m.contains('invalid credential') ||
        m.contains('wrong password') ||
        m.contains('incorrect password') ||
        m.contains('invalid password');
  }

  @override
  String toString() => message;
}

/// Result of checking whether an email/phone exists before asking for password.
class AccountCheckResult {
  const AccountCheckResult({
    required this.exists,
    required this.hasPassword,
  });

  factory AccountCheckResult.fromJson(Map<String, dynamic> json) {
    final exists = json['exists'] as bool? ??
        json['found'] as bool? ??
        json['userExists'] as bool? ??
        false;
    final hasPassword = json['hasPassword'] as bool? ??
        json['passwordSet'] as bool? ??
        false;
    return AccountCheckResult(exists: exists, hasPassword: hasPassword);
  }

  final bool exists;
  final bool hasPassword;
}

class AuthService {
  AuthService(this._dioClient);

  final DioClient _dioClient;

  Dio get _dio => _dioClient.dio;

  /// Checks if an account exists and whether a password is set.
  /// Tries `POST /auth/check`; falls back to a login probe if that route is missing.
  Future<AccountCheckResult> checkAccount({
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authCheck,
        data: {
          if (email != null && email.isNotEmpty) 'email': email,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phoneNumber': phoneNumber,
        },
      );
      final data = ApiHelpers.extractData(response.data);
      return AccountCheckResult.fromJson(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Route not available yet — probe via login.
      if (status == 404 || status == 405) {
        return _probeViaLogin(email: email, phoneNumber: phoneNumber);
      }
      throw _asAuthException(e);
    }
  }

  Future<AccountCheckResult> _probeViaLogin({
    String? email,
    String? phoneNumber,
  }) async {
    try {
      await login(
        email: email,
        phoneNumber: phoneNumber,
        password: '__account_check_probe__',
      );
      // Extremely unlikely: probe password worked.
      return const AccountCheckResult(exists: true, hasPassword: true);
    } on AuthApiException catch (e) {
      if (e.isPasswordNotSet) {
        return const AccountCheckResult(exists: true, hasPassword: false);
      }
      if (e.isUserNotFound) {
        return const AccountCheckResult(exists: false, hasPassword: false);
      }
      // Wrong password / invalid credentials ⇒ account exists with a password.
      return const AccountCheckResult(exists: true, hasPassword: true);
    }
  }

  Future<LoginResponse> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authLogin,
        data: {
          if (email != null && email.isNotEmpty) 'email': email,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phoneNumber': phoneNumber,
          'password': password,
        },
      );
      return _parseLogin(response.data);
    } on DioException catch (e) {
      throw _asAuthException(e);
    }
  }

  Future<LoginResponse> register({
    String? email,
    String? phoneNumber,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authRegister,
        data: {
          if (email != null && email.isNotEmpty) 'email': email,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phoneNumber': phoneNumber,
          'password': password,
          'fullName': fullName,
        },
      );
      return _parseLogin(response.data);
    } on DioException catch (e) {
      throw _asAuthException(e);
    }
  }

  Future<LoginResponse> setPassword({
    String? email,
    String? phoneNumber,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authSetPassword,
        data: {
          if (email != null && email.isNotEmpty) 'email': email,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phoneNumber': phoneNumber,
          'password': password,
          if (fullName != null && fullName.trim().isNotEmpty)
            'fullName': fullName.trim(),
        },
      );
      return _parseLogin(response.data);
    } on DioException catch (e) {
      throw _asAuthException(e);
    }
  }

  Future<LoginResponse> resetPassword({
    String? email,
    String? phoneNumber,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authResetPassword,
        data: {
          if (email != null && email.isNotEmpty) 'email': email,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phoneNumber': phoneNumber,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return _parseLogin(response.data);
    } on DioException catch (e) {
      throw _asAuthException(e);
    }
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authChangePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return ApiHelpers.extractMessage(
        response.data,
        fallback: 'Password updated',
      );
    } on DioException catch (e) {
      throw _asAuthException(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.authMe);
      return UserModel.fromJson(_extractUserPayload(response.data));
    } on DioException catch (e) {
      throw _asAuthException(e);
    }
  }

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
      throw _asAuthException(e);
    }
  }

  Future<ApiResult<UserModel>> uploadAvatar(PickedImageFile image) async {
    try {
      final filename = _uploadFilename(image.path, image.mimeType);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: filename,
          contentType: MediaType.parse(image.mimeType),
        ),
      });
      final response = await _dio.post(
        ApiConstants.authAvatar,
        data: formData,
      );
      return ApiResult(
        data: UserModel.fromJson(_extractUserPayload(response.data)),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Avatar uploaded',
        ),
      );
    } on DioException catch (e) {
      throw _asAuthException(e);
    }
  }

  String _uploadFilename(String path, String mimeType) {
    final name = path.split(RegExp(r'[\\/]')).last;
    if (name.contains('.')) return name;
    final ext = switch (mimeType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/gif' => 'gif',
      _ => 'jpg',
    };
    return 'avatar.$ext';
  }

  Map<String, dynamic> _extractUserPayload(dynamic responseData) {
    final body = Map<String, dynamic>.from(responseData as Map? ?? {});
    final data = Map<String, dynamic>.from(body['data'] as Map? ?? body);
    if (data['user'] is Map) {
      return Map<String, dynamic>.from(data['user'] as Map);
    }
    return data;
  }

  LoginResponse _parseLogin(dynamic responseData) {
    final body = responseData as Map<String, dynamic>;
    final data = Map<String, dynamic>.from(body['data'] as Map? ?? body);
    return LoginResponse.fromJson(data);
  }

  AuthApiException _asAuthException(DioException e) {
    return AuthApiException(
      ApiHelpers.extractError(e),
      code: ApiHelpers.extractErrorCode(e),
    );
  }

  Future<String> logout() async {
    try {
      final response = await _dio.post(ApiConstants.authLogout);
      return ApiHelpers.extractMessage(response.data, fallback: 'Logged out');
    } on DioException catch (e) {
      AppLogger.warning('Logout API failed: ${ApiHelpers.extractError(e)}');
      return 'Logged out';
    }
  }
}
