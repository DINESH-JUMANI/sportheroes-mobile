class MatchFormat {
  const MatchFormat({
    this.setsToWin,
    this.bestOfSets,
    this.pointsPerSet,
    this.winByMargin,
    this.deuceEnabled,
  });

  factory MatchFormat.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MatchFormat();
    return MatchFormat(
      setsToWin: _asInt(json['sets_to_win'] ?? json['setsToWin']),
      bestOfSets: _asInt(json['best_of_sets'] ?? json['bestOfSets']),
      pointsPerSet: _asInt(json['points_per_set'] ?? json['pointsPerSet']),
      winByMargin: _asInt(json['win_by_margin'] ?? json['winByMargin']),
      deuceEnabled: json['deuce_enabled'] as bool? ??
          json['deuceEnabled'] as bool?,
    );
  }

  final int? setsToWin;
  final int? bestOfSets;
  final int? pointsPerSet;
  final int? winByMargin;
  final bool? deuceEnabled;

  Map<String, dynamic> toJson() => {
        'sets_to_win': setsToWin,
        'best_of_sets': bestOfSets,
        'points_per_set': pointsPerSet,
        'win_by_margin': winByMargin,
        'deuce_enabled': deuceEnabled,
      };

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class SportModel {
  const SportModel({
    required this.id,
    required this.name,
    required this.code,
    this.iconUrl,
    this.description,
    this.isTeamSport = false,
    this.defaultMatchFormat,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      iconUrl: json['iconUrl'] as String?,
      description: json['description'] as String?,
      isTeamSport: json['isTeamSport'] as bool? ?? false,
      defaultMatchFormat: json['defaultMatchFormat'] is Map
          ? MatchFormat.fromJson(
              Map<String, dynamic>.from(json['defaultMatchFormat'] as Map),
            )
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String id;
  final String name;
  final String code;
  final String? iconUrl;
  final String? description;
  final bool isTeamSport;
  final MatchFormat? defaultMatchFormat;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  String get emoji => switch (code.toUpperCase()) {
        'TT' => '🏓',
        'BAD' || 'BD' || 'BADMINTON' => '🏸',
        'VB' || 'VOLLEYBALL' => '🏐',
        'PBL' || 'PB' || 'PICKLEBALL' => '🥒',
        'TEN' || 'TENNIS' => '🎾',
        _ => '🏅',
      };
}

class PlayerSportProfile {
  const PlayerSportProfile({
    required this.id,
    required this.userId,
    required this.sportId,
    this.skillLevel,
    this.rankingPoints = 0,
    this.isPrimarySport = false,
    this.sport,
    this.createdAt,
    this.updatedAt,
  });

  factory PlayerSportProfile.fromJson(Map<String, dynamic> json) {
    return PlayerSportProfile(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      sportId: json['sportId']?.toString() ?? '',
      skillLevel: json['skillLevel'] as String?,
      rankingPoints: (json['rankingPoints'] as num?)?.toInt() ?? 0,
      isPrimarySport: json['isPrimarySport'] as bool? ?? false,
      sport: json['sport'] is Map
          ? SportModel.fromJson(Map<String, dynamic>.from(json['sport'] as Map))
          : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String id;
  final String userId;
  final String sportId;
  final String? skillLevel;
  final int rankingPoints;
  final bool isPrimarySport;
  final SportModel? sport;
  final String? createdAt;
  final String? updatedAt;
}

class CreatePlayerProfileRequest {
  const CreatePlayerProfileRequest({
    required this.sportId,
    this.skillLevel,
    this.isPrimarySport,
  });

  final String sportId;
  final String? skillLevel;
  final bool? isPrimarySport;

  Map<String, dynamic> toJson() => {
        'sportId': sportId,
        if (skillLevel != null) 'skillLevel': skillLevel,
        if (isPrimarySport != null) 'isPrimarySport': isPrimarySport,
      };
}

class UpdatePlayerProfileRequest {
  const UpdatePlayerProfileRequest({this.skillLevel, this.isPrimarySport});

  final String? skillLevel;
  final bool? isPrimarySport;

  Map<String, dynamic> toJson() => {
        if (skillLevel != null) 'skillLevel': skillLevel,
        if (isPrimarySport != null) 'isPrimarySport': isPrimarySport,
      };
}
