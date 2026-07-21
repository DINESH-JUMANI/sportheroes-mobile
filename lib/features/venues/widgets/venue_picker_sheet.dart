import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/features/venues/models/venue_model.dart';
import 'package:sportheroes_mobile/features/venues/providers/venues_provider.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';

/// Bottom sheet / dialog to pick a venue for match create.
class VenuePickerSheet extends ConsumerStatefulWidget {
  const VenuePickerSheet({super.key, this.selectedId});

  final String? selectedId;

  @override
  ConsumerState<VenuePickerSheet> createState() => _VenuePickerSheetState();
}

class _VenuePickerSheetState extends ConsumerState<VenuePickerSheet> {
  final _q = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(venuesProvider.notifier).loadVenues();
    });
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(venuesProvider);
    final venues = state.venues;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select venue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final created = await Navigator.pushNamed(
                        context,
                        AppRoutes.createVenue,
                      );
                      if (created is VenueModel && context.mounted) {
                        Navigator.pop(context, created);
                      } else {
                        await ref.read(venuesProvider.notifier).loadVenues();
                      }
                    },
                    child: const Text('New'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _q,
                decoration: const InputDecoration(
                  hintText: 'Search venues…',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (v) =>
                    ref.read(venuesProvider.notifier).loadVenues(q: v),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: state.listState.isLoading && venues.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: venues.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return ListTile(
                            leading: const Icon(Icons.clear_rounded),
                            title: const Text('No venue'),
                            onTap: () => Navigator.pop(context),
                          );
                        }
                        final v = venues[i - 1];
                        final selected = v.id == widget.selectedId;
                        return ListTile(
                          leading: Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.place_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(v.name),
                          subtitle: Text(v.subtitle),
                          onTap: () => Navigator.pop(context, v),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
