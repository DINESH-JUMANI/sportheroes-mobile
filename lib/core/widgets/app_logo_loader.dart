import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_assets.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';

/// Rotating SportHeroes logo spinner for inline / page loading states.
class AppLogoLoader extends StatefulWidget {
  const AppLogoLoader({super.key, this.size = 100, this.message});

  final double size;
  final String? message;

  @override
  State<AppLogoLoader> createState() => _AppLogoLoaderState();
}

class _AppLogoLoaderState extends State<AppLogoLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _controller,
          child: Image.asset(
            AppAssets.sportHeroesLogo,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            color: AppColors.primary,
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
