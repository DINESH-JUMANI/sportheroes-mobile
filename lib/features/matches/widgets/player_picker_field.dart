import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/app_logo_loader.dart';
import 'package:sportheroes_mobile/features/auth/models/user_model.dart';
import 'package:sportheroes_mobile/features/search/providers/search_provider.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

/// Selected player for match create — either from search or manually added.
class PickedPlayer {
  const PickedPlayer({
    required this.phoneNumber,
    this.fullName,
    this.userId,
    this.fromSearch = false,
  });

  /// E.164 phone, e.g. +919999999999
  final String phoneNumber;
  final String? fullName;
  final String? userId;
  final bool fromSearch;

  String get displayLabel {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    return phoneNumber;
  }
}

/// Search-first player picker with "Add new player" fallback.
class PlayerPickerField extends ConsumerStatefulWidget {
  const PlayerPickerField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initial,
  });

  final String label;
  final ValueChanged<PickedPlayer?> onChanged;
  final PickedPlayer? initial;

  @override
  ConsumerState<PlayerPickerField> createState() => _PlayerPickerFieldState();
}

class _PlayerPickerFieldState extends ConsumerState<PlayerPickerField> {
  final _searchController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Timer? _debounce;
  List<UserSummary> _results = const [];
  bool _searching = false;
  String? _searchError;
  bool _showResults = false;
  bool _addingNew = false;
  PickedPlayer? _selected;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _toE164(String local) {
    final digits = local.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('91') && digits.length > 10) {
      return '+$digits';
    }
    return '+91$digits';
  }

  void _selectUser(UserSummary user) {
    final phone = user.phoneNumber?.trim() ?? '';
    if (phone.isEmpty) return;

    final picked = PickedPlayer(
      phoneNumber: phone.startsWith('+') ? phone : _toE164(phone),
      fullName: user.fullName ?? user.displayName,
      userId: user.id,
      fromSearch: true,
    );
    setState(() {
      _selected = picked;
      _showResults = false;
      _addingNew = false;
      _results = const [];
      _searchController.clear();
    });
    widget.onChanged(picked);
  }

  void _clearSelection() {
    setState(() {
      _selected = null;
      _addingNew = false;
      _showResults = false;
      _results = const [];
      _searchController.clear();
      _phoneController.clear();
      _nameController.clear();
    });
    widget.onChanged(null);
  }

  void _startAddNew() {
    setState(() {
      _addingNew = true;
      _showResults = false;
      _selected = null;
      // Prefill phone if the query looks like digits.
      final q = _searchController.text.trim();
      final digits = q.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 6) {
        _phoneController.text = digits.length > 10
            ? digits.substring(digits.length - 10)
            : digits;
      }
    });
    widget.onChanged(null);
  }

  void _cancelAddNew() {
    setState(() {
      _addingNew = false;
      _phoneController.clear();
      _nameController.clear();
    });
    widget.onChanged(null);
  }

  void _confirmNewPlayer() {
    if (!_formKey.currentState!.validate()) return;
    final picked = PickedPlayer(
      phoneNumber: _toE164(_phoneController.text.trim()),
      fullName: _nameController.text.trim(),
    );
    setState(() {
      _selected = picked;
      _addingNew = false;
      _searchController.clear();
    });
    widget.onChanged(picked);
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.isEmpty) {
      setState(() {
        _results = const [];
        _showResults = false;
        _searching = false;
        _searchError = null;
      });
      return;
    }

    setState(() {
      _searching = true;
      _searchError = null;
      _showResults = true;
    });

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(q);
    });
  }

  Future<void> _runSearch(String query) async {
    final id = ++_requestId;
    try {
      final page = await ref.read(searchServiceProvider).searchUsers(
            query: query,
            limit: 10,
          );
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = page.users;
        _searching = false;
        _showResults = true;
      });
    } catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _searching = false;
        _searchError = e.toString().replaceFirst('Exception: ', '');
        _results = const [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        if (_selected != null) _SelectedCard(
          player: _selected!,
          onClear: _clearSelection,
        ) else if (_addingNew)
          _NewPlayerForm(
            formKey: _formKey,
            phoneController: _phoneController,
            nameController: _nameController,
            onCancel: _cancelAddNew,
            onConfirm: _confirmNewPlayer,
          )
        else ...[
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by name, phone or email',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: AppLogoLoader(size: 18),
                      ),
                    )
                  : (_searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _onQueryChanged('');
                          },
                        )
                      : null),
            ),
            onChanged: _onQueryChanged,
          ),
          if (_showResults) ...[
            const SizedBox(height: 8),
            _ResultsPanel(
              searching: _searching,
              error: _searchError,
              results: _results,
              query: _searchController.text.trim(),
              onSelect: _selectUser,
              onAddNew: _startAddNew,
            ),
          ] else ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _startAddNew,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Add new player'),
              ),
            ),
          ],
        ],
        // Hidden FormField so parent Form validation fails if empty.
        FormField<PickedPlayer>(
          validator: (_) {
            if (_selected == null) {
              return 'Select or add a player';
            }
            return null;
          },
          builder: (state) {
            if (state.hasError) {
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _SelectedCard extends StatelessWidget {
  const _SelectedCard({required this.player, required this.onClear});

  final PickedPlayer player;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary100,
            child: Text(
              player.displayLabel.isNotEmpty
                  ? player.displayLabel[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  player.phoneNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (player.fromSearch)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.verified_rounded,
                size: 18,
                color: AppColors.success700,
              ),
            ),
          IconButton(
            tooltip: 'Change',
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _NewPlayerForm extends StatelessWidget {
  const _NewPlayerForm({
    required this.formKey,
    required this.phoneController,
    required this.nameController,
    required this.onCancel,
    required this.onConfirm,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add new player',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'They are not registered yet — enter phone and full name.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '10-digit mobile',
                prefixText: '+91 ',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) => Validators.phone(v, maxLength: 10),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: Validators.name,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    child: const Text('Use player'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({
    required this.searching,
    required this.error,
    required this.results,
    required this.query,
    required this.onSelect,
    required this.onAddNew,
  });

  final bool searching;
  final String? error;
  final List<UserSummary> results;
  final String query;
  final ValueChanged<UserSummary> onSelect;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (searching && results.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: AppLogoLoader(size: 28, message: 'Searching…'),
        ),
      );
    } else if (error != null) {
      body = Padding(
        padding: const EdgeInsets.all(16),
        child: Text(error!, style: const TextStyle(color: AppColors.error)),
      );
    } else if (results.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          query.isEmpty
              ? 'Type to search players'
              : 'No players found for "$query"',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      );
    } else {
      body = ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: results.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final user = results[i];
          final avatar = user.profilePictureUrl;
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary100,
              backgroundImage:
                  avatar != null && avatar.trim().isNotEmpty
                      ? NetworkImage(avatar)
                      : null,
              child: avatar == null || avatar.trim().isEmpty
                  ? Text(
                      user.displayLabel.isNotEmpty
                          ? user.displayLabel[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            title: Text(
              user.displayLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              user.subtitle.isNotEmpty ? user.subtitle : (user.email ?? ''),
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () => onSelect(user),
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: body,
          ),
          const Divider(height: 1),
          ListTile(
            dense: true,
            leading: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.primary,
            ),
            title: const Text(
              'Add new player',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            subtitle: const Text(
              'Not in the list? Add with phone & name',
              style: TextStyle(fontSize: 12),
            ),
            onTap: onAddNew,
          ),
        ],
      ),
    );
  }
}
