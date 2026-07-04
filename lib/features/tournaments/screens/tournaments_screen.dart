import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/mock/mock_data.dart';
import 'package:sportheroes_mobile/features/tournaments/widgets/tournament_card.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Tournaments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create tournament API coming soon')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.tournaments.length,
        itemBuilder: (context, i) {
          final t = MockData.tournaments[i];
          return TournamentCard(
            name: t['name'] as String,
            sport: t['sport'] as String,
            format: t['format'] as String,
            status: t['status'] as String,
            participants: t['participants'] as int,
            venue: t['venue'] as String,
            dateRange: '${t['startDate']} → ${t['endDate']}',
          );
        },
      ),
    );
  }
}
