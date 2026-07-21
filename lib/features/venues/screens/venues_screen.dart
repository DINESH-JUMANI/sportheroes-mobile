import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/app_logo_loader.dart';
import 'package:sportheroes_mobile/features/venues/models/venue_model.dart';
import 'package:sportheroes_mobile/features/venues/providers/venues_provider.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';

class VenuesScreen extends ConsumerStatefulWidget {
  const VenuesScreen({super.key});

  @override
  ConsumerState<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends ConsumerState<VenuesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(venuesProvider.notifier).loadVenues();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() => ref.read(venuesProvider.notifier).loadVenues(
        q: _searchController.text,
      );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(venuesProvider);
    final venues = state.venues;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Venues')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.createVenue);
          if (mounted) await _refresh();
        },
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add venue'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search venues…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: _refresh,
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _refresh(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: state.listState.isLoading && venues.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 140),
                        Center(
                          child: AppLogoLoader(message: 'Loading venues…'),
                        ),
                      ],
                    )
                  : state.listState.isError
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                state.listState.errorOrNull ?? 'Error',
                                style: const TextStyle(color: AppColors.error),
                              ),
                              TextButton(
                                onPressed: _refresh,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : venues.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text(
                            'No venues yet. Add one with GPS.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: venues.length,
                      itemBuilder: (context, i) {
                        final v = venues[i];
                        return _VenueTile(venue: v);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueTile extends StatelessWidget {
  const _VenueTile({required this.venue});

  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary50,
          child: Icon(Icons.place_rounded, color: AppColors.primary),
        ),
        title: Text(
          venue.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(venue.subtitle),
      ),
    );
  }
}
