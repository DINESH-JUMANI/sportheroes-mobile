import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/mock/mock_data.dart';
import 'package:sportheroes_mobile/features/leaderboard/widgets/leaderboard_row.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.leaderboard.length,
        itemBuilder: (context, i) {
          final row = MockData.leaderboard[i];
          return LeaderboardRow(
            rank: row['rank'] as int,
            name: row['name'] as String,
            sport: row['sport'] as String,
            wins: row['wins'] as int,
            winPercentage: row['winPercentage'] as double,
            points: row['points'] as int,
          );
        },
      ),
    );
  }
}
