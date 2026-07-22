import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/models/api_state.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/core/utils/image_picker_helper.dart';
import 'package:sportheroes_mobile/features/auth/models/login_response.dart';
import 'package:sportheroes_mobile/features/auth/models/user_model.dart';
import 'package:sportheroes_mobile/features/auth/services/auth_service.dart';
import 'package:sportheroes_mobile/utils/app_logger.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioClientProvider));
});

enum AuthStep { login, setPassword, profile, authenticated }

enum LoginOutcome { success, passwordNotSet, failed }

/// After identifier-only continue on the login screen.
enum IdentifierCheckOutcome {
  /// Account exists and has a password → show password field.
  needsPassword,

  /// Account exists but password not set → set-password screen.
  needsSetPassword,

  /// No account → register / sign-up screen.
  notFound,

  /// Network / unexpected error.
  failed,
}

class AuthSessionState {
  const AuthSessionState({
    this.step = AuthStep.login,
    this.pendingEmail,
    this.pendingPhone,
    this.user,
    this.isNewUser = false,
    this.authActionState = const ApiInitial<bool>(),
    this.profileState = const ApiInitial<UserModel>(),
    this.logoutState = const ApiInitial<String>(),
    this.lastActionMessage,
  });

  final AuthStep step;
  final String? pendingEmail;
  final String? pendingPhone;
  final UserModel? user;
  final bool isNewUser;
  final ApiState<bool> authActionState;
  final ApiState<UserModel> profileState;
  final ApiState<String> logoutState;
  final String? lastActionMessage;

  bool get isBusy =>
      authActionState.isLoading ||
      profileState.isLoading ||
      logoutState.isLoading;

  AuthSessionState copyWith({
    AuthStep? step,
    String? pendingEmail,
    String? pendingPhone,
    UserModel? user,
    bool? isNewUser,
    ApiState<bool>? authActionState,
    ApiState<UserModel>? profileState,
    ApiState<String>? logoutState,
    String? lastActionMessage,
    bool clearUser = false,
    bool clearPending = false,
  }) {
    return AuthSessionState(
      step: step ?? this.step,
      pendingEmail: clearPending ? null : (pendingEmail ?? this.pendingEmail),
      pendingPhone: clearPending ? null : (pendingPhone ?? this.pendingPhone),
      user: clearUser ? null : (user ?? this.user),
      isNewUser: isNewUser ?? this.isNewUser,
      authActionState: authActionState ?? this.authActionState,
      profileState: profileState ?? this.profileState,
      logoutState: logoutState ?? this.logoutState,
      lastActionMessage: lastActionMessage ?? this.lastActionMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() {
    final storage = ref.read(localStorageServiceProvider);
    if (storage.isLoggedIn) {
      final json = storage.userJson;
      final user = json != null ? UserModel.fromJson(json) : null;
      return AuthSessionState(
        step: user != null && !user.isProfileComplete
            ? AuthStep.profile
            : AuthStep.authenticated,
        user: user,
      );
    }
    return const AuthSessionState();
  }

  AuthService get _auth => ref.read(authServiceProvider);

  /// Formats local digits into E.164 with India default (`+91`).
  String formatPhone(String localDigits, {String countryCode = '+91'}) {
    final digits = localDigits.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (localDigits.trim().startsWith('+')) {
      return '+$digits';
    }
    final code = countryCode.startsWith('+') ? countryCode : '+$countryCode';
    return '$code$digits';
  }

  /// Returns email if [raw] looks like email, otherwise formatted phone.
  ({String? email, String? phone}) parseIdentifier(String raw) {
    final value = raw.trim();
    if (value.contains('@')) {
      return (email: value, phone: null);
    }
    final phone = formatPhone(value);
    return (email: null, phone: phone.isEmpty ? null : phone);
  }

  /// Step 1 of login: check whether the email/phone exists and has a password.
  Future<IdentifierCheckOutcome> checkIdentifier(String identifier) async {
    final parsed = parseIdentifier(identifier);
    if ((parsed.email == null || parsed.email!.isEmpty) &&
        (parsed.phone == null || parsed.phone!.isEmpty)) {
      state = state.copyWith(
        authActionState: const ApiError('Enter an email or phone number'),
      );
      return IdentifierCheckOutcome.failed;
    }

    state = state.copyWith(
      authActionState: const ApiLoading<bool>(),
      pendingEmail: parsed.email,
      pendingPhone: parsed.phone,
    );

    try {
      final result = await _auth.checkAccount(
        email: parsed.email,
        phoneNumber: parsed.phone,
      );

      if (!result.exists) {
        state = state.copyWith(authActionState: const ApiSuccess(true));
        return IdentifierCheckOutcome.notFound;
      }
      if (!result.hasPassword) {
        state = state.copyWith(
          step: AuthStep.setPassword,
          authActionState: const ApiSuccess(true),
        );
        return IdentifierCheckOutcome.needsSetPassword;
      }
      state = state.copyWith(authActionState: const ApiSuccess(true));
      return IdentifierCheckOutcome.needsPassword;
    } on AuthApiException catch (e) {
      AppLogger.error('checkIdentifier failed: ${e.message} (${e.code})');
      if (e.isPasswordNotSet) {
        state = state.copyWith(
          step: AuthStep.setPassword,
          authActionState: const ApiSuccess(true),
        );
        return IdentifierCheckOutcome.needsSetPassword;
      }
      if (e.isUserNotFound) {
        state = state.copyWith(authActionState: const ApiSuccess(true));
        return IdentifierCheckOutcome.notFound;
      }
      state = state.copyWith(authActionState: ApiError(e.message));
      return IdentifierCheckOutcome.failed;
    } catch (e) {
      AppLogger.error('checkIdentifier failed: $e');
      state = state.copyWith(authActionState: ApiError(_cleanError(e)));
      return IdentifierCheckOutcome.failed;
    }
  }

  Future<LoginOutcome> login({
    required String identifier,
    required String password,
  }) async {
    final parsed = parseIdentifier(identifier);
    state = state.copyWith(
      authActionState: const ApiLoading<bool>(),
      pendingEmail: parsed.email,
      pendingPhone: parsed.phone,
    );

    try {
      final login = await _auth.login(
        email: parsed.email,
        phoneNumber: parsed.phone,
        password: password,
      );
      await _applyLogin(login);
      return LoginOutcome.success;
    } on AuthApiException catch (e) {
      AppLogger.error('login failed: ${e.message} (${e.code})');
      if (e.isPasswordNotSet) {
        state = state.copyWith(
          step: AuthStep.setPassword,
          authActionState: ApiError(e.message),
        );
        return LoginOutcome.passwordNotSet;
      }
      state = state.copyWith(authActionState: ApiError(e.message));
      return LoginOutcome.failed;
    } catch (e) {
      AppLogger.error('login failed: $e');
      state = state.copyWith(authActionState: ApiError(_cleanError(e)));
      return LoginOutcome.failed;
    }
  }

  Future<bool> register({
    String? email,
    String? phoneNumber,
    required String password,
    required String fullName,
    UpdateProfileRequest? profileDetails,
  }) async {
    state = state.copyWith(authActionState: const ApiLoading<bool>());
    try {
      final login = await _auth.register(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        fullName: fullName,
      );
      await _applyLogin(login);

      if (profileDetails != null) {
        final result = await _auth.updateProfile(profileDetails);
        final storage = ref.read(localStorageServiceProvider);
        await storage.setUserJson(result.data.toJson());
        state = state.copyWith(
          user: result.data,
          step: AuthStep.authenticated,
          authActionState: const ApiSuccess(true),
          lastActionMessage: result.message,
        );
      }

      return true;
    } catch (e) {
      AppLogger.error('register failed: $e');
      state = state.copyWith(authActionState: ApiError(_cleanError(e)));
      return false;
    }
  }

  Future<bool> setPassword({
    required String password,
    String? fullName,
  }) async {
    state = state.copyWith(authActionState: const ApiLoading<bool>());
    try {
      final login = await _auth.setPassword(
        email: state.pendingEmail,
        phoneNumber: state.pendingPhone,
        password: password,
        fullName: fullName,
      );
      await _applyLogin(login);
      return true;
    } catch (e) {
      AppLogger.error('setPassword failed: $e');
      state = state.copyWith(authActionState: ApiError(_cleanError(e)));
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(authActionState: const ApiLoading<bool>());
    try {
      final message = await _auth.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(
        authActionState: const ApiSuccess(true),
        lastActionMessage: message,
      );
      return true;
    } catch (e) {
      AppLogger.error('changePassword failed: $e');
      state = state.copyWith(authActionState: ApiError(_cleanError(e)));
      return false;
    }
  }

  Future<void> _applyLogin(LoginResponse login) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveSession(
      accessToken: login.tokens.accessToken,
      user: login.user.toJson(),
    );

    final needsProfile = login.isNewUser || !login.user.isProfileComplete;
    state = state.copyWith(
      user: login.user,
      isNewUser: login.isNewUser,
      step: needsProfile ? AuthStep.profile : AuthStep.authenticated,
      authActionState: const ApiSuccess(true),
      clearPending: true,
    );
  }

  Future<bool> completeProfile(UpdateProfileRequest request) async {
    state = state.copyWith(profileState: const ApiLoading<UserModel>());

    try {
      final result = await _auth.updateProfile(request);
      final storage = ref.read(localStorageServiceProvider);
      await storage.setUserJson(result.data.toJson());

      state = state.copyWith(
        user: result.data,
        step: AuthStep.authenticated,
        profileState: ApiSuccess(result.data),
        lastActionMessage: result.message,
      );
      return true;
    } catch (e) {
      AppLogger.error('completeProfile failed: $e');
      state = state.copyWith(profileState: ApiError(_cleanError(e)));
      return false;
    }
  }

  Future<bool> uploadAvatar(PickedImageFile image) async {
    state = state.copyWith(profileState: const ApiLoading<UserModel>());
    try {
      final result = await _auth.uploadAvatar(image);
      final storage = ref.read(localStorageServiceProvider);
      await storage.setUserJson(result.data.toJson());
      state = state.copyWith(
        user: result.data,
        profileState: ApiSuccess(result.data),
        lastActionMessage: result.message,
      );
      return true;
    } catch (e) {
      AppLogger.error('uploadAvatar failed: $e');
      state = state.copyWith(profileState: ApiError(_cleanError(e)));
      return false;
    }
  }

  Future<void> refreshMe() async {
    state = state.copyWith(profileState: const ApiLoading<UserModel>());
    try {
      final user = await _auth.getMe();
      final storage = ref.read(localStorageServiceProvider);
      await storage.setUserJson(user.toJson());
      state = state.copyWith(
        user: user,
        profileState: ApiSuccess(user),
        step: user.isProfileComplete
            ? AuthStep.authenticated
            : AuthStep.profile,
      );
    } catch (e) {
      state = state.copyWith(profileState: ApiError(_cleanError(e)));
    }
  }

  Future<bool> validateSession() async {
    final storage = ref.read(localStorageServiceProvider);
    if (!storage.isLoggedIn) return false;

    try {
      final valid = await _auth.validateAccessToken();
      if (!valid) {
        await logout();
        return false;
      }
      try {
        await refreshMe();
      } catch (_) {}
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(logoutState: const ApiLoading<String>());
    String message = 'Logged out';
    try {
      message = await _auth.logout();
    } finally {
      await ref.read(localStorageServiceProvider).clearSession();
      state = AuthSessionState(logoutState: ApiSuccess(message));
    }
  }

  void clearErrors() {
    state = state.copyWith(
      authActionState: state.authActionState.isError
          ? const ApiInitial<bool>()
          : state.authActionState,
      profileState: state.profileState.isError
          ? const ApiInitial<UserModel>()
          : state.profileState,
    );
  }

  String _cleanError(Object e) {
    if (e is AuthApiException) return e.message;
    final text = e.toString();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }
    return text;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthSessionState>(
  AuthNotifier.new,
);
