import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/api_state_view.dart';
import 'package:sportheroes_mobile/features/search/models/search_result.dart';
import 'package:sportheroes_mobile/features/search/providers/search_provider.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  static const _typeFilters = [
    ('users', 'Users'),
    ('teams', 'Teams'),
    ('tournaments', 'Events'),
    ('matches', 'Matches'),
    ('venues', 'Venues'),
  ];

  final Set<String> _selectedTypes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search() {
    ref.read(searchProvider.notifier).search(
          _controller.text,
          types: _selectedTypes.isEmpty ? null : _selectedTypes.toList(),
        );
  }

  void _onResultTap(SearchResult result) {
    switch (result.resultType) {
      case SearchResultType.team:
        Navigator.pushNamed(
          context,
          AppRoutes.teamDetail,
          arguments: result.id,
        );
      case SearchResultType.tournament:
        Navigator.pushNamed(
          context,
          AppRoutes.tournamentDetail,
          arguments: result.id,
        );
      case SearchResultType.match:
        Navigator.pushNamed(
          context,
          AppRoutes.matchDetail,
          arguments: result.id,
        );
      case SearchResultType.user:
      case SearchResultType.venue:
      case SearchResultType.other:
        AppSnackbar.info(context, result.title);
    }
  }

  IconData _iconFor(SearchResultType type) => switch (type) {
        SearchResultType.user => Icons.person_outline_rounded,
        SearchResultType.team => Icons.groups_outlined,
        SearchResultType.tournament => Icons.emoji_events_outlined,
        SearchResultType.match => Icons.sports_outlined,
        SearchResultType.venue => Icons.location_on_outlined,
        SearchResultType.other => Icons.search_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search players, teams, events…',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppColors.primary,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          onChanged: (v) {
            if (v.trim().length >= 2) _search();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: _search,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _typeFilters.map((t) {
                final selected = _selectedTypes.contains(t.$1);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(t.$2),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedTypes.add(t.$1);
                        } else {
                          _selectedTypes.remove(t.$1);
                        }
                      });
                      if (_controller.text.trim().isNotEmpty) _search();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ApiStateView(
              isLoading: state.resultsState.isLoading,
              loadingMessage: 'Searching…',
              error: state.resultsState.isError
                  ? state.resultsState.errorOrNull
                  : null,
              onRetry: _search,
              isEmpty: !state.resultsState.isLoading &&
                  !state.resultsState.isError &&
                  state.query.isNotEmpty &&
                  state.results.isEmpty,
              emptyMessage: 'No results for “${state.query}”',
              child: state.query.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.travel_explore_rounded,
                              size: 48,
                              color: AppColors.grey400,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Search players, teams, matches & venues',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = state.results[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary50,
                            child: Icon(
                              _iconFor(r.resultType),
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            r.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle:
                              r.subtitle != null ? Text(r.subtitle!) : null,
                          trailing: Text(
                            r.type,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () => _onResultTap(r),
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
