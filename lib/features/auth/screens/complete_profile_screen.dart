import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/features/auth/models/login_response.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/auth/widgets/auth_header.dart';
import 'package:sportheroes_mobile/features/auth/widgets/auth_primary_button.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');

  @override
  void dispose() {
    _fullNameController.dispose();
    _displayNameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(authProvider.notifier).completeProfile(
          UpdateProfileRequest(
            fullName: _fullNameController.text.trim(),
            displayName: _displayNameController.text.trim(),
            city: _cityController.text.trim(),
            country: _countryController.text.trim(),
          ),
        );

    if (!mounted) return;

    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else {
      final message = ref.read(authProvider).profileState.errorOrNull;
      if (message != null) {
        AppSnackbar.error(context, message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).profileState.isLoading;

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
                const AuthHeader(
                  title: 'Complete your profile',
                  subtitle:
                      'Tell us a bit about yourself so other players can find you.',
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) => Validators.name(v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _displayNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    hintText: 'How you appear on leaderboards',
                  ),
                  validator: (v) => Validators.required(v, fieldName: 'Display name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (v) => Validators.required(v, fieldName: 'City'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _countryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Country'),
                  validator: (v) => Validators.required(v, fieldName: 'Country'),
                ),
                const SizedBox(height: 32),
                AuthPrimaryButton(
                  label: 'Save & Continue',
                  isLoading: isLoading,
                  onPressed: _onSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
