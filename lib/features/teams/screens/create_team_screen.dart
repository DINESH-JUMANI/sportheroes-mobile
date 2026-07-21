import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/utils/image_picker_helper.dart';
import 'package:sportheroes_mobile/core/widgets/app_loading_overlay.dart';
import 'package:sportheroes_mobile/features/teams/models/team_model.dart';
import 'package:sportheroes_mobile/features/teams/providers/teams_provider.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

class CreateTeamScreen extends ConsumerStatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _logoBase64;
  String? _logoMimeType;

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePickerHelper.pickLogo();
    if (picked == null) return;
    setState(() {
      _logoBase64 = picked.base64;
      _logoMimeType = picked.mimeType;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final team = await AppLoader.during(
      context,
      () => ref.read(teamsProvider.notifier).createTeam(
            CreateTeamRequest(
              name: _nameController.text.trim(),
              shortName: _shortNameController.text.trim().isEmpty
                  ? null
                  : _shortNameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              logoBase64: _logoBase64,
              logoMimeType: _logoMimeType,
            ),
          ),
      message: 'Creating team…',
    );

    if (!mounted) return;
    if (team != null) {
      final msg =
          ref.read(teamsProvider).actionState.dataOrNull ?? 'Team created';
      AppSnackbar.success(context, msg);
      Navigator.pop(context);
    } else {
      final err = ref.read(teamsProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Create Team')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickLogo,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary50,
                      backgroundImage: _logoBase64 != null
                          ? MemoryImage(base64Decode(_logoBase64!))
                          : null,
                      child: _logoBase64 == null
                          ? const Icon(
                              Icons.add_a_photo_rounded,
                              color: AppColors.primary,
                              size: 28,
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
                          Icons.edit_rounded,
                          size: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Add a team logo (optional)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Team name',
                hintText: 'e.g. Mumbai Smashers',
                prefixIcon: Icon(Icons.groups_rounded),
              ),
              validator: (v) => Validators.required(v, fieldName: 'Name'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _shortNameController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Short name (optional)',
                hintText: 'e.g. MSM',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
              maxLength: 10,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary25,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You’ll be the team admin. Add members later with their phone numbers.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Create Team'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
