import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/models/api_state.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/features/search/models/search_result.dart';
import 'package:sportheroes_mobile/features/search/services/search_service.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref.watch(dioClientProvider));
});

class SearchState {
  const SearchState({
    this.resultsState = const ApiInitial<List<SearchResult>>(),
    this.query = '',
    this.selectedTypes = const [],
  });

  final ApiState<List<SearchResult>> resultsState;
  final String query;
  final List<String> selectedTypes;

  List<SearchResult> get results => resultsState.dataOrNull ?? const [];

  SearchState copyWith({
    ApiState<List<SearchResult>>? resultsState,
    String? query,
    List<String>? selectedTypes,
  }) {
    return SearchState(
      resultsState: resultsState ?? this.resultsState,
      query: query ?? this.query,
      selectedTypes: selectedTypes ?? this.selectedTypes,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() => const SearchState();

  SearchService get _service => ref.read(searchServiceProvider);

  Future<void> search(String query, {List<String>? types}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        query: '',
        resultsState: const ApiInitial(),
      );
      return;
    }

    state = state.copyWith(
      query: trimmed,
      selectedTypes: types ?? state.selectedTypes,
      resultsState: const ApiLoading(),
    );

    try {
      final page = await _service.search(
        query: trimmed,
        types: types ?? state.selectedTypes,
      );
      state = state.copyWith(resultsState: ApiSuccess(page.results));
    } catch (e) {
      state = state.copyWith(
        resultsState: ApiError(ApiHelpers.cleanError(e)),
      );
    }
  }

  void clear() {
    state = const SearchState();
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
