import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/app_loading_overlay.dart';
import 'package:sportheroes_mobile/core/widgets/app_logo_loader.dart';
import 'package:sportheroes_mobile/features/matches/models/match_model.dart';
import 'package:sportheroes_mobile/features/matches/providers/matches_provider.dart';
import 'package:sportheroes_mobile/features/sports/models/sport_model.dart';
import 'package:sportheroes_mobile/features/sports/providers/sports_provider.dart';
import 'package:sportheroes_mobile/features/teams/providers/teams_provider.dart';
import 'package:sportheroes_mobile/features/venues/models/venue_model.dart';
import 'package:sportheroes_mobile/features/venues/widgets/venue_picker_sheet.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();

  // Singles / doubles — all players chosen explicitly (organizer not auto-added)
  final _sideA1Phone = TextEditingController();
  final _sideA1Name = TextEditingController();
  final _sideA2Phone = TextEditingController();
  final _sideA2Name = TextEditingController();
  final _sideB1Phone = TextEditingController();
  final _sideB1Name = TextEditingController();
  final _sideB2Phone = TextEditingController();
  final _sideB2Name = TextEditingController();

  SportModel? _selectedSport;
  String? _matchType;
  int _bestOfSets = 3;
  String? _teamAId;
  String? _teamBId;
  VenueModel? _selectedVenue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sportsProvider.notifier).loadSports();
      ref.read(teamsProvider.notifier).loadTeams();
    });
  }

  @override
  void dispose() {
    _sideA1Phone.dispose();
    _sideA1Name.dispose();
    _sideA2Phone.dispose();
    _sideA2Name.dispose();
    _sideB1Phone.dispose();
    _sideB1Name.dispose();
    _sideB2Phone.dispose();
    _sideB2Name.dispose();
    super.dispose();
  }

  String _e164(String local) {
    final digits = local.replaceAll(RegExp(r'\D'), '');
    return '+91$digits';
  }

  String _matchTypeLabel(String type) => switch (type) {
        'singles' => 'Singles',
        'doubles' => 'Doubles',
        'team' => 'Team',
        _ => type,
      };

  CreateMatchParticipant _player({
    required String side,
    required TextEditingController phone,
    required TextEditingController name,
  }) {
    return CreateMatchParticipant(
      side: side,
      phoneNumber: _e164(phone.text.trim()),
      fullName: name.text.trim().isEmpty ? null : name.text.trim(),
    );
  }

  Future<void> _pickVenue() async {
    final picked = await showModalBottomSheet<VenueModel?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => VenuePickerSheet(selectedId: _selectedVenue?.id),
    );
    // null from sheet can mean "No venue" or dismiss — use a sentinel?
    // VenuePickerSheet pops null for "No venue". Dismiss also returns null.
    // We can't distinguish — clearing on dismiss is ok enough, or we only set
    // when non-null and have clear button.
    if (!mounted) return;
    if (picked != null) {
      setState(() => _selectedVenue = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSport == null) {
      AppSnackbar.error(context, 'Select a sport');
      return;
    }
    if (_matchType == null) {
      AppSnackbar.error(context, 'Select a match type');
      return;
    }

    late final List<CreateMatchParticipant> participants;

    if (_matchType == 'team') {
      if (_teamAId == null || _teamBId == null) {
        AppSnackbar.error(context, 'Select both teams');
        return;
      }
      if (_teamAId == _teamBId) {
        AppSnackbar.error(context, 'Teams must be different');
        return;
      }
      participants = [
        CreateMatchParticipant(side: 'A', teamId: _teamAId),
        CreateMatchParticipant(side: 'B', teamId: _teamBId),
      ];
    } else if (_matchType == 'doubles') {
      participants = [
        _player(side: 'A', phone: _sideA1Phone, name: _sideA1Name),
        _player(side: 'A', phone: _sideA2Phone, name: _sideA2Name),
        _player(side: 'B', phone: _sideB1Phone, name: _sideB1Name),
        _player(side: 'B', phone: _sideB2Phone, name: _sideB2Name),
      ];
    } else {
      participants = [
        _player(side: 'A', phone: _sideA1Phone, name: _sideA1Name),
        _player(side: 'B', phone: _sideB1Phone, name: _sideB1Name),
      ];
    }

    final match = await AppLoader.during(
      context,
      () => ref.read(matchesProvider.notifier).createMatch(
            CreateMatchRequest(
              sportCode: _selectedSport!.code,
              matchType: _matchType!,
              bestOfSets: _bestOfSets,
              venueId: _selectedVenue?.id,
              participants: participants,
            ),
          ),
      message: 'Creating match…',
    );

    if (!mounted) return;
    if (match != null) {
      final msg =
          ref.read(matchesProvider).actionState.dataOrNull ?? 'Match created';
      AppSnackbar.success(context, msg);
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.matchDetail,
        arguments: match.id,
      );
    } else {
      final err = ref.read(matchesProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  Widget _phoneField({
    required TextEditingController phone,
    required TextEditingController name,
    required String phoneLabel,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            labelText: phoneLabel,
            hintText: '10-digit mobile',
            prefixText: '+91 ',
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          validator: (v) => Validators.phone(v, maxLength: 10),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Full name (if new)',
            hintText: 'Required only for new players',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sports = ref.watch(sportsProvider).sports;
    final teams = ref.watch(teamsProvider).teams;
    final sportCode = _selectedSport?.code ?? '';
    final rulesAsync =
        sportCode.isNotEmpty ? ref.watch(sportRulesProvider(sportCode)) : null;
    final matchTypes = rulesAsync?.value?.supportedMatchTypes ?? const [];

    if (_matchType == null && matchTypes.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _matchType = matchTypes.first);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Create Match')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<SportModel>(
              initialValue: _selectedSport,
              decoration: const InputDecoration(
                labelText: 'Sport',
                prefixIcon: Icon(Icons.sports_tennis_rounded),
              ),
              items: sports
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text('${s.emoji} ${s.name}'),
                    ),
                  )
                  .toList(),
              onChanged: (sport) {
                setState(() {
                  _selectedSport = sport;
                  _matchType = null;
                  _teamAId = null;
                  _teamBId = null;
                });
              },
              validator: (v) => v == null ? 'Sport is required' : null,
            ),
            if (rulesAsync?.isLoading == true) ...[
              const SizedBox(height: 20),
              const Center(
                child: AppLogoLoader(size: 40, message: 'Loading sport rules…'),
              ),
            ],
            if (matchTypes.isNotEmpty) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _matchType,
                decoration: const InputDecoration(
                  labelText: 'Match type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: matchTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(_matchTypeLabel(t)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _matchType = v),
                validator: (v) => v == null ? 'Match type is required' : null,
              ),
            ],
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              initialValue: _bestOfSets == 2 || _bestOfSets == 4
                  ? 3
                  : _bestOfSets,
              decoration: const InputDecoration(
                labelText: 'Number of sets',
                prefixIcon: Icon(Icons.format_list_numbered_rounded),
                helperText: 'Best of 1, 3 or 5 (first to majority wins)',
              ),
              items: const [1, 3, 5].map((n) {
                final toWin = (n + 1) ~/ 2;
                return DropdownMenuItem(
                  value: n,
                  child: Text('Best of $n · first to $toWin'),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _bestOfSets = v);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.grey200),
              ),
              leading: const Icon(Icons.place_rounded, color: AppColors.primary),
              title: Text(
                _selectedVenue?.name ?? 'Venue (optional)',
                style: TextStyle(
                  fontWeight: _selectedVenue != null
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
              subtitle: _selectedVenue != null
                  ? Text(_selectedVenue!.subtitle)
                  : const Text('Pick from venues or leave empty'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedVenue != null)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _selectedVenue = null),
                    ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              onTap: _pickVenue,
            ),
            const SizedBox(height: 20),
            if (_matchType == 'team') ...[
              DropdownButtonFormField<String>(
                initialValue: _teamAId,
                decoration: const InputDecoration(
                  labelText: 'Team A',
                  prefixIcon: Icon(Icons.groups_rounded),
                ),
                items: teams
                    .map(
                      (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _teamAId = v),
                validator: (v) => v == null ? 'Select team A' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _teamBId,
                decoration: const InputDecoration(
                  labelText: 'Team B',
                  prefixIcon: Icon(Icons.groups_rounded),
                ),
                items: teams
                    .map(
                      (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _teamBId = v),
                validator: (v) => v == null ? 'Select team B' : null,
              ),
            ] else if (_matchType != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary25,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Choose every player by phone. You are the organizer only — you are not added as a player unless you enter your own number.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
              Text(
                'Side A',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              _phoneField(
                phone: _sideA1Phone,
                name: _sideA1Name,
                phoneLabel: _matchType == 'doubles'
                    ? 'Player 1 phone (Side A)'
                    : 'Player A phone',
              ),
              if (_matchType == 'doubles')
                _phoneField(
                  phone: _sideA2Phone,
                  name: _sideA2Name,
                  phoneLabel: 'Player 2 phone (Side A)',
                ),
              Text(
                'Side B',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              _phoneField(
                phone: _sideB1Phone,
                name: _sideB1Name,
                phoneLabel: _matchType == 'doubles'
                    ? 'Player 1 phone (Side B)'
                    : 'Player B phone',
              ),
              if (_matchType == 'doubles')
                _phoneField(
                  phone: _sideB2Phone,
                  name: _sideB2Name,
                  phoneLabel: 'Player 2 phone (Side B)',
                ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: rulesAsync?.isLoading == true ? null : _submit,
                child: const Text('Create Match'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
