import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/models/api_result.dart';
import 'package:sportheroes_mobile/core/models/api_state.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/features/matches/models/match_model.dart';
import 'package:sportheroes_mobile/features/matches/services/matches_service.dart';
import 'package:sportheroes_mobile/features/teams/providers/teams_provider.dart';

final matchesServiceProvider = Provider<MatchesService>((ref) {
  return MatchesService(ref.watch(dioClientProvider));
});

class MatchesState {
  const MatchesState({
    this.listState = const ApiInitial<List<MatchModel>>(),
    this.liveState = const ApiInitial<List<MatchModel>>(),
    this.myState = const ApiInitial<List<MatchModel>>(),
    this.detailState = const ApiInitial<MatchModel>(),
    this.timelineState = const ApiInitial<List<MatchTimelinePoint>>(),
    this.actionState = const ApiInitial<String>(),
    this.statusFilter,
  });

  final ApiState<List<MatchModel>> listState;
  final ApiState<List<MatchModel>> liveState;
  final ApiState<List<MatchModel>> myState;
  final ApiState<MatchModel> detailState;
  final ApiState<List<MatchTimelinePoint>> timelineState;
  final ApiState<String> actionState;
  final String? statusFilter;

  List<MatchModel> get matches => listState.dataOrNull ?? const [];
  List<MatchModel> get liveMatches => liveState.dataOrNull ?? const [];
  List<MatchModel> get myMatches => myState.dataOrNull ?? const [];
  MatchModel? get currentMatch => detailState.dataOrNull;

  MatchesState copyWith({
    ApiState<List<MatchModel>>? listState,
    ApiState<List<MatchModel>>? liveState,
    ApiState<List<MatchModel>>? myState,
    ApiState<MatchModel>? detailState,
    ApiState<List<MatchTimelinePoint>>? timelineState,
    ApiState<String>? actionState,
    String? statusFilter,
  }) {
    return MatchesState(
      listState: listState ?? this.listState,
      liveState: liveState ?? this.liveState,
      myState: myState ?? this.myState,
      detailState: detailState ?? this.detailState,
      timelineState: timelineState ?? this.timelineState,
      actionState: actionState ?? this.actionState,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class MatchesNotifier extends Notifier<MatchesState> {
  @override
  MatchesState build() => const MatchesState();

  MatchesService get _service => ref.read(matchesServiceProvider);

  /// Fills nested team names when API only returns `teamId`.
  Future<List<MatchModel>> _withTeamNames(List<MatchModel> matches) async {
    final needsLookup = matches.any(
      (m) => m.participants.any(
        (p) =>
            p.team == null &&
            p.teamId != null &&
            p.teamId!.trim().isNotEmpty,
      ),
    );
    if (!needsLookup) return matches;

    try {
      final teams = await ref.read(teamsServiceProvider).listTeams(limit: 100);
      final byId = {for (final t in teams.teams) t.id: t};
      return matches.map((m) {
        final participants = m.participants.map((p) {
          if (p.team != null || p.teamId == null || p.teamId!.isEmpty) {
            return p;
          }
          final team = byId[p.teamId];
          if (team == null) return p;
          return p.copyWith(
            team: MatchTeamSummary(
              id: team.id,
              name: team.name,
              shortName: team.shortName,
            ),
          );
        }).toList();
        return m.copyWith(participants: participants);
      }).toList();
    } catch (_) {
      return matches;
    }
  }

  Future<MatchModel> _withTeamName(MatchModel match) async {
    final list = await _withTeamNames([match]);
    return list.first;
  }

  Future<void> loadMatches({
    String? status,
    String? participantPhone,
    String? sportCode,
  }) async {
    state = state.copyWith(
      listState: const ApiLoading(),
      statusFilter: status,
    );
    try {
      final result = await _service.listMatches(
        status: status,
        participantPhone: participantPhone,
        sportCode: sportCode,
      );
      final matches = await _withTeamNames(result.matches);
      state = state.copyWith(listState: ApiSuccess(matches));
    } catch (e) {
      state = state.copyWith(listState: ApiError(ApiHelpers.cleanError(e)));
    }
  }

  Future<void> loadMyMatches(String phone) async {
    state = state.copyWith(myState: const ApiLoading());
    try {
      final result = await _service.listMatches(participantPhone: phone);
      final matches = await _withTeamNames(result.matches);
      state = state.copyWith(myState: ApiSuccess(matches));
    } catch (e) {
      state = state.copyWith(myState: ApiError(ApiHelpers.cleanError(e)));
    }
  }

  Future<void> loadLiveMatches() async {
    state = state.copyWith(liveState: const ApiLoading());
    try {
      final ongoing = await _service.listMatches(status: 'ongoing');
      final paused = await _service.listMatches(status: 'paused');
      final matches = await _withTeamNames([
        ...ongoing.matches,
        ...paused.matches,
      ]);
      state = state.copyWith(liveState: ApiSuccess(matches));
    } catch (e) {
      state = state.copyWith(liveState: ApiError(ApiHelpers.cleanError(e)));
    }
  }

  Future<void> loadRecentAndScheduled() async {
    state = state.copyWith(listState: const ApiLoading());
    try {
      final completed = await _service.listMatches(status: 'completed');
      final scheduled = await _service.listMatches(status: 'scheduled');
      final matches = await _withTeamNames([
        ...scheduled.matches,
        ...completed.matches,
      ]);
      state = state.copyWith(listState: ApiSuccess(matches));
    } catch (e) {
      state = state.copyWith(listState: ApiError(ApiHelpers.cleanError(e)));
    }
  }

  Future<void> loadMatch(String id) async {
    state = state.copyWith(detailState: const ApiLoading());
    try {
      final match = await _withTeamName(await _service.getMatch(id));
      state = state.copyWith(detailState: ApiSuccess(match));
    } catch (e) {
      state = state.copyWith(detailState: ApiError(ApiHelpers.cleanError(e)));
    }
  }

  Future<void> refreshMatch(String id) async {
    try {
      final match = await _withTeamName(await _service.getMatch(id));
      state = state.copyWith(detailState: ApiSuccess(match));
    } catch (_) {
      // Silent refresh failure.
    }
  }

  Future<void> loadTimeline(String id) async {
    state = state.copyWith(timelineState: const ApiLoading());
    try {
      final timeline = await _service.getTimeline(id);
      state = state.copyWith(timelineState: ApiSuccess(timeline));
    } catch (e) {
      state = state.copyWith(
        timelineState: ApiError(ApiHelpers.cleanError(e)),
      );
    }
  }

  Future<MatchModel?> createMatch(CreateMatchRequest request) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      final result = await _service.createMatch(request);
      await loadRecentAndScheduled();
      final match = await _withTeamName(result.data);
      state = state.copyWith(
        actionState: ApiSuccess(result.message),
        detailState: ApiSuccess(match),
      );
      return match;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return null;
    }
  }

  Future<bool> start(String id) => _runAction(() => _service.start(id));
  Future<bool> pause(String id) => _runAction(() => _service.pause(id));
  Future<bool> resume(String id) => _runAction(() => _service.resume(id));
  Future<bool> undoPoint(String id) => _runAction(() => _service.undoPoint(id));
  Future<bool> finishSet(String id, {String? winnerSide}) =>
      _runAction(() => _service.finishSet(id, winnerSide: winnerSide));
  Future<bool> complete(String id, {String? winnerSide}) =>
      _runAction(() => _service.complete(id, winnerSide: winnerSide));

  Future<bool> recordPoint(String id, String scoringSide) =>
      _runAction(() => _service.recordPoint(id, scoringSide));

  Future<bool> cancel(String id, {String? reason}) =>
      _runAction(() => _service.cancel(id, reason: reason));

  Future<bool> _runAction(
    Future<ApiResult<MatchModel>> Function() action,
  ) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      final result = await action();
      final match = await _withTeamName(result.data);
      state = state.copyWith(
        actionState: ApiSuccess(result.message),
        detailState: ApiSuccess(match),
      );
      return true;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return false;
    }
  }
}

final matchesProvider = NotifierProvider<MatchesNotifier, MatchesState>(
  MatchesNotifier.new,
);
