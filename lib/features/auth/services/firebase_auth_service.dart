import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sportheroes_mobile/utils/app_logger.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  /// Sends OTP to [phoneNumber] (E.164, e.g. `+919876543210`).
  Future<PhoneVerificationResult> sendOtp({
    required String phoneNumber,
    int? forceResendingToken,
  }) async {
    final completer = Completer<PhoneVerificationResult>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        AppLogger.info('Firebase auto-verification completed');
        try {
          await _auth.signInWithCredential(credential);
          final idToken = await _auth.currentUser?.getIdToken();
          if (!completer.isCompleted) {
            completer.complete(
              PhoneVerificationResult.autoVerified(idToken: idToken),
            );
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.complete(
              PhoneVerificationResult.failed(message: e.toString()),
            );
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        AppLogger.error('Firebase verification failed: ${e.message}');
        if (!completer.isCompleted) {
          completer.complete(
            PhoneVerificationResult.failed(
              message: e.message ?? 'Phone verification failed',
            ),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        AppLogger.info('Firebase OTP code sent');
        if (!completer.isCompleted) {
          completer.complete(
            PhoneVerificationResult.codeSent(
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        AppLogger.info('Firebase auto-retrieval timeout');
        if (!completer.isCompleted) {
          completer.complete(
            PhoneVerificationResult.codeSent(
              verificationId: verificationId,
            ),
          );
        }
      },
    );

    return completer.future;
  }

  /// Verifies OTP and returns Firebase ID token.
  Future<String> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await _auth.signInWithCredential(credential);
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Firebase sign-in failed');
    }

    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to obtain Firebase ID token');
    }
    return idToken;
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

sealed class PhoneVerificationResult {
  const PhoneVerificationResult();

  factory PhoneVerificationResult.codeSent({
    required String verificationId,
    int? resendToken,
  }) = PhoneCodeSent;

  factory PhoneVerificationResult.autoVerified({String? idToken}) =
      PhoneAutoVerified;

  factory PhoneVerificationResult.failed({required String message}) =
      PhoneVerificationFailed;
}

final class PhoneCodeSent extends PhoneVerificationResult {
  const PhoneCodeSent({required this.verificationId, this.resendToken});

  final String verificationId;
  final int? resendToken;
}

final class PhoneAutoVerified extends PhoneVerificationResult {
  const PhoneAutoVerified({this.idToken});

  final String? idToken;
}

final class PhoneVerificationFailed extends PhoneVerificationResult {
  const PhoneVerificationFailed({required this.message});

  final String message;
}
