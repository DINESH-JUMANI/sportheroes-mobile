import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/features/sports/providers/sports_provider.dart';
import 'package:sportheroes_mobile/features/tournaments/models/tournament_model.dart';
import 'package:sportheroes_mobile/features/tournaments/providers/tournaments_provider.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  ConsumerState<CreateTournamentScreen> createState() =>
      _CreateTournamentScreenState();
}

class _CreateTournamentScreenState
    extends ConsumerState<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _venueController = TextEditingController();
  final _cityController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  String? _sportId;
  String _format = 'knockout';
  String _participantKind = 'individual';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sportsProvider.notifier).loadSports();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _cityController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sportId == null) {
      AppSnackbar.error(context, 'Select a sport');
      return;
    }

    final tournament = await ref.read(tournamentsProvider.notifier).create(
          CreateTournamentRequest(
            sportId: _sportId!,
            name: _nameController.text.trim(),
            format: _format,
            participantKind: _participantKind,
            startDate: _startDateController.text.trim(),
            endDate: _endDateController.text.trim().isEmpty
                ? null
                : _endDateController.text.trim(),
            venue: _venueController.text.trim().isEmpty
                ? null
                : _venueController.text.trim(),
            city: _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            country: 'India',
          ),
        );

    if (!mounted) return;
    if (tournament != null) {
      final msg = ref.read(tournamentsProvider).actionState.dataOrNull ??
          'Tournament created';
      AppSnackbar.success(context, msg);
      Navigator.pop(context);
    } else {
      final err = ref.read(tournamentsProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sports = ref.watch(sportsProvider).sports;
    final busy = ref.watch(tournamentsProvider).actionState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Tournament')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _sportId,
              decoration: const InputDecoration(labelText: 'Sport'),
              items: sports
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _sportId = v),
              validator: (v) => v == null ? 'Sport is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => Validators.required(v, fieldName: 'Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _format,
              decoration: const InputDecoration(labelText: 'Format'),
              items: const [
                DropdownMenuItem(value: 'knockout', child: Text('Knockout')),
                DropdownMenuItem(
                  value: 'round_robin',
                  child: Text('Round Robin'),
                ),
                DropdownMenuItem(value: 'league', child: Text('League')),
              ],
              onChanged: (v) => setState(() => _format = v ?? 'knockout'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _participantKind,
              decoration: const InputDecoration(labelText: 'Participants'),
              items: const [
                DropdownMenuItem(
                  value: 'individual',
                  child: Text('Individual'),
                ),
                DropdownMenuItem(value: 'team', child: Text('Team')),
              ],
              onChanged: (v) =>
                  setState(() => _participantKind = v ?? 'individual'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'Start date (YYYY-MM-DD)',
              ),
              validator: (v) => Validators.required(v, fieldName: 'Start date'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _endDateController,
              decoration: const InputDecoration(
                labelText: 'End date (optional)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _venueController,
              decoration: const InputDecoration(labelText: 'Venue'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: busy ? null : _submit,
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
