import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/mock/mock_data.dart';
import 'package:sportheroes_mobile/features/matches/widgets/match_list_tile.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.grey50,
        appBar: AppBar(
          title: const Text('Matches'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Recent'),
              Tab(text: 'Live'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create match API coming soon')),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('New Match'),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MockData.recentMatches.length,
              itemBuilder: (context, i) {
                final m = MockData.recentMatches[i];
                return MatchListTile(
                  sport: m['sport'] as String,
                  opponent: m['opponent'] as String,
                  score: m['score'] as String,
                  result: m['result'] as String,
                  date: m['date'] as String,
                );
              },
            ),
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MockData.liveMatches.length,
              itemBuilder: (context, i) {
                final m = MockData.liveMatches[i];
                return MatchListTile(
                  sport: m['sport'] as String,
                  opponent: '${m['playerA']} vs ${m['playerB']}',
                  score: '${m['scoreA']}-${m['scoreB']}',
                  result: 'LIVE',
                  date: m['venue'] as String,
                  isLive: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
