import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/app_logo_loader.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/profile/widgets/profile_stat_tile.dart';
import 'package:sportheroes_mobile/features/statistics/providers/statistics_provider.dart';

class MyStatsScreen extends ConsumerStatefulWidget {
  const MyStatsScreen({super.key});

  @override
  ConsumerState<MyStatsScreen> createState() => _MyStatsScreenState();
}

class _MyStatsScreenState extends ConsumerState<MyStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(statisticsProvider.notifier).loadMyStats(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(statisticsProvider);
    final myStats = statsState.myStats;

    final totals = myStats.fold<({int played, int wins, int losses})>(
      (played: 0, wins: 0, losses: 0),
      (acc, s) => (
        played: acc.played + s.matchesPlayed,
        wins: acc.wins + s.matchesWon,
        losses: acc.losses + s.matchesLost,
      ),
    );
    final winPct =
        totals.played == 0 ? 0.0 : (totals.wins / totals.played) * 100;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(title: const Text('Stats')),
      body: RefreshIndicator(
        onRefresh: () async {
          final user = ref.read(authProvider).user;
          if (user != null) {
            await ref.read(statisticsProvider.notifier).loadMyStats(user.id);
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (statsState.myStatsState.isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: AppLogoLoader(size: 48, message: 'Loading stats…'),
                ),
              )
            else ...[
              ProfileStatTile(
                label: 'Matches played',
                value: '${totals.played}',
              ),
              ProfileStatTile(label: 'Wins', value: '${totals.wins}'),
              ProfileStatTile(label: 'Losses', value: '${totals.losses}'),
              ProfileStatTile(
                label: 'Win percentage',
                value: '${winPct.toStringAsFixed(1)}%',
              ),
              if (myStats.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'By sport',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 8),
                  ...myStats.map(
                  (s) => ProfileStatTile(
                    label: s.sportId.length > 8
                        ? 'Sport ${s.sportId.substring(0, 8)}…'
                        : 'Sport',
                    value: '${s.matchesWon}W / ${s.matchesPlayed}P',
                  ),
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Text(
                    'No stats yet. Play a match to see your performance here.',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
