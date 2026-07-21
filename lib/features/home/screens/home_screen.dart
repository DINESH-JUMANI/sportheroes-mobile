import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/home/widgets/match_preview_card.dart';
import 'package:sportheroes_mobile/features/home/widgets/stat_chip.dart';
import 'package:sportheroes_mobile/features/matches/providers/matches_provider.dart';
import 'package:sportheroes_mobile/features/statistics/providers/statistics_provider.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final notifierMatches = ref.read(matchesProvider.notifier);
    await Future.wait([
      notifierMatches.loadLiveMatches(),
      notifierMatches.loadRecentAndScheduled(),
    ]);

    final user = ref.read(authProvider).user;
    if (user != null) {
      await ref.read(statisticsProvider.notifier).loadMyStats(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final matchesState = ref.watch(matchesProvider);
    final statsState = ref.watch(statisticsProvider);

    final name = user?.displayLabel ?? 'Player';
    final myStats = statsState.myStats;
    final totals = myStats.fold<({int played, int wins, double winPct})>(
      (played: 0, wins: 0, winPct: 0),
      (acc, s) => (
        played: acc.played + s.matchesPlayed,
        wins: acc.wins + s.matchesWon,
        winPct: acc.winPct + s.winPercentage,
      ),
    );
    final winPct = myStats.isEmpty ? 0.0 : (totals.winPct / myStats.length);

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('SportHeroes'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Hey, $name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ready for your next match?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatChip(
                    label: 'Matches',
                    value: '${totals.played}',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatChip(
                    label: 'Wins',
                    value: '${totals.wins}',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatChip(
                    label: 'Win %',
                    value: winPct.toStringAsFixed(1),
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Live now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (matchesState.liveMatches.isEmpty)
              const Text(
                'No live matches',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              ...matchesState.liveMatches.map(
                (m) => GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.matchDetail,
                    arguments: m.id,
                  ),
                  child: MatchPreviewCard(
                    title: '${m.sideLabel('A')} vs ${m.sideLabel('B')}',
                    subtitle:
                        '${m.sport?.name ?? m.matchType} · Set ${m.currentSet?.setNumber ?? 1}',
                    trailing:
                        '${m.currentSet?.sideAScore ?? 0}-${m.currentSet?.sideBScore ?? 0}',
                    badge: 'LIVE',
                    badgeColor: AppColors.error,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Recent matches',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (matchesState.matches.isEmpty)
              const Text(
                'No matches yet',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              ...matchesState.matches.take(5).map(
                (m) => GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.matchDetail,
                    arguments: m.id,
                  ),
                  child: MatchPreviewCard(
                    title: '${m.sideLabel('A')} vs ${m.sideLabel('B')}',
                    subtitle:
                        '${m.sport?.name ?? m.matchType} · ${m.scheduledAt?.split('T').first ?? m.status}',
                    trailing: m.scoreSummary,
                    badge: m.resultLabel,
                    badgeColor: m.isLive
                        ? AppColors.error
                        : m.isCompleted
                            ? AppColors.success
                            : AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
