import 'package:sportheroes_mobile/features/sports/models/sport_model.dart';

class SportRules {
  const SportRules({
    required this.sportId,
    required this.sportCode,
    this.supportsSingles = true,
    this.supportsDoubles = true,
    this.supportsTeamMatches = false,
    this.usesTeamRoster = false,
    this.hasCaptain = false,
    this.hasViceCaptain = false,
    this.minRosterSize,
    this.maxRosterSize,
    this.minPlayersPerSide,
    this.maxPlayersPerSide,
    this.matchFormat,
    this.scoringConfig,
  });

  factory SportRules.fromJson(Map<String, dynamic> json) {
    return SportRules(
      sportId: json['sportId']?.toString() ?? '',
      sportCode: json['sportCode']?.toString() ?? '',
      supportsSingles: json['supportsSingles'] as bool? ?? true,
      supportsDoubles: json['supportsDoubles'] as bool? ?? true,
      supportsTeamMatches: json['supportsTeamMatches'] as bool? ?? false,
      usesTeamRoster: json['usesTeamRoster'] as bool? ?? false,
      hasCaptain: json['hasCaptain'] as bool? ?? false,
      hasViceCaptain: json['hasViceCaptain'] as bool? ?? false,
      minRosterSize: (json['minRosterSize'] as num?)?.toInt(),
      maxRosterSize: (json['maxRosterSize'] as num?)?.toInt(),
      minPlayersPerSide: (json['minPlayersPerSide'] as num?)?.toInt(),
      maxPlayersPerSide: (json['maxPlayersPerSide'] as num?)?.toInt(),
      matchFormat: json['matchFormat'] is Map
          ? MatchFormat.fromJson(
              Map<String, dynamic>.from(json['matchFormat'] as Map),
            )
          : null,
      scoringConfig: json['scoringConfig'] is Map
          ? Map<String, dynamic>.from(json['scoringConfig'] as Map)
          : null,
    );
  }

  final String sportId;
  final String sportCode;
  final bool supportsSingles;
  final bool supportsDoubles;
  final bool supportsTeamMatches;
  final bool usesTeamRoster;
  final bool hasCaptain;
  final bool hasViceCaptain;
  final int? minRosterSize;
  final int? maxRosterSize;
  final int? minPlayersPerSide;
  final int? maxPlayersPerSide;
  final MatchFormat? matchFormat;
  final Map<String, dynamic>? scoringConfig;

  List<String> get supportedMatchTypes {
    final types = <String>[];
    if (supportsSingles) types.add('singles');
    if (supportsDoubles) types.add('doubles');
    if (supportsTeamMatches) types.add('team');
    return types;
  }

  List<String> get assignableRoles {
    final roles = <String>['member'];
    if (hasCaptain) roles.add('captain');
    if (hasViceCaptain) roles.add('vice_captain');
    return roles;
  }
}
