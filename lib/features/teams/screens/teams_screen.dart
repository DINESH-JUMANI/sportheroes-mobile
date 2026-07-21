import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/app_logo_loader.dart';
import 'package:sportheroes_mobile/features/teams/providers/teams_provider.dart';
import 'package:sportheroes_mobile/features/teams/widgets/team_card.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';

class TeamsScreen extends ConsumerStatefulWidget {
  const TeamsScreen({super.key});

  @override
  ConsumerState<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends ConsumerState<TeamsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamsProvider.notifier).loadTeams();
    });
  }

  Future<void> _refresh() => ref.read(teamsProvider.notifier).loadTeams();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamsProvider);
    final teams = state.teams;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('Teams'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.createTeam);
          if (mounted) await _refresh();
        },
        icon: const Icon(Icons.group_add_rounded),
        label: const Text('Create Team'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: state.listState.isLoading && teams.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 160),
                  Center(
                    child: AppLogoLoader(
                      message: 'Loading teams…',
                    ),
                  ),
                ],
              )
            : state.listState.isError
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            state.listState.errorOrNull ?? 'Error',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _refresh,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : teams.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No teams yet.\nCreate one to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: teams.length,
                itemBuilder: (context, i) {
                  final team = teams[i];
                  return TeamCard(
                    teamId: team.id,
                    name: team.name,
                    shortName: team.shortName,
                    captain: team.captainName,
                    members: team.memberCount,
                    hasLogo: team.hasLogo,
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.teamDetail,
                        arguments: team.id,
                      );
                      if (mounted) await _refresh();
                    },
                  );
                },
              ),
      ),
    );
  }
}
