import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/models/api_state.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/features/teams/models/team_model.dart';
import 'package:sportheroes_mobile/features/teams/services/teams_service.dart';

final teamsServiceProvider = Provider<TeamsService>((ref) {
  return TeamsService(ref.watch(dioClientProvider));
});

class TeamsState {
  const TeamsState({
    this.listState = const ApiInitial<List<TeamModel>>(),
    this.detailState = const ApiInitial<TeamModel>(),
    this.lookupState = const ApiInitial<LookupUserResult>(),
    this.actionState = const ApiInitial<String>(),
  });

  final ApiState<List<TeamModel>> listState;
  final ApiState<TeamModel> detailState;
  final ApiState<LookupUserResult> lookupState;
  final ApiState<String> actionState;

  List<TeamModel> get teams => listState.dataOrNull ?? const [];

  TeamsState copyWith({
    ApiState<List<TeamModel>>? listState,
    ApiState<TeamModel>? detailState,
    ApiState<LookupUserResult>? lookupState,
    ApiState<String>? actionState,
  }) {
    return TeamsState(
      listState: listState ?? this.listState,
      detailState: detailState ?? this.detailState,
      lookupState: lookupState ?? this.lookupState,
      actionState: actionState ?? this.actionState,
    );
  }
}

class TeamsNotifier extends Notifier<TeamsState> {
  @override
  TeamsState build() => const TeamsState();

  TeamsService get _service => ref.read(teamsServiceProvider);

  Future<void> loadTeams() async {
    state = state.copyWith(listState: const ApiLoading());
    try {
      final result = await _service.listTeams();
      state = state.copyWith(listState: ApiSuccess(result.teams));
    } catch (e) {
      state = state.copyWith(listState: ApiError(ApiHelpers.cleanError(e)));
    }
  }

  Future<void> loadTeam(String id) async {
    state = state.copyWith(detailState: const ApiLoading());
    try {
      final team = await _service.getTeam(id);
      state = state.copyWith(detailState: ApiSuccess(team));
    } catch (e) {
      state = state.copyWith(detailState: ApiError(ApiHelpers.cleanError(e)));
    }
  }

  Future<TeamModel?> createTeam(CreateTeamRequest request) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      final result = await _service.createTeam(request);
      await loadTeams();
      state = state.copyWith(actionState: ApiSuccess(result.message));
      return result.data;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return null;
    }
  }

  Future<TeamModel?> updateTeam(String id, UpdateTeamRequest request) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      final team = await _service.updateTeam(id, request);
      state = state.copyWith(
        actionState: ApiSuccess('Done'),
        detailState: ApiSuccess(team),
      );
      await loadTeams();
      return team;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return null;
    }
  }

  Future<bool> deleteTeam(String id) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      await _service.deleteTeam(id);
      await loadTeams();
      state = state.copyWith(actionState: ApiSuccess('Done'));
      return true;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return false;
    }
  }

  Future<void> lookupUserByPhone(String phoneNumber) async {
    state = state.copyWith(lookupState: const ApiLoading());
    try {
      final result = await _service.lookupUserByPhone(phoneNumber);
      state = state.copyWith(lookupState: ApiSuccess(result));
    } catch (e) {
      state = state.copyWith(lookupState: ApiError(ApiHelpers.cleanError(e)));
    }
  }

  void clearLookup() {
    state = state.copyWith(lookupState: const ApiInitial());
  }

  Future<bool> addMember(String teamId, AddTeamMemberRequest request) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      await _service.addMember(teamId, request);
      await loadTeam(teamId);
      state = state.copyWith(actionState: ApiSuccess('Done'));
      return true;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return false;
    }
  }

  Future<bool> updateMemberRole(
    String teamId,
    String memberId,
    String role,
  ) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      await _service.updateMember(
        teamId,
        memberId,
        UpdateTeamMemberRequest(role: role),
      );
      await loadTeam(teamId);
      state = state.copyWith(actionState: ApiSuccess('Done'));
      return true;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return false;
    }
  }

  Future<bool> removeMember(String teamId, String memberId) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      await _service.removeMember(teamId, memberId);
      await loadTeam(teamId);
      state = state.copyWith(actionState: ApiSuccess('Done'));
      return true;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return false;
    }
  }

  Future<bool> uploadLogo(
    String teamId,
    UploadTeamLogoRequest request,
  ) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      final team = await _service.uploadLogo(teamId, request);
      state = state.copyWith(
        actionState: ApiSuccess('Done'),
        detailState: ApiSuccess(team),
      );
      return true;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return false;
    }
  }
}

final teamsProvider = NotifierProvider<TeamsNotifier, TeamsState>(
  TeamsNotifier.new,
);

final teamLogoProvider =
    FutureProvider.autoDispose.family<List<int>?, String>((ref, teamId) async {
  return ref.read(teamsServiceProvider).fetchLogoBytes(teamId);
});
