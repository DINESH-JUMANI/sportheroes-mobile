import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/mock/mock_data.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/home/widgets/match_preview_card.dart';
import 'package:sportheroes_mobile/features/home/widgets/stat_chip.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final name = user?.displayLabel ?? MockData.currentUser['displayName'] as String;
    final stats = MockData.currentUser;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('SportHeroes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.groups_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.teams),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hey, $name 👋',
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
                  value: '${stats['matchesPlayed']}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatChip(
                  label: 'Wins',
                  value: '${stats['wins']}',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatChip(
                  label: 'Win %',
                  value: '${stats['winPercentage']}',
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Sports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.sports.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final sport = MockData.sports[i];
                return Container(
                  width: 110,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sport['emoji'] as String,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sport['name'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Live now',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...MockData.liveMatches.map(
            (m) => MatchPreviewCard(
              title: '${m['playerA']} vs ${m['playerB']}',
              subtitle: '${m['sport']} · ${m['set']}',
              trailing: '${m['scoreA']}-${m['scoreB']}',
              badge: 'LIVE',
              badgeColor: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent matches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...MockData.recentMatches.map(
            (m) => MatchPreviewCard(
              title: 'vs ${m['opponent']}',
              subtitle: '${m['sport']} · ${m['date']}',
              trailing: m['score'] as String,
              badge: m['result'] as String,
              badgeColor: m['result'] == 'Won'
                  ? AppColors.success
                  : m['result'] == 'Lost'
                  ? AppColors.error
                  : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
