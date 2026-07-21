import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/models/api_state.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/features/support/models/support_models.dart';
import 'package:sportheroes_mobile/features/support/services/support_service.dart';

final supportServiceProvider = Provider<SupportService>((ref) {
  return SupportService(ref.watch(dioClientProvider));
});

class SupportState {
  const SupportState({
    this.concernsState = const ApiInitial<List<SupportConcern>>(),
    this.ticketsState = const ApiInitial<List<SupportTicket>>(),
    this.actionState = const ApiInitial<String>(),
    this.lastCreatedTicket,
  });

  final ApiState<List<SupportConcern>> concernsState;
  final ApiState<List<SupportTicket>> ticketsState;
  final ApiState<String> actionState;
  final SupportTicket? lastCreatedTicket;

  List<SupportConcern> get concerns => concernsState.dataOrNull ?? const [];
  List<SupportTicket> get tickets => ticketsState.dataOrNull ?? const [];

  SupportState copyWith({
    ApiState<List<SupportConcern>>? concernsState,
    ApiState<List<SupportTicket>>? ticketsState,
    ApiState<String>? actionState,
    SupportTicket? lastCreatedTicket,
    bool clearLastTicket = false,
  }) {
    return SupportState(
      concernsState: concernsState ?? this.concernsState,
      ticketsState: ticketsState ?? this.ticketsState,
      actionState: actionState ?? this.actionState,
      lastCreatedTicket:
          clearLastTicket ? null : (lastCreatedTicket ?? this.lastCreatedTicket),
    );
  }
}

class SupportNotifier extends Notifier<SupportState> {
  @override
  SupportState build() => const SupportState();

  SupportService get _service => ref.read(supportServiceProvider);

  Future<void> loadConcerns() async {
    state = state.copyWith(concernsState: const ApiLoading());
    try {
      final result = await _service.listConcerns();
      state = state.copyWith(concernsState: ApiSuccess(result.data));
    } catch (e) {
      state = state.copyWith(
        concernsState: ApiError(ApiHelpers.cleanError(e)),
      );
    }
  }

  Future<void> loadMyTickets({String? status}) async {
    state = state.copyWith(ticketsState: const ApiLoading());
    try {
      final result = await _service.listMyTickets(status: status);
      state = state.copyWith(ticketsState: ApiSuccess(result.data));
    } catch (e) {
      state = state.copyWith(
        ticketsState: ApiError(ApiHelpers.cleanError(e)),
      );
    }
  }

  Future<SupportTicket?> createTicket(CreateSupportTicketRequest request) async {
    state = state.copyWith(actionState: const ApiLoading());
    try {
      final result = await _service.createTicket(request);
      await loadMyTickets();
      state = state.copyWith(
        actionState: ApiSuccess(result.message),
        lastCreatedTicket: result.data,
      );
      return result.data;
    } catch (e) {
      state = state.copyWith(actionState: ApiError(ApiHelpers.cleanError(e)));
      return null;
    }
  }
}

final supportProvider = NotifierProvider<SupportNotifier, SupportState>(
  SupportNotifier.new,
);
