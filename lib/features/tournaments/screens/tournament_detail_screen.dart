import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/api_state_view.dart';
import 'package:sportheroes_mobile/core/widgets/app_loading_overlay.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/tournaments/providers/tournaments_provider.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  const TournamentDetailScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  ConsumerState<TournamentDetailScreen> createState() =>
      _TournamentDetailScreenState();
}

class _TournamentDetailScreenState
    extends ConsumerState<TournamentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(tournamentsProvider.notifier);
      notifier.loadTournament(widget.tournamentId);
      notifier.loadParticipants(widget.tournamentId);
      notifier.loadStandings(widget.tournamentId);
    });
  }

  Future<void> _register() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      AppSnackbar.error(context, 'Login required');
      return;
    }
    if (user.phoneNumber.trim().isEmpty) {
      AppSnackbar.error(context, 'Your profile has no phone number');
      return;
    }

    final ok = await AppLoader.during(
      context,
      () => ref.read(tournamentsProvider.notifier).registerSelf(
            tournamentId: widget.tournamentId,
            phoneNumber: user.phoneNumber,
            fullName: user.fullName ?? user.displayName,
          ),
      message: 'Registering…',
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, 'Registered successfully');
    } else {
      final err = ref.read(tournamentsProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tournamentsProvider);
    final t = state.detailState.dataOrNull;
    final participants = state.participantsState.dataOrNull ?? const [];
    final standings = state.standingsState.dataOrNull ?? const [];

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: Text(t?.name ?? 'Tournament')),
      body: ApiStateView(
        isLoading: state.detailState.isLoading,
        error: state.detailState.errorOrNull,
        onRetry: () => ref
            .read(tournamentsProvider.notifier)
            .loadTournament(widget.tournamentId),
        child: t == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('${t.sport?.name ?? 'Sport'} · ${t.formatLabel}'),
                          Text('Status: ${t.statusLabel}'),
                          Text(t.dateRange),
                          if (t.venue != null) Text(t.venue!),
                          if (t.description != null) ...[
                            const SizedBox(height: 8),
                            Text(t.description!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (t.status == 'registration_open') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            state.actionState.isLoading ? null : _register,
                        icon: const Icon(Icons.how_to_reg_rounded),
                        label: const Text('Register with my phone'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Participants (${participants.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (participants.isEmpty)
                    const Text(
                      'No participants yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  else
                    ...participants.map(
                      (p) => Card(
                        child: ListTile(
                          title: Text(p.userId ?? p.teamId ?? p.id),
                          subtitle: Text(p.status),
                          trailing: p.seedNumber != null
                              ? Text('Seed ${p.seedNumber}')
                              : null,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Standings',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (standings.isEmpty)
                    const Text(
                      'Standings unavailable',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  else
                    ...standings.map(
                      (s) => Card(
                        child: ListTile(
                          leading: Text('#${s.position ?? '-'}'),
                          title: Text(s.userId ?? s.teamId ?? s.id),
                          subtitle: Text(
                            '${s.wins}W ${s.losses}L · ${s.matchesPlayed} played',
                          ),
                          trailing: Text(
                            '${s.points} pts',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
