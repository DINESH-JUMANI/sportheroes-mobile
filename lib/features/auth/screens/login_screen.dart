import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/auth/widgets/auth_header.dart';
import 'package:sportheroes_mobile/features/auth/widgets/auth_primary_button.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

enum _LoginUiStep { identifier, password }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  _LoginUiStep _step = _LoginUiStep.identifier;
  bool _obscure = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onContinueIdentifier() async {
    if (!_formKey.currentState!.validate()) return;

    final outcome = await ref
        .read(authProvider.notifier)
        .checkIdentifier(_identifierController.text.trim());

    if (!mounted) return;

    switch (outcome) {
      case IdentifierCheckOutcome.needsPassword:
        setState(() {
          _step = _LoginUiStep.password;
          _passwordController.clear();
        });
      case IdentifierCheckOutcome.needsSetPassword:
        AppSnackbar.info(
          context,
          'Create a password to continue with this account.',
        );
        Navigator.pushNamed(context, AppRoutes.setPassword);
      case IdentifierCheckOutcome.notFound:
        final parsed = ref
            .read(authProvider.notifier)
            .parseIdentifier(_identifierController.text.trim());
        AppSnackbar.info(
          context,
          'No account found. Create one to get started.',
        );
        Navigator.pushNamed(
          context,
          AppRoutes.register,
          arguments: {
            if (parsed.email != null) 'email': parsed.email,
            if (parsed.phone != null) 'phone': parsed.phone,
          },
        );
      case IdentifierCheckOutcome.failed:
        final message = ref.read(authProvider).authActionState.errorOrNull;
        if (message != null) AppSnackbar.error(context, message);
    }
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final outcome = await ref.read(authProvider.notifier).login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    switch (outcome) {
      case LoginOutcome.success:
        _goAfterAuth();
      case LoginOutcome.passwordNotSet:
        AppSnackbar.warning(
          context,
          'Password is not set for this account. Create one to continue.',
        );
        Navigator.pushNamed(context, AppRoutes.setPassword);
      case LoginOutcome.failed:
        final message = ref.read(authProvider).authActionState.errorOrNull;
        if (message != null) AppSnackbar.error(context, message);
    }
  }

  void _goAfterAuth() {
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
  }

  void _editIdentifier() {
    setState(() {
      _step = _LoginUiStep.identifier;
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isLoading = auth.authActionState.isLoading;
    final isPasswordStep = _step == _LoginUiStep.password;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthHeader(
                  title: isPasswordStep ? 'Enter password' : 'Welcome back',
                  subtitle: isPasswordStep
                      ? 'Enter the password for ${_identifierController.text.trim()}.'
                      : 'Enter your email or phone number to continue.',
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _identifierController,
                  readOnly: isPasswordStep,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: isPasswordStep
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onFieldSubmitted: (_) {
                    if (!isPasswordStep) _onContinueIdentifier();
                  },
                  decoration: InputDecoration(
                    labelText: 'Email or phone',
                    hintText: 'you@email.com or 9876543210',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    suffixIcon: isPasswordStep
                        ? TextButton(
                            onPressed: isLoading ? null : _editIdentifier,
                            child: const Text('Change'),
                          )
                        : null,
                  ),
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Email or phone'),
                ),
                if (isPasswordStep) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onLogin(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: Validators.temporaryPassword,
                  ),
                ],
                const SizedBox(height: 28),
                AuthPrimaryButton(
                  label: isPasswordStep ? 'Sign in' : 'Continue',
                  isLoading: isLoading,
                  onPressed: isPasswordStep ? _onLogin : _onContinueIdentifier,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New here?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              ),
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
