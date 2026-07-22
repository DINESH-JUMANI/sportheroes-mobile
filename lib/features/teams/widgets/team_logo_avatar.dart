import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';

class TeamLogoAvatar extends StatelessWidget {
  const TeamLogoAvatar({
    super.key,
    required this.name,
    this.logoUrl,
    this.hasLogo = false,
    this.radius = 24,
  });

  final String name;
  final String? logoUrl;
  final bool hasLogo;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl?.trim();
    final showNetwork =
        hasLogo && url != null && url.isNotEmpty;

    if (!showNetwork) {
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

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary50,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, _) {},
    );
  }
}
