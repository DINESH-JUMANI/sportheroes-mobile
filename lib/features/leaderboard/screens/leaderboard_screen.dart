import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/api_state_view.dart';
import 'package:sportheroes_mobile/features/leaderboard/widgets/leaderboard_row.dart';
import 'package:sportheroes_mobile/features/sports/providers/sports_provider.dart';
import 'package:sportheroes_mobile/features/statistics/providers/statistics_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String? _sportId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(sportsProvider.notifier).loadSports();
      final sports = ref.read(sportsProvider).sports;
      if (sports.isNotEmpty) {
        setState(() => _sportId = sports.first.id);
        await ref
            .read(statisticsProvider.notifier)
            .loadPlayerLeaderboard(sports.first.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sports = ref.watch(sportsProvider).sports;
    final stats = ref.watch(statisticsProvider);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Column(
        children: [
          if (sports.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: sports.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final sport = sports[i];
                  final selected = sport.id == _sportId;
                  return ChoiceChip(
                    label: Text(
                      sport.name,
                      style: TextStyle(
                        color: selected ? AppColors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.primary50,
                    checkmarkColor: AppColors.white,
                    side: BorderSide.none,
                    onSelected: (_) {
                      setState(() => _sportId = sport.id);
                      ref
                          .read(statisticsProvider.notifier)
                          .loadPlayerLeaderboard(sport.id);
                    },
                  );
                },
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (_sportId != null) {
                  await ref
                      .read(statisticsProvider.notifier)
                      .loadPlayerLeaderboard(_sportId!);
                }
              },
              child: ApiStateView(
                isLoading: stats.playerLeaderboardState.isLoading,
                error: stats.playerLeaderboardState.errorOrNull,
                onRetry: _sportId == null
                    ? null
                    : () => ref
                        .read(statisticsProvider.notifier)
                        .loadPlayerLeaderboard(_sportId!),
                isEmpty: stats.playerLeaderboard.isEmpty &&
                    stats.playerLeaderboardState.isSuccess,
                emptyMessage: _sportId == null
                    ? 'Load sports to see rankings'
                    : 'No rankings yet for this sport',
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stats.playerLeaderboard.length,
                  itemBuilder: (context, i) {
                    final row = stats.playerLeaderboard[i];
                    return LeaderboardRow(
                      rank: i + 1,
                      name: row.player?.displayLabel ?? row.userId,
                      sport: 'Pts ${row.currentRankingPoints}',
                      wins: row.matchesWon,
                      winPercentage: row.winPercentage,
                      points: row.currentRankingPoints,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
