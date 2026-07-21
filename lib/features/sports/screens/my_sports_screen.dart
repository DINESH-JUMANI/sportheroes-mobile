import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/api_state_view.dart';
import 'package:sportheroes_mobile/features/sports/models/sport_model.dart';
import 'package:sportheroes_mobile/features/sports/providers/sports_provider.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';

class MySportsScreen extends ConsumerStatefulWidget {
  const MySportsScreen({super.key});

  @override
  ConsumerState<MySportsScreen> createState() => _MySportsScreenState();
}

class _MySportsScreenState extends ConsumerState<MySportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(sportsProvider.notifier).loadSports();
      await ref.read(sportsProvider.notifier).loadMyProfiles();
    });
  }

  Future<void> _toggleSport(SportModel sport, bool alreadyAdded) async {
    final notifier = ref.read(sportsProvider.notifier);
    if (alreadyAdded) {
      final profile = ref
          .read(sportsProvider)
          .myProfiles
          .where((p) => p.sportId == sport.id)
          .firstOrNull;
      if (profile == null) return;
      final ok = await notifier.removeSportProfile(profile.id);
      if (!mounted) return;
      if (ok) {
        AppSnackbar.success(context, 'Removed ${sport.name}');
      } else {
        final err = ref.read(sportsProvider).actionState.errorOrNull;
        if (err != null) AppSnackbar.error(context, err);
      }
    } else {
      final hasPrimary = ref.read(sportsProvider).myProfiles.isEmpty;
      final ok = await notifier.addSportProfile(
        CreatePlayerProfileRequest(
          sportId: sport.id,
          skillLevel: 'beginner',
          isPrimarySport: hasPrimary,
        ),
      );
      if (!mounted) return;
      if (ok) {
        AppSnackbar.success(context, 'Added ${sport.name}');
      } else {
        final err = ref.read(sportsProvider).actionState.errorOrNull;
        if (err != null) AppSnackbar.error(context, err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sportsProvider);
    final mySportIds = state.myProfiles.map((p) => p.sportId).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('My Sports')),
      body: ApiStateView(
        isLoading: state.sportsState.isLoading,
        error: state.sportsState.errorOrNull,
        onRetry: () => ref.read(sportsProvider.notifier).loadSports(),
        isEmpty: state.sports.isEmpty && state.sportsState.isSuccess,
        emptyMessage: 'No sports available',
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.sports.length,
          itemBuilder: (context, i) {
            final sport = state.sports[i];
            final selected = mySportIds.contains(sport.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Text(sport.emoji, style: const TextStyle(fontSize: 28)),
                title: Text(
                  sport.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  sport.description ?? sport.code,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: state.actionState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : FilterChip(
                        label: Text(selected ? 'Added' : 'Add'),
                        selected: selected,
                        selectedColor: AppColors.primary100,
                        onSelected: (_) => _toggleSport(sport, selected),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
