import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconName,
  });

  final String title;
  final String subtitle;
  final String iconName;

  IconData get _icon {
    return switch (iconName) {
      'sports_score' => Icons.sports_score,
      'person' => Icons.person_outline,
      'emoji_events' => Icons.emoji_events_outlined,
      _ => Icons.sports,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(_icon, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
