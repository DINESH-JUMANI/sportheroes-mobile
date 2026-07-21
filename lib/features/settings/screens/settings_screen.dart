import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';

/// Bottom-nav Settings hub: Profile, Stats, Help & Support, Logout.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final name = user?.displayLabel ?? 'Player';
    final phone = user?.phoneNumber ?? '';
    final pictureUrl = user?.profilePictureUrl;
    final isLoggingOut = auth.logoutState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary100,
                    backgroundImage:
                        pictureUrl != null && pictureUrl.trim().isNotEmpty
                            ? NetworkImage(pictureUrl)
                            : null,
                    child: pictureUrl == null || pictureUrl.trim().isEmpty
                        ? Text(
                            user?.avatarInitial ??
                                (name.isNotEmpty
                                    ? name.substring(0, 1).toUpperCase()
                                    : '?'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (phone.isNotEmpty)
                          Text(
                            phone,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            subtitle: 'View and edit your profile',
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          _SettingsTile(
            icon: Icons.bar_chart_rounded,
            title: 'Stats',
            subtitle: 'Your match performance',
            onTap: () => Navigator.pushNamed(context, AppRoutes.myStats),
          ),
          _SettingsTile(
            icon: Icons.support_agent_rounded,
            title: 'Help & Support',
            subtitle: 'Raise a ticket or view status',
            onTap: () => Navigator.pushNamed(context, AppRoutes.helpSupport),
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
                      final msg = ref.read(authProvider).logoutState.dataOrNull;
                      AppSnackbar.success(
                        context,
                        msg ?? 'Logged out',
                      );
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              icon: isLoggingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.greyscale60,
        ),
      ),
    );
  }
}
