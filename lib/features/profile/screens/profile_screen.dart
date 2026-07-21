import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).refreshMe();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final name = user?.displayLabel ?? 'Player';
    final phone = user?.phoneNumber ?? '';
    final city = [
      user?.city,
      user?.state,
      user?.country,
    ].where((e) => e != null && e.trim().isNotEmpty).join(', ');
    final pictureUrl = user?.profilePictureUrl;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.editProfile);
              if (!mounted) return;
              await ref.read(authProvider.notifier).refreshMe();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
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
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (phone.isNotEmpty)
                    Text(
                      phone,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  if (city.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      city,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.editProfile,
                        );
                        if (!mounted) return;
                        await ref.read(authProvider.notifier).refreshMe();
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Edit profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (user?.email != null && user!.email!.trim().isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user.email!),
              ),
            ),
        ],
      ),
    );
  }
}
