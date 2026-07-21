import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';

class MatchListTile extends StatelessWidget {
  const MatchListTile({
    super.key,
    required this.sport,
    required this.opponent,
    required this.score,
    required this.result,
    required this.date,
    this.isLive = false,
    this.onTap,
  });

  final String sport;
  final String opponent;
  final String score;
  final String result;
  final String date;
  final bool isLive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badgeColor = isLive || result == 'LIVE'
        ? AppColors.error
        : result.toLowerCase().contains('won')
            ? AppColors.success
            : result == 'Upcoming'
                ? AppColors.warning
                : AppColors.grey500;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          opponent,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('$sport · $date'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              score,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            Text(
              result,
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
