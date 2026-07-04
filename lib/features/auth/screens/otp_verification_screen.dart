import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/auth/widgets/auth_header.dart';
import 'package:sportheroes_mobile/features/auth/widgets/auth_primary_button.dart';
import 'package:sportheroes_mobile/features/auth/widgets/otp_input_field.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  String? _fieldError;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _onVerify() async {
    final error = Validators.otp(_otpController.text);
    if (error != null) {
      setState(() => _fieldError = error);
      return;
    }
    setState(() => _fieldError = null);

    final ok = await ref
        .read(authProvider.notifier)
        .verifyOtp(_otpController.text.trim());

    if (!mounted) return;

    if (ok) {
      final step = ref.read(authProvider).step;
      if (step == AuthStep.profile) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.completeProfile,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } else {
      final message = ref.read(authProvider).verifyOtpState.errorOrNull;
      if (message != null) {
        AppSnackbar.error(context, message);
      }
    }
  }

  Future<void> _onResend() async {
    final ok = await ref.read(authProvider.notifier).resendOtp();
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, 'OTP resent successfully');
    } else {
      final message = ref.read(authProvider).sendOtpState.errorOrNull;
      if (message != null) {
        AppSnackbar.error(context, message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isLoading =
        auth.verifyOtpState.isLoading || auth.sendOtpState.isLoading;
    final phone = auth.phoneNumber ?? '';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading
              ? null
              : () {
                  ref.read(authProvider.notifier).resetToPhone();
                  Navigator.pop(context);
                },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                title: 'Verify OTP',
                subtitle: phone.isEmpty
                    ? 'Enter the 6-digit code sent to your phone.'
                    : 'Enter the 6-digit code sent to $phone',
              ),
              const SizedBox(height: 40),
              OtpInputField(
                controller: _otpController,
                errorText: _fieldError,
                onChanged: (_) {
                  if (_fieldError != null) {
                    setState(() => _fieldError = null);
                  }
                },
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                label: 'Verify & Continue',
                isLoading: auth.verifyOtpState.isLoading,
                onPressed: _onVerify,
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: isLoading ? null : _onResend,
                  child: auth.sendOtpState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
