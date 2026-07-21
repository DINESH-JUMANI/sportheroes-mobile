import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/api_state_view.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/matches/providers/matches_provider.dart';
import 'package:sportheroes_mobile/features/matches/widgets/match_list_tile.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final phone = ref.read(authProvider).user?.phoneNumber;
    await Future.wait([
      ref.read(matchesProvider.notifier).loadRecentAndScheduled(),
      ref.read(matchesProvider.notifier).loadLiveMatches(),
      if (phone != null && phone.isNotEmpty)
        ref.read(matchesProvider.notifier).loadMyMatches(phone),
    ]);
  }

  Future<void> _openCreate() async {
    await Navigator.pushNamed(context, AppRoutes.createMatch);
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchesProvider);
    final phone = ref.watch(authProvider).user?.phoneNumber;
    // When "My" is selected we reuse listState via loadMyMatches.
    // For All we use loadRecentAndScheduled into listState.
    // Live uses liveState.
    // Switching tabs should reload appropriate data.
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('Matches'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          onTap: (i) async {
            if (i == 0) {
              await ref.read(matchesProvider.notifier).loadRecentAndScheduled();
            } else if (i == 1) {
              await ref.read(matchesProvider.notifier).loadLiveMatches();
            } else if (phone != null && phone.isNotEmpty) {
              await ref.read(matchesProvider.notifier).loadMyMatches(phone);
            }
          },
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Live'),
            Tab(text: 'My'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('New Match'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          RefreshIndicator(
            onRefresh: () =>
                ref.read(matchesProvider.notifier).loadRecentAndScheduled(),
            child: ApiStateView(
              isLoading: state.listState.isLoading,
              error: state.listState.errorOrNull,
              onRetry: () =>
                  ref.read(matchesProvider.notifier).loadRecentAndScheduled(),
              isEmpty: state.matches.isEmpty && state.listState.isSuccess,
              emptyMessage: 'No matches yet. Create your first match.',
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: state.matches.length,
                itemBuilder: (context, i) {
                  final m = state.matches[i];
                  return MatchListTile(
                    sport: m.sport?.name ?? m.matchType,
                    opponent: '${m.sideLabel('A')} vs ${m.sideLabel('B')}',
                    score: m.scoreSummary,
                    result: m.resultLabel,
                    date: [
                      m.formatLabel,
                      if (m.venueDisplay.isNotEmpty) m.venueDisplay,
                      m.scheduledAt?.split('T').first,
                    ].whereType<String>().where((e) => e.isNotEmpty).join(' · '),
                    isLive: m.isLive,
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.matchDetail,
                        arguments: m.id,
                      );
                      if (mounted) await _refresh();
                    },
                  );
                },
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: () =>
                ref.read(matchesProvider.notifier).loadLiveMatches(),
            child: ApiStateView(
              isLoading: state.liveState.isLoading,
              error: state.liveState.errorOrNull,
              onRetry: () =>
                  ref.read(matchesProvider.notifier).loadLiveMatches(),
              isEmpty:
                  state.liveMatches.isEmpty && state.liveState.isSuccess,
              emptyMessage: 'No live matches right now.',
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: state.liveMatches.length,
                itemBuilder: (context, i) {
                  final m = state.liveMatches[i];
                  final current = m.currentSet;
                  return MatchListTile(
                    sport: m.sport?.name ?? m.matchType,
                    opponent: '${m.sideLabel('A')} vs ${m.sideLabel('B')}',
                    score: current == null
                        ? m.scoreSummary
                        : '${current.sideAScore}-${current.sideBScore}',
                    result: 'LIVE',
                    date: [
                      m.formatLabel,
                      'Set ${current?.setNumber ?? 1}',
                      if (m.venueDisplay.isNotEmpty) m.venueDisplay,
                    ].join(' · '),
                    isLive: true,
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.matchDetail,
                        arguments: m.id,
                      );
                      if (mounted) await _refresh();
                    },
                  );
                },
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: () async {
              if (phone == null || phone.isEmpty) return;
              await ref.read(matchesProvider.notifier).loadMyMatches(phone);
            },
            child: phone == null || phone.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      Center(
                        child: Text(
                          'Sign in with a phone number to see your matches.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  )
                : ApiStateView(
                    isLoading: state.listState.isLoading,
                    error: state.listState.errorOrNull,
                    onRetry: () => ref
                        .read(matchesProvider.notifier)
                        .loadMyMatches(phone),
                    isEmpty:
                        state.matches.isEmpty && state.listState.isSuccess,
                    emptyMessage: 'You have not played any matches yet.',
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: state.matches.length,
                      itemBuilder: (context, i) {
                        final m = state.matches[i];
                        return MatchListTile(
                          sport: m.sport?.name ?? m.matchType,
                          opponent:
                              '${m.sideLabel('A')} vs ${m.sideLabel('B')}',
                          score: m.scoreSummary,
                          result: m.resultLabel,
                          date: [
                            m.formatLabel,
                            if (m.venueDisplay.isNotEmpty) m.venueDisplay,
                            m.scheduledAt?.split('T').first,
                          ]
                              .whereType<String>()
                              .where((e) => e.isNotEmpty)
                              .join(' · '),
                          isLive: m.isLive,
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.matchDetail,
                              arguments: m.id,
                            );
                            if (mounted) {
                              await ref
                                  .read(matchesProvider.notifier)
                                  .loadMyMatches(phone);
                            }
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
