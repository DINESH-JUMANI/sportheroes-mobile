import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/auth/widgets/auth_header.dart';
import 'package:sportheroes_mobile/features/auth/widgets/auth_primary_button.dart';
import 'package:sportheroes_mobile/features/auth/widgets/phone_input_field.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  String? _fieldError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final error = Validators.phone(_phoneController.text, maxLength: 10);
    if (error != null) {
      setState(() => _fieldError = error);
      return;
    }
    setState(() => _fieldError = null);

    final notifier = ref.read(authProvider.notifier);
    final e164 = notifier.formatPhone(_phoneController.text.trim());
    final ok = await notifier.sendOtp(e164);

    if (!mounted) return;

    if (ok) {
      final step = ref.read(authProvider).step;
      if (step == AuthStep.otp) {
        Navigator.pushNamed(context, AppRoutes.otp);
      } else if (step == AuthStep.profile) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.completeProfile,
          (route) => false,
        );
      } else if (step == AuthStep.authenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
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
    final isLoading = auth.sendOtpState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(
                title: 'Welcome to SportHeroes',
                subtitle:
                    'Sign in with your phone number to track matches, teams, and tournaments.',
              ),
              const SizedBox(height: 40),
              PhoneInputField(
                controller: _phoneController,
                errorText: _fieldError,
                onChanged: (_) {
                  if (_fieldError != null) {
                    setState(() => _fieldError = null);
                  }
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'We will send a one-time password (OTP) via SMS.',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 32),
              AuthPrimaryButton(
                label: 'Send OTP',
                isLoading: isLoading,
                onPressed: _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
