import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/app_loading_overlay.dart';
import 'package:sportheroes_mobile/core/widgets/app_logo_loader.dart';
import 'package:sportheroes_mobile/features/teams/models/team_model.dart';
import 'package:sportheroes_mobile/features/teams/providers/teams_provider.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

class AddMemberSheet extends ConsumerStatefulWidget {
  const AddMemberSheet({super.key, required this.teamId});

  final String teamId;

  @override
  ConsumerState<AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<AddMemberSheet> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _lookedUp = false;
  bool _userFound = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatPhone(String local) {
    final digits = local.replaceAll(RegExp(r'\D'), '');
    return '+91$digits';
  }

  Future<void> _lookup() async {
    final error = Validators.phone(_phoneController.text, maxLength: 10);
    if (error != null) {
      AppSnackbar.error(context, error);
      return;
    }

    ref.read(teamsProvider.notifier).clearLookup();
    await ref
        .read(teamsProvider.notifier)
        .lookupUserByPhone(_formatPhone(_phoneController.text.trim()));

    final lookup = ref.read(teamsProvider).lookupState.dataOrNull;
    if (!mounted) return;

    setState(() {
      _lookedUp = true;
      _userFound = lookup?.found ?? false;
      if (_userFound && lookup?.user != null) {
        _nameController.text =
            lookup!.user!.fullName ?? lookup.user!.displayLabel;
      } else {
        _nameController.clear();
      }
    });
  }

  Future<void> _add() async {
    final phone = _formatPhone(_phoneController.text.trim());

    if (!_lookedUp) {
      await _lookup();
      if (!mounted) return;
      if (!_lookedUp) return;
    }

    if (!_userFound && _nameController.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Full name is required for new players');
      return;
    }

    final ok = await AppLoader.during(
      context,
      () => ref.read(teamsProvider.notifier).addMember(
            widget.teamId,
            AddTeamMemberRequest(
              phoneNumber: phone,
              fullName: _userFound ? null : _nameController.text.trim(),
            ),
          ),
      message: 'Adding member…',
    );

    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, 'Member added');
      Navigator.pop(context);
    } else {
      final err = ref.read(teamsProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lookupState = ref.watch(teamsProvider).lookupState;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add team member',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Find players by phone number. New numbers need a full name.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              labelText: 'Phone number',
              prefixText: '+91 ',
              hintText: '9876543210',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            onChanged: (_) {
              if (_lookedUp) {
                setState(() {
                  _lookedUp = false;
                  _userFound = false;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: lookupState.isLoading ? null : _lookup,
            icon: lookupState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: AppLogoLoader(size: 16),
                  )
                : const Icon(Icons.search_rounded),
            label: Text(lookupState.isLoading ? 'Looking up…' : 'Look up player'),
          ),
          if (_lookedUp) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _userFound ? AppColors.success50 : AppColors.warning50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _userFound
                        ? Icons.check_circle_rounded
                        : Icons.person_add_alt_1_rounded,
                    color: _userFound
                        ? AppColors.success700
                        : AppColors.warning700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _userFound
                          ? 'Player found: ${_nameController.text}'
                          : 'Not registered yet — enter their full name',
                      style: TextStyle(
                        color: _userFound
                            ? AppColors.success700
                            : AppColors.warning700,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_lookedUp && !_userFound) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _add,
              child: const Text('Add to team'),
            ),
          ),
        ],
      ),
    );
  }
}
