import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/models/api_state.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/features/sports/models/sport_model.dart';
import 'package:sportheroes_mobile/features/sports/models/sport_rules_model.dart';
import 'package:sportheroes_mobile/features/sports/services/sports_service.dart';

final sportsServiceProvider = Provider<SportsService>((ref) {
  return SportsService(ref.watch(dioClientProvider));
});

class SportsState {
  const SportsState({
    this.sportsState = const ApiInitial<List<SportModel>>(),
    this.myProfilesState = const ApiInitial<List<PlayerSportProfile>>(),
    this.actionState = const ApiInitial<bool>(),
  });

  final ApiState<List<SportModel>> sportsState;
  final ApiState<List<PlayerSportProfile>> myProfilesState;
  final ApiState<bool> actionState;

  List<SportModel> get sports => sportsState.dataOrNull ?? const [];
  List<PlayerSportProfile> get myProfiles =>
      myProfilesState.dataOrNull ?? const [];

  SportsState copyWith({
    ApiState<List<SportModel>>? sportsState,
    ApiState<List<PlayerSportProfile>>? myProfilesState,
    ApiState<bool>? actionState,
  }) {
    return SportsState(
      sportsState: sportsState ?? this.sportsState,
      myProfilesState: myProfilesState ?? this.myProfilesState,
      actionState: actionState ?? this.actionState,
    );
  }
}

class SportsNotifier extends Notifier<SportsState> {
  @override
  SportsState build() => const SportsState();

  SportsService get _service => ref.read(sportsServiceProvider);

  Future<void> loadSports() async {
    state = state.copyWith(sportsState: const ApiLoading());
    try {
      final result = await _service.listSports();
      state = state.copyWith(sportsState: ApiSuccess(result.sports));
    } catch (e) {
      state = state.copyWith(
        sportsState: ApiError(ApiHelpers.cleanError(e)),
      );
    }
  }

  Future<void> loadMyProfiles() async {
    state = state.copyWith(myProfilesState: const ApiLoading());
    try {
      final profiles = await _service.getMyProfiles();
      state = state.copyWith(myProfilesState: ApiSuccess(profiles));
    } catch (e) {
      state = state.copyWith(
        myProfilesState: ApiError(ApiHelpers.cleanError(e)),
      );
    }
  }

  Future<bool> addSportProfile(CreatePlayerProfileRequest request) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      await _service.createPlayerProfile(request);
      await loadMyProfiles();
      state = state.copyWith(actionState: const ApiSuccess(true));
      return true;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return false;
    }
  }

  Future<bool> removeSportProfile(String profileId) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      await _service.deletePlayerProfile(profileId);
      await loadMyProfiles();
      state = state.copyWith(actionState: const ApiSuccess(true));
      return true;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return false;
    }
  }
}

final sportsProvider = NotifierProvider<SportsNotifier, SportsState>(
  SportsNotifier.new,
);

final sportRulesProvider =
    FutureProvider.autoDispose.family<SportRules, String>((ref, sportCode) {
  return ref.read(sportsServiceProvider).getSportRules(sportCode);
});
