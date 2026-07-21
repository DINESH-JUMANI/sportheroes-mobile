import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/api_state_view.dart';
import 'package:sportheroes_mobile/features/tournaments/providers/tournaments_provider.dart';
import 'package:sportheroes_mobile/features/tournaments/widgets/tournament_card.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';

class TournamentsScreen extends ConsumerStatefulWidget {
  const TournamentsScreen({super.key});

  @override
  ConsumerState<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends ConsumerState<TournamentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tournamentsProvider.notifier).loadTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tournamentsProvider);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Tournaments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.createTournament),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(tournamentsProvider.notifier).loadTournaments(),
        child: ApiStateView(
          isLoading: state.listState.isLoading,
          error: state.listState.errorOrNull,
          onRetry: () =>
              ref.read(tournamentsProvider.notifier).loadTournaments(),
          isEmpty: state.tournaments.isEmpty && state.listState.isSuccess,
          emptyMessage: 'No tournaments yet.',
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.tournaments.length,
            itemBuilder: (context, i) {
              final t = state.tournaments[i];
              return TournamentCard(
                name: t.name,
                sport: t.sport?.name ?? 'Sport',
                format: t.formatLabel,
                status: t.statusLabel,
                participants: t.maxParticipants ?? 0,
                venue: t.venue ?? t.city ?? '—',
                dateRange: t.dateRange,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.tournamentDetail,
                  arguments: t.id,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
