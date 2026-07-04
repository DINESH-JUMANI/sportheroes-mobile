import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/models/api_state.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/features/auth/models/login_response.dart';
import 'package:sportheroes_mobile/features/auth/models/user_model.dart';
import 'package:sportheroes_mobile/features/auth/services/auth_service.dart';
import 'package:sportheroes_mobile/features/auth/services/firebase_auth_service.dart';
import 'package:sportheroes_mobile/utils/app_logger.dart';

// ── Service providers ───────────────────────────────────────────────────────

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioClientProvider));
});

// ── Auth session state ──────────────────────────────────────────────────────

enum AuthStep { phone, otp, profile, authenticated }

class AuthSessionState {
  const AuthSessionState({
    this.step = AuthStep.phone,
    this.phoneNumber,
    this.verificationId,
    this.resendToken,
    this.user,
    this.isNewUser = false,
    this.sendOtpState = const ApiInitial<bool>(),
    this.verifyOtpState = const ApiInitial<bool>(),
    this.profileState = const ApiInitial<UserModel>(),
    this.logoutState = const ApiInitial<bool>(),
  });

  final AuthStep step;
  final String? phoneNumber;
  final String? verificationId;
  final int? resendToken;
  final UserModel? user;
  final bool isNewUser;

  /// Loading / success / error for sending OTP.
  final ApiState<bool> sendOtpState;

  /// Loading / success / error for verifying OTP + backend login.
  final ApiState<bool> verifyOtpState;

  /// Loading / success / error for profile update / fetch.
  final ApiState<UserModel> profileState;

  final ApiState<bool> logoutState;

  bool get isBusy =>
      sendOtpState.isLoading ||
      verifyOtpState.isLoading ||
      profileState.isLoading ||
      logoutState.isLoading;

  AuthSessionState copyWith({
    AuthStep? step,
    String? phoneNumber,
    String? verificationId,
    int? resendToken,
    UserModel? user,
    bool? isNewUser,
    ApiState<bool>? sendOtpState,
    ApiState<bool>? verifyOtpState,
    ApiState<UserModel>? profileState,
    ApiState<bool>? logoutState,
    bool clearUser = false,
    bool clearVerification = false,
  }) {
    return AuthSessionState(
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: clearVerification
          ? null
          : (verificationId ?? this.verificationId),
      resendToken: clearVerification
          ? null
          : (resendToken ?? this.resendToken),
      user: clearUser ? null : (user ?? this.user),
      isNewUser: isNewUser ?? this.isNewUser,
      sendOtpState: sendOtpState ?? this.sendOtpState,
      verifyOtpState: verifyOtpState ?? this.verifyOtpState,
      profileState: profileState ?? this.profileState,
      logoutState: logoutState ?? this.logoutState,
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

  FirebaseAuthService get _firebase => ref.read(firebaseAuthServiceProvider);
  AuthService get _auth => ref.read(authServiceProvider);

  /// Formats local digits into E.164 with India default (`+91`).
  String formatPhone(String localDigits, {String countryCode = '+91'}) {
    final digits = localDigits.replaceAll(RegExp(r'\D'), '');
    final code = countryCode.startsWith('+') ? countryCode : '+$countryCode';
    return '$code$digits';
  }

  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(
      sendOtpState: const ApiLoading<bool>(),
      phoneNumber: phoneNumber,
    );

    try {
      final result = await _firebase.sendOtp(
        phoneNumber: phoneNumber,
        forceResendingToken: state.resendToken,
      );

      switch (result) {
        case PhoneCodeSent(:final verificationId, :final resendToken):
          state = state.copyWith(
            step: AuthStep.otp,
            verificationId: verificationId,
            resendToken: resendToken,
            sendOtpState: const ApiSuccess(true),
            verifyOtpState: const ApiInitial(),
          );
          return true;

        case PhoneAutoVerified(:final idToken):
          if (idToken == null || idToken.isEmpty) {
            state = state.copyWith(
              sendOtpState: const ApiError(
                'Auto-verification succeeded but no ID token was returned',
              ),
            );
            return false;
          }
          return _exchangeIdToken(idToken);

        case PhoneVerificationFailed(:final message):
          state = state.copyWith(sendOtpState: ApiError(message));
          return false;
      }
    } catch (e) {
      AppLogger.error('sendOtp failed: $e');
      state = state.copyWith(sendOtpState: ApiError(e.toString()));
      return false;
    }
  }

  Future<bool> resendOtp() async {
    final phone = state.phoneNumber;
    if (phone == null) return false;
    return sendOtp(phone);
  }

  Future<bool> verifyOtp(String smsCode) async {
    final verificationId = state.verificationId;
    if (verificationId == null) {
      state = state.copyWith(
        verifyOtpState: const ApiError(
          'Missing verification ID. Please request OTP again.',
        ),
      );
      return false;
    }

    state = state.copyWith(verifyOtpState: const ApiLoading<bool>());

    try {
      final idToken = await _firebase.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return _exchangeIdToken(idToken);
    } catch (e) {
      AppLogger.error('verifyOtp failed: $e');
      state = state.copyWith(verifyOtpState: ApiError(_cleanError(e)));
      return false;
    }
  }

  Future<bool> _exchangeIdToken(String idToken) async {
    state = state.copyWith(verifyOtpState: const ApiLoading<bool>());

    try {
      final login = await _auth.loginWithIdToken(idToken);
      final storage = ref.read(localStorageServiceProvider);
      await storage.saveSession(
        accessToken: login.tokens.accessToken,
        user: login.user.toJson(),
      );

      final needsProfile =
          login.isNewUser || !login.user.isProfileComplete;

      state = state.copyWith(
        user: login.user,
        isNewUser: login.isNewUser,
        step: needsProfile ? AuthStep.profile : AuthStep.authenticated,
        verifyOtpState: const ApiSuccess(true),
        sendOtpState: const ApiInitial(),
      );
      return true;
    } catch (e) {
      AppLogger.error('Backend login failed: $e');
      state = state.copyWith(verifyOtpState: ApiError(_cleanError(e)));
      return false;
    }
  }

  Future<bool> completeProfile(UpdateProfileRequest request) async {
    state = state.copyWith(profileState: const ApiLoading<UserModel>());

    try {
      final user = await _auth.updateProfile(request);
      final storage = ref.read(localStorageServiceProvider);
      await storage.setUserJson(user.toJson());

      state = state.copyWith(
        user: user,
        step: AuthStep.authenticated,
        profileState: ApiSuccess(user),
      );
      return true;
    } catch (e) {
      AppLogger.error('completeProfile failed: $e');
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

  Future<void> logout() async {
    state = state.copyWith(logoutState: const ApiLoading<bool>());
    try {
      await _auth.logout();
    } finally {
      await _firebase.signOut();
      await ref.read(localStorageServiceProvider).clearSession();
      state = const AuthSessionState(logoutState: ApiSuccess(true));
    }
  }

  void resetToPhone() {
    state = AuthSessionState(phoneNumber: state.phoneNumber);
  }

  void clearErrors() {
    state = state.copyWith(
      sendOtpState: state.sendOtpState.isError
          ? const ApiInitial<bool>()
          : state.sendOtpState,
      verifyOtpState: state.verifyOtpState.isError
          ? const ApiInitial<bool>()
          : state.verifyOtpState,
      profileState: state.profileState.isError
          ? const ApiInitial<UserModel>()
          : state.profileState,
    );
  }

  String _cleanError(Object e) {
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
