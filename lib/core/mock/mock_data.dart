/// Static mock data for feature screens until APIs are wired.
class MockData {
  MockData._();

  static const currentUser = {
    'id': 'user-1',
    'fullName': 'Rahul Sharma',
    'displayName': 'Rahul',
    'phoneNumber': '+919876543210',
    'city': 'Mumbai',
    'country': 'India',
    'sports': ['Table Tennis', 'Badminton'],
    'matchesPlayed': 42,
    'wins': 28,
    'losses': 14,
    'winPercentage': 66.7,
  };

  static const sports = [
    {'id': 'tt', 'name': 'Table Tennis', 'emoji': '🏓'},
    {'id': 'badminton', 'name': 'Badminton', 'emoji': '🏸'},
    {'id': 'volleyball', 'name': 'Volleyball', 'emoji': '🏐'},
    {'id': 'pickleball', 'name': 'Pickleball', 'emoji': '🥒'},
  ];

  static const recentMatches = [
    {
      'id': 'm1',
      'sport': 'Table Tennis',
      'opponent': 'Amit Patel',
      'score': '3-1',
      'result': 'Won',
      'date': '2026-07-02',
      'status': 'completed',
    },
    {
      'id': 'm2',
      'sport': 'Badminton',
      'opponent': 'Priya Singh',
      'score': '1-2',
      'result': 'Lost',
      'date': '2026-06-28',
      'status': 'completed',
    },
    {
      'id': 'm3',
      'sport': 'Table Tennis',
      'opponent': 'Vikram Rao',
      'score': '2-0',
      'result': 'Won',
      'date': '2026-06-25',
      'status': 'completed',
    },
    {
      'id': 'm4',
      'sport': 'Pickleball',
      'opponent': 'Neha Kapoor',
      'score': '-',
      'result': 'Upcoming',
      'date': '2026-07-08',
      'status': 'scheduled',
    },
  ];

  static const liveMatches = [
    {
      'id': 'live-1',
      'sport': 'Table Tennis',
      'playerA': 'Rahul',
      'playerB': 'Suresh',
      'scoreA': 8,
      'scoreB': 6,
      'set': 'Set 2',
      'venue': 'Andheri Sports Club',
    },
  ];

  static const teams = [
    {
      'id': 't1',
      'name': 'Smash Kings',
      'sport': 'Table Tennis',
      'members': 4,
      'captain': 'Rahul Sharma',
      'wins': 12,
      'losses': 5,
    },
    {
      'id': 't2',
      'name': 'Shuttle Stars',
      'sport': 'Badminton',
      'members': 6,
      'captain': 'Priya Singh',
      'wins': 9,
      'losses': 7,
    },
    {
      'id': 't3',
      'name': 'Net Warriors',
      'sport': 'Volleyball',
      'members': 8,
      'captain': 'Amit Patel',
      'wins': 15,
      'losses': 3,
    },
  ];

  static const tournaments = [
    {
      'id': 'tour1',
      'name': 'Mumbai Open 2026',
      'sport': 'Table Tennis',
      'format': 'Knockout',
      'status': 'Ongoing',
      'participants': 32,
      'startDate': '2026-07-01',
      'endDate': '2026-07-10',
      'venue': 'NSCI Dome',
    },
    {
      'id': 'tour2',
      'name': 'City Badminton League',
      'sport': 'Badminton',
      'format': 'Round Robin',
      'status': 'Upcoming',
      'participants': 16,
      'startDate': '2026-07-15',
      'endDate': '2026-07-22',
      'venue': 'Powai Indoor Arena',
    },
    {
      'id': 'tour3',
      'name': 'Pickleball Cup',
      'sport': 'Pickleball',
      'format': 'League',
      'status': 'Completed',
      'participants': 24,
      'startDate': '2026-06-01',
      'endDate': '2026-06-14',
      'venue': 'Bandra Sports Complex',
    },
  ];

  static const leaderboard = [
    {
      'rank': 1,
      'name': 'Vikram Rao',
      'sport': 'Table Tennis',
      'wins': 40,
      'winPercentage': 82.0,
      'points': 980,
    },
    {
      'rank': 2,
      'name': 'Rahul Sharma',
      'sport': 'Table Tennis',
      'wins': 28,
      'winPercentage': 66.7,
      'points': 840,
    },
    {
      'rank': 3,
      'name': 'Priya Singh',
      'sport': 'Badminton',
      'wins': 31,
      'winPercentage': 72.1,
      'points': 810,
    },
    {
      'rank': 4,
      'name': 'Amit Patel',
      'sport': 'Volleyball',
      'wins': 22,
      'winPercentage': 61.0,
      'points': 720,
    },
    {
      'rank': 5,
      'name': 'Neha Kapoor',
      'sport': 'Pickleball',
      'wins': 19,
      'winPercentage': 58.5,
      'points': 690,
    },
  ];

  static const onboardingPages = [
    {
      'title': 'Track every match',
      'subtitle':
          'Record live scores for Table Tennis, Badminton, Volleyball, and Pickleball.',
      'icon': 'sports_score',
    },
    {
      'title': 'Build your sports profile',
      'subtitle':
          'Maintain history, stats, and rankings that travel with you across clubs.',
      'icon': 'person',
    },
    {
      'title': 'Compete in tournaments',
      'subtitle':
          'Join leagues, knockouts, and community events near you.',
      'icon': 'emoji_events',
    },
  ];
}
