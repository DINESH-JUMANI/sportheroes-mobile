import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/models/api_state.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/features/tournaments/models/tournament_model.dart';
import 'package:sportheroes_mobile/features/tournaments/services/tournaments_service.dart';

final tournamentsServiceProvider = Provider<TournamentsService>((ref) {
  return TournamentsService(ref.watch(dioClientProvider));
});

class TournamentsState {
  const TournamentsState({
    this.listState = const ApiInitial<List<TournamentModel>>(),
    this.detailState = const ApiInitial<TournamentModel>(),
    this.participantsState =
        const ApiInitial<List<TournamentParticipant>>(),
    this.standingsState = const ApiInitial<List<TournamentStanding>>(),
    this.actionState = const ApiInitial<String>(),
  });

  final ApiState<List<TournamentModel>> listState;
  final ApiState<TournamentModel> detailState;
  final ApiState<List<TournamentParticipant>> participantsState;
  final ApiState<List<TournamentStanding>> standingsState;
  final ApiState<String> actionState;

  List<TournamentModel> get tournaments => listState.dataOrNull ?? const [];

  TournamentsState copyWith({
    ApiState<List<TournamentModel>>? listState,
    ApiState<TournamentModel>? detailState,
    ApiState<List<TournamentParticipant>>? participantsState,
    ApiState<List<TournamentStanding>>? standingsState,
    ApiState<String>? actionState,
  }) {
    return TournamentsState(
      listState: listState ?? this.listState,
      detailState: detailState ?? this.detailState,
      participantsState: participantsState ?? this.participantsState,
      standingsState: standingsState ?? this.standingsState,
      actionState: actionState ?? this.actionState,
    );
  }
}

class TournamentsNotifier extends Notifier<TournamentsState> {
  @override
  TournamentsState build() => const TournamentsState();

  TournamentsService get _service => ref.read(tournamentsServiceProvider);

  Future<void> loadTournaments({String? status, String? sportId}) async {
    state = state.copyWith(listState: const ApiLoading());
    try {
      final result = await _service.list(status: status, sportId: sportId);
      state = state.copyWith(listState: ApiSuccess(result.tournaments));
    } catch (e) {
      state = state.copyWith(listState: ApiError(ApiHelpers.cleanError(e)));
    }
  }

  Future<void> loadTournament(String id) async {
    state = state.copyWith(detailState: const ApiLoading());
    try {
      final tournament = await _service.getById(id);
      state = state.copyWith(detailState: ApiSuccess(tournament));
    } catch (e) {
      state = state.copyWith(detailState: ApiError(ApiHelpers.cleanError(e)));
    }
  }

  Future<void> loadParticipants(String id) async {
    state = state.copyWith(participantsState: const ApiLoading());
    try {
      final list = await _service.listParticipants(id);
      state = state.copyWith(participantsState: ApiSuccess(list));
    } catch (e) {
      state = state.copyWith(
        participantsState: ApiError(ApiHelpers.cleanError(e)),
      );
    }
  }

  Future<void> loadStandings(String id) async {
    state = state.copyWith(standingsState: const ApiLoading());
    try {
      final list = await _service.getStandings(id);
      state = state.copyWith(standingsState: ApiSuccess(list));
    } catch (e) {
      state = state.copyWith(
        standingsState: ApiError(ApiHelpers.cleanError(e)),
      );
    }
  }

  Future<TournamentModel?> create(CreateTournamentRequest request) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      final result = await _service.create(request);
      await loadTournaments();
      state = state.copyWith(actionState: ApiSuccess(result.message));
      return result.data;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return null;
    }
  }

  Future<bool> registerSelf({
    required String tournamentId,
    required String phoneNumber,
    String? fullName,
  }) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      await _service.register(
        tournamentId: tournamentId,
        phoneNumber: phoneNumber,
        fullName: fullName,
      );
      await loadParticipants(tournamentId);
      state = state.copyWith(actionState: ApiSuccess('Registered'));
      return true;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return false;
    }
  }
}

final tournamentsProvider =
    NotifierProvider<TournamentsNotifier, TournamentsState>(
  TournamentsNotifier.new,
);
