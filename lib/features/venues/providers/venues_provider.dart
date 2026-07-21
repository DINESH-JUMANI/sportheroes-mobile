import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/models/api_state.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/features/venues/models/venue_model.dart';
import 'package:sportheroes_mobile/features/venues/services/venues_service.dart';

final venuesServiceProvider = Provider<VenuesService>((ref) {
  return VenuesService(ref.watch(dioClientProvider));
});

class VenuesState {
  const VenuesState({
    this.listState = const ApiInitial<List<VenueModel>>(),
    this.actionState = const ApiInitial<String>(),
    this.query = '',
  });

  final ApiState<List<VenueModel>> listState;
  final ApiState<String> actionState;
  final String query;

  List<VenueModel> get venues => listState.dataOrNull ?? const [];

  VenuesState copyWith({
    ApiState<List<VenueModel>>? listState,
    ApiState<String>? actionState,
    String? query,
  }) {
    return VenuesState(
      listState: listState ?? this.listState,
      actionState: actionState ?? this.actionState,
      query: query ?? this.query,
    );
  }
}

class VenuesNotifier extends Notifier<VenuesState> {
  @override
  VenuesState build() => const VenuesState();

  VenuesService get _service => ref.read(venuesServiceProvider);

  Future<void> loadVenues({String? q}) async {
    final query = q ?? state.query;
    state = state.copyWith(
      listState: const ApiLoading(),
      query: query,
    );
    try {
      final result = await _service.list(
        q: query.trim().isEmpty ? null : query.trim(),
      );
      state = state.copyWith(listState: ApiSuccess(result.venues));
    } catch (e) {
      state = state.copyWith(listState: ApiError(ApiHelpers.cleanError(e)));
    }
  }

  Future<VenueModel?> createVenue(CreateVenueRequest request) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      final result = await _service.create(request);
      await loadVenues();
      state = state.copyWith(actionState: ApiSuccess(result.message));
      return result.data;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return null;
    }
  }

  Future<bool> deleteVenue(String id) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      await _service.delete(id);
      await loadVenues();
      state = state.copyWith(actionState: ApiSuccess('Venue deleted'));
      return true;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return false;
    }
  }
}

final venuesProvider = NotifierProvider<VenuesNotifier, VenuesState>(
  VenuesNotifier.new,
);
