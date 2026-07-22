import 'package:sportheroes_mobile/features/auth/models/user_model.dart';
import 'package:sportheroes_mobile/features/sports/models/sport_model.dart';

class MatchTeamSummary {
  const MatchTeamSummary({
    required this.id,
    required this.name,
    this.shortName,
  });

  factory MatchTeamSummary.fromJson(Map<String, dynamic> json) {
    return MatchTeamSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortName: json['shortName'] as String?,
    );
  }

  final String id;
  final String name;
  final String? shortName;

  String get displayLabel {
    if (shortName != null && shortName!.trim().isNotEmpty) {
      return shortName!.trim();
    }
    if (name.trim().isNotEmpty) return name.trim();
    return 'Team';
  }
}

class MatchParticipant {
  const MatchParticipant({
    required this.id,
    required this.side,
    this.userId,
    this.teamId,
    this.isWinner = false,
    this.user,
    this.team,
  });

  factory MatchParticipant.fromJson(Map<String, dynamic> json) {
    return MatchParticipant(
      id: json['id']?.toString() ?? '',
      side: json['side']?.toString() ?? '',
      userId: json['userId']?.toString(),
      teamId: json['teamId']?.toString(),
      isWinner: json['isWinner'] as bool? ?? false,
      user: json['user'] is Map
          ? UserSummary.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
      team: json['team'] is Map
          ? MatchTeamSummary.fromJson(
              Map<String, dynamic>.from(json['team'] as Map),
            )
          : null,
    );
  }

  final String id;
  final String side;
  final String? userId;
  final String? teamId;
  final bool isWinner;
  final UserSummary? user;
  final MatchTeamSummary? team;

  bool get isTeamSide =>
      team != null || (teamId != null && teamId!.trim().isNotEmpty);

  String get displayName {
    if (team != null && team!.displayLabel.isNotEmpty) {
      return team!.displayLabel;
    }
    final userLabel = user?.displayLabel.trim();
    if (userLabel != null &&
        userLabel.isNotEmpty &&
        userLabel.toLowerCase() != 'player') {
      return userLabel;
    }
    return '';
  }

  MatchParticipant copyWith({
    MatchTeamSummary? team,
  }) {
    return MatchParticipant(
      id: id,
      side: side,
      userId: userId,
      teamId: teamId,
      isWinner: isWinner,
      user: user,
      team: team ?? this.team,
    );
  }
}

class MatchSet {
  const MatchSet({
    required this.id,
    required this.setNumber,
    this.sideAScore = 0,
    this.sideBScore = 0,
    this.winnerSide,
    this.startedAt,
    this.endedAt,
  });

  factory MatchSet.fromJson(Map<String, dynamic> json) {
    return MatchSet(
      id: json['id']?.toString() ?? '',
      setNumber: (json['setNumber'] as num?)?.toInt() ?? 0,
      sideAScore: (json['sideAScore'] as num?)?.toInt() ?? 0,
      sideBScore: (json['sideBScore'] as num?)?.toInt() ?? 0,
      winnerSide: json['winnerSide'] as String?,
      startedAt: json['startedAt'] as String?,
      endedAt: json['endedAt'] as String?,
    );
  }

  final String id;
  final int setNumber;
  final int sideAScore;
  final int sideBScore;
  final String? winnerSide;
  final String? startedAt;
  final String? endedAt;

  /// Set is still being played (no winner yet).
  bool get isOpen => winnerSide == null;
}

class MatchTimelinePoint {
  const MatchTimelinePoint({
    required this.id,
    required this.pointNumber,
    required this.scoringSide,
    this.sideAScoreAfter = 0,
    this.sideBScoreAfter = 0,
    this.isUndone = false,
    this.recordedBy,
    this.recordedAt,
  });

  factory MatchTimelinePoint.fromJson(Map<String, dynamic> json) {
    return MatchTimelinePoint(
      id: json['id']?.toString() ?? '',
      pointNumber: (json['pointNumber'] as num?)?.toInt() ?? 0,
      scoringSide: json['scoringSide']?.toString() ?? '',
      sideAScoreAfter: (json['sideAScoreAfter'] as num?)?.toInt() ?? 0,
      sideBScoreAfter: (json['sideBScoreAfter'] as num?)?.toInt() ?? 0,
      isUndone: json['isUndone'] as bool? ?? false,
      recordedBy: json['recordedBy']?.toString(),
      recordedAt: json['recordedAt'] as String?,
    );
  }

  final String id;
  final int pointNumber;
  final String scoringSide;
  final int sideAScoreAfter;
  final int sideBScoreAfter;
  final bool isUndone;
  final String? recordedBy;
  final String? recordedAt;
}

class MatchModel {
  const MatchModel({
    required this.id,
    required this.sportId,
    required this.matchType,
    required this.status,
    this.tournamentId,
    this.tournamentRoundId,
    this.matchFormat,
    this.venue,
    this.venueId,
    this.venueDetails,
    this.scheduledAt,
    this.startedAt,
    this.finishedAt,
    this.winnerSide,
    this.createdBy,
    this.startedBy,
    this.participants = const [],
    this.sets = const [],
    this.sport,
    this.createdAt,
    this.updatedAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id']?.toString() ?? '',
      sportId: json['sportId']?.toString() ?? '',
      tournamentId: json['tournamentId']?.toString(),
      tournamentRoundId: json['tournamentRoundId']?.toString(),
      matchType: json['matchType']?.toString() ?? 'singles',
      matchFormat: json['matchFormat'] is Map
          ? MatchFormat.fromJson(
              Map<String, dynamic>.from(json['matchFormat'] as Map),
            )
          : null,
      venue: json['venue'] as String?,
      venueId: json['venueId']?.toString(),
      venueDetails: json['venueDetails'] is Map
          ? MatchVenueDetails.fromJson(
              Map<String, dynamic>.from(json['venueDetails'] as Map),
            )
          : null,
      scheduledAt: json['scheduledAt'] as String?,
      startedAt: json['startedAt'] as String?,
      finishedAt: json['finishedAt'] as String?,
      status: json['status']?.toString() ?? 'scheduled',
      winnerSide: json['winnerSide'] as String?,
      createdBy: json['createdBy']?.toString(),
      startedBy: json['startedBy']?.toString() ?? json['started_by']?.toString(),
      participants: json['participants'] is List
          ? (json['participants'] as List)
              .map(
                (e) => MatchParticipant.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList()
          : const [],
      sets: () {
        final list = json['sets'] is List
            ? (json['sets'] as List)
                .map(
                  (e) => MatchSet.fromJson(Map<String, dynamic>.from(e as Map)),
                )
                .toList()
            : <MatchSet>[];
        list.sort((a, b) => a.setNumber.compareTo(b.setNumber));
        return list;
      }(),
      sport: json['sport'] is Map
          ? SportModel.fromJson(Map<String, dynamic>.from(json['sport'] as Map))
          : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String id;
  final String sportId;
  final String? tournamentId;
  final String? tournamentRoundId;
  final String matchType;
  final MatchFormat? matchFormat;
  final String? venue;
  final String? venueId;
  final MatchVenueDetails? venueDetails;
  final String? scheduledAt;
  final String? startedAt;
  final String? finishedAt;
  final String status;
  final String? winnerSide;
  final String? createdBy;
  /// User who pressed Start Match and may score / control the match.
  final String? startedBy;
  final List<MatchParticipant> participants;
  final List<MatchSet> sets;
  final SportModel? sport;
  final String? createdAt;
  final String? updatedAt;

  bool get isLive => status == 'ongoing' || status == 'paused';
  bool get isCompleted => status == 'completed';
  bool get isTeamMatch =>
      matchType == 'team' || participants.any((p) => p.isTeamSide);

  /// Only the BE `startedBy` user may score / pause / end while live.
  bool canManageScoring(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    if (!isLive) return false;
    final controller = startedBy?.trim();
    if (controller == null || controller.isEmpty) return false;
    return controller == userId;
  }

  MatchSet? get currentSet {
    if (sets.isEmpty) return null;
    final sorted = [...sets]..sort((a, b) => a.setNumber.compareTo(b.setNumber));
    // Prefer the highest set number that is still open (no winner).
    final open = sorted.where((s) => s.isOpen).toList();
    if (open.isNotEmpty) return open.last;
    return sorted.last;
  }

  /// Real player or team name for a side — never "Side A/B".
  String sideLabel(String side) {
    final sideParts = participants.where((p) => p.side == side).toList();
    if (sideParts.isEmpty) return 'TBD';

    if (isTeamMatch) {
      final teamNames = <String>[];
      for (final p in sideParts) {
        final name = p.team?.displayLabel.trim();
        if (name != null && name.isNotEmpty && name.toLowerCase() != 'team') {
          if (!teamNames.contains(name)) teamNames.add(name);
        }
      }
      if (teamNames.isNotEmpty) return teamNames.join(' / ');
    }

    final playerNames = sideParts
        .map((p) => p.displayName)
        .where((n) => n.isNotEmpty)
        .toList();
    if (playerNames.isNotEmpty) return playerNames.join(' / ');

    if (isTeamMatch) return 'Team $side';
    return 'Player $side';
  }

  String get matchupLabel => '${sideLabel('A')} vs ${sideLabel('B')}';

  String get scoreSummary {
    final completed = sets.where((s) => s.winnerSide != null).toList();
    if (completed.isEmpty) {
      final current = currentSet;
      if (current == null) return '-';
      return '${current.sideAScore}-${current.sideBScore}';
    }
    final aWins = completed.where((s) => s.winnerSide == 'A').length;
    final bWins = completed.where((s) => s.winnerSide == 'B').length;
    return '$aWins-$bWins';
  }

  String get resultLabel {
    if (status == 'ongoing') return 'LIVE';
    if (status == 'paused') return 'Paused';
    if (status == 'scheduled') return 'Upcoming';
    if (status == 'cancelled') return 'Cancelled';
    if (winnerSide == 'A') return '${sideLabel('A')} won';
    if (winnerSide == 'B') return '${sideLabel('B')} won';
    return 'Completed';
  }

  String get venueDisplay =>
      venueDetails?.name ?? venue ?? venueDetails?.city ?? '';

  int get setsToWin =>
      matchFormat?.setsToWin ??
      ((matchFormat?.bestOfSets ?? 1) + 1) ~/ 2;

  int get bestOfSets => matchFormat?.bestOfSets ?? 1;

  int setsWonBy(String side) =>
      sets.where((s) => s.winnerSide == side).length;

  String get formatLabel => 'Best of $bestOfSets';

  MatchModel copyWith({
    List<MatchParticipant>? participants,
    String? startedBy,
    String? status,
    String? winnerSide,
  }) {
    return MatchModel(
      id: id,
      sportId: sportId,
      tournamentId: tournamentId,
      tournamentRoundId: tournamentRoundId,
      matchType: matchType,
      matchFormat: matchFormat,
      venue: venue,
      venueId: venueId,
      venueDetails: venueDetails,
      scheduledAt: scheduledAt,
      startedAt: startedAt,
      finishedAt: finishedAt,
      status: status ?? this.status,
      winnerSide: winnerSide ?? this.winnerSide,
      createdBy: createdBy,
      startedBy: startedBy ?? this.startedBy,
      participants: participants ?? this.participants,
      sets: sets,
      sport: sport,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class MatchVenueDetails {
  const MatchVenueDetails({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
  });

  factory MatchVenueDetails.fromJson(Map<String, dynamic> json) {
    return MatchVenueDetails(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
    );
  }

  final String id;
  final String name;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
}

class CreateMatchParticipant {
  const CreateMatchParticipant({
    required this.side,
    this.phoneNumber,
    this.fullName,
    this.teamId,
  });

  final String side;
  final String? phoneNumber;
  final String? fullName;
  final String? teamId;

  Map<String, dynamic> toJson() => {
        'side': side,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (fullName != null) 'fullName': fullName,
        if (teamId != null) 'teamId': teamId,
      };
}

class CreateMatchRequest {
  const CreateMatchRequest({
    required this.matchType,
    required this.participants,
    required this.bestOfSets,
    this.sportCode,
    this.sportId,
    this.venueId,
    this.venue,
    this.scheduledAt,
    this.tournamentId,
    this.tournamentRoundId,
  });

  final String? sportCode;
  final String? sportId;
  final String matchType;
  final int bestOfSets;
  final List<CreateMatchParticipant> participants;
  final String? venueId;
  final String? venue;
  final String? scheduledAt;
  final String? tournamentId;
  final String? tournamentRoundId;

  Map<String, dynamic> toJson() => {
        if (sportCode != null) 'sportCode': sportCode,
        if (sportId != null) 'sportId': sportId,
        'matchType': matchType,
        'bestOfSets': bestOfSets,
        'participants': participants.map((p) => p.toJson()).toList(),
        if (venueId != null) 'venueId': venueId,
        if (venue != null) 'venue': venue,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        if (tournamentId != null) 'tournamentId': tournamentId,
        if (tournamentRoundId != null) 'tournamentRoundId': tournamentRoundId,
      };
}
