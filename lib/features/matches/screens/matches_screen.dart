import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/api_state_view.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/matches/providers/matches_provider.dart';
import 'package:sportheroes_mobile/features/matches/widgets/match_list_tile.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/date_formatter.dart';

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
    _tabs.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTab(0));
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    _loadTab(_tabs.index);
  }

  Future<void> _loadTab(int index) async {
    final phone = ref.read(authProvider).user?.phoneNumber;
    final notifier = ref.read(matchesProvider.notifier);
    if (index == 0) {
      await notifier.loadRecentAndScheduled();
    } else if (index == 1) {
      await notifier.loadLiveMatches();
    } else if (phone != null && phone.isNotEmpty) {
      await notifier.loadMyMatches(phone);
    }
  }

  Future<void> _openCreate() async {
    await Navigator.pushNamed(context, AppRoutes.createMatch);
    if (mounted) await _loadTab(_tabs.index);
  }

  String _dateLine(String? scheduledAt, String formatLabel, String venue) {
    final parts = <String>[formatLabel];
    if (venue.isNotEmpty) parts.add(venue);
    if (scheduledAt != null && scheduledAt.isNotEmpty) {
      parts.add(DateFormatter.formatToDateTimeSeconds(scheduledAt));
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchesProvider);
    final phone = ref.watch(authProvider).user?.phoneNumber;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Matches'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Live'),
            Tab(text: 'My Matches'),
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
              isLoading: state.listState.isLoading || state.listState.isInitial,
              loadingMessage: 'Loading matches…',
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
                    opponent: m.matchupLabel,
                    score: m.scoreSummary,
                    result: m.resultLabel,
                    date: _dateLine(
                      m.scheduledAt,
                      m.formatLabel,
                      m.venueDisplay,
                    ),
                    isLive: m.isLive,
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.matchDetail,
                        arguments: m.id,
                      );
                      if (mounted) await _loadTab(0);
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
              isLoading: state.liveState.isLoading || state.liveState.isInitial,
              loadingMessage: 'Loading live matches…',
              error: state.liveState.errorOrNull,
              onRetry: () =>
                  ref.read(matchesProvider.notifier).loadLiveMatches(),
              isEmpty: state.liveMatches.isEmpty && state.liveState.isSuccess,
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
                    opponent: m.matchupLabel,
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
                      if (mounted) await _loadTab(1);
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
                    isLoading:
                        state.myState.isLoading || state.myState.isInitial,
                    loadingMessage: 'Loading your matches…',
                    error: state.myState.errorOrNull,
                    onRetry: () =>
                        ref.read(matchesProvider.notifier).loadMyMatches(phone),
                    isEmpty: state.myMatches.isEmpty && state.myState.isSuccess,
                    emptyMessage: 'You have not played any matches yet.',
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: state.myMatches.length,
                      itemBuilder: (context, i) {
                        final m = state.myMatches[i];
                        return MatchListTile(
                          sport: m.sport?.name ?? m.matchType,
                          opponent: m.matchupLabel,
                          score: m.scoreSummary,
                          result: m.resultLabel,
                          date: _dateLine(
                            m.scheduledAt,
                            m.formatLabel,
                            m.venueDisplay,
                          ),
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
