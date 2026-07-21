import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/utils/image_picker_helper.dart';
import 'package:sportheroes_mobile/core/widgets/app_loading_overlay.dart';
import 'package:sportheroes_mobile/features/auth/models/login_response.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _displayName;
  late final TextEditingController _email;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _country;

  String? _gender;
  String? _logoBase64;
  String? _logoMime;
  String? _existingPictureUrl;

  static const _genders = [
    ('male', 'Male'),
    ('female', 'Female'),
    ('other', 'Other'),
    ('prefer_not_to_say', 'Prefer not to say'),
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _fullName = TextEditingController(text: user?.fullName ?? '');
    _displayName = TextEditingController(text: user?.displayName ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _city = TextEditingController(text: user?.city ?? '');
    _state = TextEditingController(text: user?.state ?? '');
    _country = TextEditingController(text: user?.country ?? '');
    _gender = user?.gender;
    _existingPictureUrl = user?.profilePictureUrl;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _displayName.dispose();
    _email.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePickerHelper.pickLogo();
    if (picked == null) return;
    setState(() {
      _logoBase64 = picked.base64;
      _logoMime = picked.mimeType;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await AppLoader.during(
      context,
      () => ref.read(authProvider.notifier).completeProfile(
            UpdateProfileRequest(
              fullName: _fullName.text.trim(),
              displayName: _displayName.text.trim().isEmpty
                  ? null
                  : _displayName.text.trim(),
              email: _email.text.trim().isEmpty ? null : _email.text.trim(),
              city: _city.text.trim().isEmpty ? null : _city.text.trim(),
              state: _state.text.trim().isEmpty ? null : _state.text.trim(),
              country:
                  _country.text.trim().isEmpty ? null : _country.text.trim(),
              gender: _gender,
              profilePictureBase64: _logoBase64,
              profilePictureMimeType: _logoMime,
            ),
          ),
      message: 'Saving profile…',
    );

    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(
        context,
        ref.read(authProvider).lastActionMessage ?? 'Profile updated',
      );
      Navigator.pop(context);
    } else {
      final err = ref.read(authProvider).profileState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatar;
    if (_logoBase64 != null) {
      avatar = MemoryImage(base64Decode(_logoBase64!));
    } else if (_existingPictureUrl != null &&
        _existingPictureUrl!.trim().isNotEmpty) {
      avatar = NetworkImage(_existingPictureUrl!);
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary50,
                      backgroundImage: avatar,
                      child: avatar == null
                          ? const Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap to change photo',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _fullName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) => Validators.required(v, fieldName: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _displayName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Display name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
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
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc_outlined),
              ),
              items: _genders
                  .map(
                    (g) => DropdownMenuItem(value: g.$1, child: Text(g.$2)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _city,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _state,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'State',
                prefixIcon: Icon(Icons.map_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _country,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Country',
                prefixIcon: Icon(Icons.public_outlined),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
