import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/features/home/screens/home_screen.dart';
import 'package:sportheroes_mobile/features/home/widgets/create_action_sheet.dart';
import 'package:sportheroes_mobile/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:sportheroes_mobile/features/search/screens/search_screen.dart';
import 'package:sportheroes_mobile/features/settings/screens/settings_screen.dart';

class HomeShellScreen extends StatelessWidget {
  const HomeShellScreen({super.key});

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      builder: (_) => const CreateActionSheet(),
    );
  }

  List<PersistentTabConfig> _tabs() => [
        PersistentTabConfig(
          screen: const HomeScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.home_rounded),
            inactiveIcon: const Icon(Icons.home_outlined),
            title: 'Home',
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: AppColors.grey500,
          ),
        ),
        PersistentTabConfig(
          screen: const SearchScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.search_rounded),
            inactiveIcon: const Icon(Icons.search_rounded),
            title: 'Search',
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: AppColors.grey500,
          ),
        ),
        PersistentTabConfig.noScreen(
          item: ItemConfig(
            icon: const Icon(Icons.add_rounded, color: AppColors.white),
            inactiveIcon: const Icon(Icons.add_rounded, color: AppColors.white),
            title: 'Add',
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: AppColors.white,
          ),
          onPressed: _openCreateSheet,
        ),
        PersistentTabConfig(
          screen: const LeaderboardScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.leaderboard_rounded),
            inactiveIcon: const Icon(Icons.leaderboard_outlined),
            title: 'Ranks',
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: AppColors.grey500,
          ),
        ),
        PersistentTabConfig(
          screen: const SettingsScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.settings_rounded),
            inactiveIcon: const Icon(Icons.settings_outlined),
            title: 'Settings',
            activeForegroundColor: AppColors.primary,
            inactiveForegroundColor: AppColors.grey500,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: _tabs(),
      navBarBuilder: (navBarConfig) => Style13BottomNavBar(
        navBarConfig: navBarConfig,
        middleItemSize: 56,
        navBarDecoration: const NavBarDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.secondary,
    );
  }
}
