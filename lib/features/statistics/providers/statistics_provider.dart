import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/models/api_state.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/features/statistics/models/statistics_model.dart';
import 'package:sportheroes_mobile/features/statistics/services/statistics_service.dart';

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService(ref.watch(dioClientProvider));
});

class StatisticsState {
  const StatisticsState({
    this.playerLeaderboardState =
        const ApiInitial<List<PlayerStatistics>>(),
    this.myStatsState = const ApiInitial<List<PlayerStatistics>>(),
    this.teamLeaderboardState = const ApiInitial<List<TeamStatistics>>(),
    this.selectedSportId,
  });

  final ApiState<List<PlayerStatistics>> playerLeaderboardState;
  final ApiState<List<PlayerStatistics>> myStatsState;
  final ApiState<List<TeamStatistics>> teamLeaderboardState;
  final String? selectedSportId;

  List<PlayerStatistics> get playerLeaderboard =>
      playerLeaderboardState.dataOrNull ?? const [];
  List<PlayerStatistics> get myStats => myStatsState.dataOrNull ?? const [];

  StatisticsState copyWith({
    ApiState<List<PlayerStatistics>>? playerLeaderboardState,
    ApiState<List<PlayerStatistics>>? myStatsState,
    ApiState<List<TeamStatistics>>? teamLeaderboardState,
    String? selectedSportId,
  }) {
    return StatisticsState(
      playerLeaderboardState:
          playerLeaderboardState ?? this.playerLeaderboardState,
      myStatsState: myStatsState ?? this.myStatsState,
      teamLeaderboardState: teamLeaderboardState ?? this.teamLeaderboardState,
      selectedSportId: selectedSportId ?? this.selectedSportId,
    );
  }
}

class StatisticsNotifier extends Notifier<StatisticsState> {
  @override
  StatisticsState build() => const StatisticsState();

  StatisticsService get _service => ref.read(statisticsServiceProvider);

  Future<void> loadPlayerLeaderboard(String sportId) async {
    state = state.copyWith(
      playerLeaderboardState: const ApiLoading(),
      selectedSportId: sportId,
    );
    try {
      final result = await _service.playerLeaderboard(sportId: sportId);
      state = state.copyWith(
        playerLeaderboardState: ApiSuccess(result.items),
      );
    } catch (e) {
      state = state.copyWith(
        playerLeaderboardState: ApiError(ApiHelpers.cleanError(e)),
      );
    }
  }

  Future<void> loadMyStats(String userId, {String? sportId}) async {
    state = state.copyWith(myStatsState: const ApiLoading());
    try {
      final stats = await _service.playerStats(userId, sportId: sportId);
      state = state.copyWith(myStatsState: ApiSuccess(stats));
    } catch (e) {
      state = state.copyWith(
        myStatsState: ApiError(ApiHelpers.cleanError(e)),
      );
    }
  }

  Future<void> loadTeamLeaderboard({String? sportId}) async {
    state = state.copyWith(teamLeaderboardState: const ApiLoading());
    try {
      final result = await _service.teamLeaderboard(sportId: sportId);
      state = state.copyWith(
        teamLeaderboardState: ApiSuccess(result.items),
      );
    } catch (e) {
      state = state.copyWith(
        teamLeaderboardState: ApiError(ApiHelpers.cleanError(e)),
      );
    }
  }
}

final statisticsProvider =
    NotifierProvider<StatisticsNotifier, StatisticsState>(
  StatisticsNotifier.new,
);
