import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/mock/mock_data.dart';
import 'package:sportheroes_mobile/features/teams/widgets/team_card.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Teams')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create team API coming soon')),
          );
        },
        icon: const Icon(Icons.group_add),
        label: const Text('Create Team'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.teams.length,
        itemBuilder: (context, i) {
          final team = MockData.teams[i];
          return TeamCard(
            name: team['name'] as String,
            sport: team['sport'] as String,
            captain: team['captain'] as String,
            members: team['members'] as int,
            wins: team['wins'] as int,
            losses: team['losses'] as int,
          );
        },
      ),
    );
  }
}
