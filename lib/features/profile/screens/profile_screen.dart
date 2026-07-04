import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/mock/mock_data.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/profile/widgets/profile_stat_tile.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final mock = MockData.currentUser;

    final name = user?.displayLabel ?? mock['displayName'] as String;
    final phone = user?.phoneNumber ?? mock['phoneNumber'] as String;
    final city = user?.city ?? mock['city'] as String;
    final isLoggingOut = auth.logoutState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary100,
                    child: Text(
                      user?.avatarInitial ??
                          (name.isNotEmpty
                              ? name.substring(0, 1).toUpperCase()
                              : '?'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(phone, style: const TextStyle(color: AppColors.textSecondary)),
                  Text(city, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ProfileStatTile(
            label: 'Matches played',
            value: '${mock['matchesPlayed']}',
          ),
          ProfileStatTile(label: 'Wins', value: '${mock['wins']}'),
          ProfileStatTile(label: 'Losses', value: '${mock['losses']}'),
          ProfileStatTile(
            label: 'Win percentage',
            value: '${mock['winPercentage']}%',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: isLoggingOut
                  ? null
                  : () async {
                      await ref.read(authProvider.notifier).logout();
                      if (!context.mounted) return;
                      AppSnackbar.success(context, 'Logged out');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
              icon: isLoggingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
