import 'package:sportheroes_mobile/features/auth/models/user_model.dart';

class PlayerStatistics {
  const PlayerStatistics({
    required this.id,
    required this.userId,
    required this.sportId,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.matchesLost = 0,
    this.setsWon = 0,
    this.setsLost = 0,
    this.totalPointsScored = 0,
    this.totalPointsConceded = 0,
    this.winPercentage = 0,
    this.currentRankingPoints = 0,
    this.updatedAt,
    this.player,
    this.sportName,
  });

  factory PlayerStatistics.fromJson(Map<String, dynamic> json) {
    return PlayerStatistics(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      sportId: json['sportId']?.toString() ?? '',
      matchesPlayed: (json['matchesPlayed'] as num?)?.toInt() ?? 0,
      matchesWon: (json['matchesWon'] as num?)?.toInt() ?? 0,
      matchesLost: (json['matchesLost'] as num?)?.toInt() ?? 0,
      setsWon: (json['setsWon'] as num?)?.toInt() ?? 0,
      setsLost: (json['setsLost'] as num?)?.toInt() ?? 0,
      totalPointsScored: (json['totalPointsScored'] as num?)?.toInt() ?? 0,
      totalPointsConceded: (json['totalPointsConceded'] as num?)?.toInt() ?? 0,
      winPercentage: (json['winPercentage'] as num?)?.toDouble() ?? 0,
      currentRankingPoints:
          (json['currentRankingPoints'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] as String?,
      player: json['player'] is Map
          ? UserSummary.fromJson(
              Map<String, dynamic>.from(json['player'] as Map),
            )
          : null,
      sportName: json['sport'] is Map
          ? (json['sport'] as Map)['name']?.toString()
          : json['sportName'] as String?,
    );
  }

  final String id;
  final String userId;
  final String sportId;
  final int matchesPlayed;
  final int matchesWon;
  final int matchesLost;
  final int setsWon;
  final int setsLost;
  final int totalPointsScored;
  final int totalPointsConceded;
  final double winPercentage;
  final int currentRankingPoints;
  final String? updatedAt;
  final UserSummary? player;
  final String? sportName;
}

class TeamStatistics {
  const TeamStatistics({
    this.id,
    required this.teamId,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.matchesLost = 0,
    this.setsWon = 0,
    this.setsLost = 0,
    this.winPercentage = 0,
    this.updatedAt,
    this.teamName,
    this.teamShortName,
    this.logoUrl,
    this.hasLogo = false,
    this.logoMimeType,
    this.sportId,
  });

  factory TeamStatistics.fromJson(Map<String, dynamic> json) {
    final team = json['team'] is Map
        ? Map<String, dynamic>.from(json['team'] as Map)
        : null;
    return TeamStatistics(
      id: json['id']?.toString(),
      teamId: json['teamId']?.toString() ?? team?['id']?.toString() ?? '',
      matchesPlayed: (json['matchesPlayed'] as num?)?.toInt() ?? 0,
      matchesWon: (json['matchesWon'] as num?)?.toInt() ?? 0,
      matchesLost: (json['matchesLost'] as num?)?.toInt() ?? 0,
      setsWon: (json['setsWon'] as num?)?.toInt() ?? 0,
      setsLost: (json['setsLost'] as num?)?.toInt() ?? 0,
      winPercentage: (json['winPercentage'] as num?)?.toDouble() ?? 0,
      updatedAt: json['updatedAt'] as String?,
      teamName: team?['name'] as String?,
      teamShortName: team?['shortName'] as String?,
      logoUrl: team?['logoUrl'] as String?,
      hasLogo: team?['hasLogo'] as bool? ?? false,
      logoMimeType: team?['logoMimeType'] as String?,
    );
  }

  final String? id;
  final String teamId;
  final int matchesPlayed;
  final int matchesWon;
  final int matchesLost;
  final int setsWon;
  final int setsLost;
  final double winPercentage;
  final String? updatedAt;
  final String? teamName;
  final String? teamShortName;
  final String? logoUrl;
  final bool hasLogo;
  final String? logoMimeType;
  final String? sportId;
}
