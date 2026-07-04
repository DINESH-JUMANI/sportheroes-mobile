import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.name,
    required this.sport,
    required this.wins,
    required this.winPercentage,
    required this.points,
  });

  final int rank;
  final String name;
  final String sport;
  final int wins;
  final double winPercentage;
  final int points;

  Color get _rankColor => switch (rank) {
    1 => const Color(0xFFFFD700),
    2 => const Color(0xFFC0C0C0),
    3 => const Color(0xFFCD7F32),
    _ => AppColors.primary100,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _rankColor,
          child: Text(
            '#$rank',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: rank <= 3 ? AppColors.grey900 : AppColors.primary,
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('$sport · $wins wins · $winPercentage%'),
        trailing: Text(
          '$points',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
