import 'package:sportheroes_mobile/features/sports/models/sport_model.dart';

class TournamentModel {
  const TournamentModel({
    required this.id,
    required this.sportId,
    required this.name,
    required this.format,
    required this.participantKind,
    required this.startDate,
    required this.status,
    this.organizerId,
    this.bannerUrl,
    this.description,
    this.venue,
    this.city,
    this.state,
    this.country,
    this.registrationStartDate,
    this.registrationEndDate,
    this.endDate,
    this.maxParticipants,
    this.sport,
    this.createdAt,
    this.updatedAt,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id']?.toString() ?? '',
      sportId: json['sportId']?.toString() ?? '',
      organizerId: json['organizerId']?.toString(),
      name: json['name']?.toString() ?? '',
      format: json['format']?.toString() ?? '',
      participantKind: json['participantKind']?.toString() ?? 'individual',
      bannerUrl: json['bannerUrl'] as String?,
      description: json['description'] as String?,
      venue: json['venue'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      registrationStartDate: json['registrationStartDate'] as String?,
      registrationEndDate: json['registrationEndDate'] as String?,
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate'] as String?,
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      status: json['status']?.toString() ?? 'draft',
      sport: json['sport'] is Map
          ? SportModel.fromJson(Map<String, dynamic>.from(json['sport'] as Map))
          : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String id;
  final String sportId;
  final String? organizerId;
  final String name;
  final String format;
  final String participantKind;
  final String? bannerUrl;
  final String? description;
  final String? venue;
  final String? city;
  final String? state;
  final String? country;
  final String? registrationStartDate;
  final String? registrationEndDate;
  final String startDate;
  final String? endDate;
  final int? maxParticipants;
  final String status;
  final SportModel? sport;
  final String? createdAt;
  final String? updatedAt;

  String get formatLabel => format.replaceAll('_', ' ');

  String get statusLabel => status.replaceAll('_', ' ');

  String get dateRange {
    if (endDate == null || endDate!.isEmpty) return startDate;
    return '$startDate → $endDate';
  }
}

class TournamentParticipant {
  const TournamentParticipant({
    required this.id,
    required this.tournamentId,
    required this.status,
    this.userId,
    this.teamId,
    this.seedNumber,
    this.registeredAt,
  });

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) {
    return TournamentParticipant(
      id: json['id']?.toString() ?? '',
      tournamentId: json['tournamentId']?.toString() ?? '',
      userId: json['userId']?.toString(),
      teamId: json['teamId']?.toString(),
      seedNumber: (json['seedNumber'] as num?)?.toInt(),
      status: json['status']?.toString() ?? 'registered',
      registeredAt: json['registeredAt'] as String?,
    );
  }

  final String id;
  final String tournamentId;
  final String? userId;
  final String? teamId;
  final int? seedNumber;
  final String status;
  final String? registeredAt;
}

class TournamentRound {
  const TournamentRound({
    required this.id,
    required this.tournamentId,
    required this.roundNumber,
    this.roundName,
    this.createdAt,
  });

  factory TournamentRound.fromJson(Map<String, dynamic> json) {
    return TournamentRound(
      id: json['id']?.toString() ?? '',
      tournamentId: json['tournamentId']?.toString() ?? '',
      roundNumber: (json['roundNumber'] as num?)?.toInt() ?? 0,
      roundName: json['roundName'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  final String id;
  final String tournamentId;
  final int roundNumber;
  final String? roundName;
  final String? createdAt;
}

class TournamentStanding {
  const TournamentStanding({
    required this.id,
    required this.tournamentId,
    this.userId,
    this.teamId,
    this.matchesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.points = 0,
    this.position,
    this.updatedAt,
  });

  factory TournamentStanding.fromJson(Map<String, dynamic> json) {
    return TournamentStanding(
      id: json['id']?.toString() ?? '',
      tournamentId: json['tournamentId']?.toString() ?? '',
      userId: json['userId']?.toString(),
      teamId: json['teamId']?.toString(),
      matchesPlayed: (json['matchesPlayed'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      position: (json['position'] as num?)?.toInt(),
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String id;
  final String tournamentId;
  final String? userId;
  final String? teamId;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int points;
  final int? position;
  final String? updatedAt;
}

class CreateTournamentRequest {
  const CreateTournamentRequest({
    required this.sportId,
    required this.name,
    required this.format,
    required this.participantKind,
    required this.startDate,
    this.bannerUrl,
    this.description,
    this.venue,
    this.city,
    this.state,
    this.country,
    this.registrationStartDate,
    this.registrationEndDate,
    this.endDate,
    this.maxParticipants,
  });

  final String sportId;
  final String name;
  final String format;
  final String participantKind;
  final String startDate;
  final String? bannerUrl;
  final String? description;
  final String? venue;
  final String? city;
  final String? state;
  final String? country;
  final String? registrationStartDate;
  final String? registrationEndDate;
  final String? endDate;
  final int? maxParticipants;

  Map<String, dynamic> toJson() => {
        'sportId': sportId,
        'name': name,
        'format': format,
        'participantKind': participantKind,
        'startDate': startDate,
        if (bannerUrl != null) 'bannerUrl': bannerUrl,
        if (description != null) 'description': description,
        if (venue != null) 'venue': venue,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (country != null) 'country': country,
        if (registrationStartDate != null)
          'registrationStartDate': registrationStartDate,
        if (registrationEndDate != null)
          'registrationEndDate': registrationEndDate,
        if (endDate != null) 'endDate': endDate,
        if (maxParticipants != null) 'maxParticipants': maxParticipants,
      };
}
