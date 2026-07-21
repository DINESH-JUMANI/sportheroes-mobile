import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/app_logo_loader.dart';

class ApiStateView extends StatelessWidget {
  const ApiStateView({
    super.key,
    required this.isLoading,
    this.error,
    this.onRetry,
    required this.child,
    this.emptyMessage,
    this.isEmpty = false,
    this.loadingMessage,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final Widget child;
  final String? emptyMessage;
  final bool isEmpty;
  final String? loadingMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: AppLogoLoader(
          message: loadingMessage ?? 'Loading…',
        ),
      );
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.error50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 48,
                color: AppColors.grey400,
              ),
              const SizedBox(height: 12),
              Text(
                emptyMessage ?? 'Nothing here yet',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return child;
  }
}
