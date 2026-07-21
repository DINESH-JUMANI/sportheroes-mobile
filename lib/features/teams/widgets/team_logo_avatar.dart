import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/features/teams/providers/teams_provider.dart';

class TeamLogoAvatar extends ConsumerWidget {
  const TeamLogoAvatar({
    super.key,
    required this.teamId,
    required this.name,
    this.hasLogo = false,
    this.radius = 24,
  });

  final String teamId;
  final String name;
  final bool hasLogo;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!hasLogo) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary50,
        child: Text(
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: radius * 0.7,
          ),
        ),
      );
    }

    final logoAsync = ref.watch(teamLogoProvider(teamId));

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary50,
      child: logoAsync.when(
        loading: () => SizedBox(
          width: radius,
          height: radius,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (_, _) => Text(
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: radius * 0.7,
          ),
        ),
        data: (bytes) {
          if (bytes == null || bytes.isEmpty) {
            return Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: radius * 0.7,
              ),
            );
          }
          return ClipOval(
            child: Image.memory(
              Uint8List.fromList(bytes),
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
