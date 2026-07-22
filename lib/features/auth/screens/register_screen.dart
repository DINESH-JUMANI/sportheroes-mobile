import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/auth/widgets/auth_header.dart';
import 'package:sportheroes_mobile/features/auth/widgets/auth_primary_button.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _prefillApplied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefillApplied) return;
    _prefillApplied = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final email = args['email']?.toString();
      final phone = args['phone']?.toString();
      if (email != null && email.isNotEmpty) {
        _emailController.text = email;
      }
      if (phone != null && phone.isNotEmpty) {
        // Strip +91 for the local phone field.
        var local = phone.replaceAll(RegExp(r'\D'), '');
        if (local.startsWith('91') && local.length > 10) {
          local = local.substring(local.length - 10);
        }
        _phoneController.text = local;
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final phoneRaw = _phoneController.text.trim();

    final notifier = ref.read(authProvider.notifier);
    final ok = await notifier.register(
      email: email.isEmpty ? null : email,
      phoneNumber: notifier.formatPhone(phoneRaw),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
    );

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
      final message = ref.read(authProvider).authActionState.errorOrNull;
      if (message != null) AppSnackbar.error(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).authActionState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                  title: 'Create account',
                  subtitle:
                      'Register with your phone number and password. Email is optional.',
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: Validators.name,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    return Validators.email(v);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: '10-digit mobile',
                    prefixIcon: Icon(Icons.phone_outlined),
                    prefixText: '+91 ',
                  ),
                  validator: (v) => Validators.phone(v, maxLength: 10),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
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
                  validator: Validators.password,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (v) => Validators.confirmPassword(
                    v,
                    _passwordController.text,
                  ),
                ),
                const SizedBox(height: 28),
                AuthPrimaryButton(
                  label: 'Create account',
                  isLoading: isLoading,
                  onPressed: _onRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
