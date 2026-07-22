import 'package:sportheroes_mobile/features/auth/models/user_model.dart';

/// Team member roles: admin, captain, vice_captain, member
class TeamMember {
  const TeamMember({
    required this.id,
    required this.userId,
    required this.role,
    this.joinedAt,
    this.leftAt,
    this.isActive = true,
    this.user,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      joinedAt: json['joinedAt'] as String? ?? json['joined_at'] as String?,
      leftAt: json['leftAt'] as String? ?? json['left_at'] as String?,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      user: json['user'] is Map
          ? UserSummary.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
    );
  }

  final String id;
  final String userId;
  final String role;
  final String? joinedAt;
  final String? leftAt;
  final bool isActive;
  final UserSummary? user;

  bool get isAdmin => role == 'admin';
  bool get isCaptain => role == 'captain';

  String get roleLabel => role.replaceAll('_', ' ');
}

class TeamModel {
  const TeamModel({
    required this.id,
    required this.name,
    this.shortName,
    this.logoUrl,
    this.hasLogo = false,
    this.logoMimeType,
    this.description,
    this.captainId,
    this.viceCaptainId,
    this.createdBy,
    this.isActive = true,
    this.members = const [],
    this.reportedMemberCount,
    this.reportedCaptainName,
    this.createdAt,
    this.updatedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final membersRaw = json['members'];
    final countRaw = json['memberCount'] ??
        json['membersCount'] ??
        (json['_count'] is Map ? (json['_count'] as Map)['members'] : null);

    String? captainLabel;
    if (json['captainName'] is String &&
        (json['captainName'] as String).trim().isNotEmpty) {
      captainLabel = (json['captainName'] as String).trim();
    } else if (json['captain'] is Map) {
      captainLabel = UserSummary.fromJson(
        Map<String, dynamic>.from(json['captain'] as Map),
      ).displayLabel;
    }

    return TeamModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortName: json['shortName'] as String? ?? json['short_name'] as String?,
      logoUrl: json['logoUrl'] as String? ?? json['logo_url'] as String?,
      hasLogo: json['hasLogo'] as bool? ?? json['has_logo'] as bool? ?? false,
      logoMimeType:
          json['logoMimeType'] as String? ?? json['logo_mime_type'] as String?,
      description: json['description'] as String?,
      captainId: json['captainId']?.toString() ?? json['captain_id']?.toString(),
      viceCaptainId:
          json['viceCaptainId']?.toString() ?? json['vice_captain_id']?.toString(),
      createdBy: json['createdBy']?.toString() ?? json['created_by']?.toString(),
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      members: membersRaw is List
          ? membersRaw
              .map((e) => TeamMember.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
      reportedMemberCount: _asInt(countRaw),
      reportedCaptainName: captainLabel,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  final String id;
  final String name;
  final String? shortName;
  final String? logoUrl;
  final bool hasLogo;
  final String? logoMimeType;
  final String? description;
  final String? captainId;
  final String? viceCaptainId;
  final String? createdBy;
  final bool isActive;
  final List<TeamMember> members;
  final int? reportedMemberCount;
  final String? reportedCaptainName;
  final String? createdAt;
  final String? updatedAt;

  static const List<String> assignableRoles = [
    'member',
    'admin',
    'captain',
    'vice_captain',
  ];

  String get captainName {
    final captain = members.where((m) => m.isActive && m.role == 'captain').firstOrNull;
    if (captain != null) return captain.user?.displayLabel ?? '—';
    if (captainId != null) {
      final byId = members
          .where((m) => m.isActive && m.userId == captainId)
          .firstOrNull;
      if (byId != null) return byId.user?.displayLabel ?? '—';
    }
    if (reportedCaptainName != null && reportedCaptainName!.trim().isNotEmpty) {
      return reportedCaptainName!.trim();
    }
    return '—';
  }

  int get memberCount {
    final activeCount = members.where((m) => m.isActive).length;
    if (activeCount > 0) return activeCount;
    return reportedMemberCount ?? 0;
  }

  TeamModel copyWith({
    String? name,
    String? shortName,
    String? logoUrl,
    bool? hasLogo,
    String? logoMimeType,
    String? description,
    String? captainId,
    String? viceCaptainId,
    String? createdBy,
    bool? isActive,
    List<TeamMember>? members,
    int? reportedMemberCount,
    String? reportedCaptainName,
    String? createdAt,
    String? updatedAt,
  }) {
    return TeamModel(
      id: id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      logoUrl: logoUrl ?? this.logoUrl,
      hasLogo: hasLogo ?? this.hasLogo,
      logoMimeType: logoMimeType ?? this.logoMimeType,
      description: description ?? this.description,
      captainId: captainId ?? this.captainId,
      viceCaptainId: viceCaptainId ?? this.viceCaptainId,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      members: members ?? this.members,
      reportedMemberCount: reportedMemberCount ?? this.reportedMemberCount,
      reportedCaptainName: reportedCaptainName ?? this.reportedCaptainName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  TeamMember? memberForUser(String userId) {
    return members.where((m) => m.userId == userId && m.isActive).firstOrNull;
  }

  String? roleForUser(String userId) => memberForUser(userId)?.role;

  bool isAdmin(String userId) => roleForUser(userId) == 'admin';

  bool isCaptain(String userId) => roleForUser(userId) == 'captain';

  bool canManageTeam(String userId) => isAdmin(userId);

  bool canAddMember(String userId) {
    final role = roleForUser(userId);
    return role == 'admin' || role == 'captain';
  }

  bool canRemoveMember(String userId) {
    final role = roleForUser(userId);
    return role == 'admin' || role == 'captain';
  }

  bool canAssignRoles(String userId) => isAdmin(userId);
}

class CreateTeamRequest {
  const CreateTeamRequest({
    required this.name,
    this.shortName,
    this.description,
  });

  final String name;
  final String? shortName;
  final String? description;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (shortName != null) 'shortName': shortName,
        if (description != null) 'description': description,
      };
}

class UpdateTeamRequest {
  const UpdateTeamRequest({
    this.name,
    this.shortName,
    this.description,
  });

  final String? name;
  final String? shortName;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (shortName != null) 'shortName': shortName,
      if (description != null) 'description': description,
    };
  }
}

class AddTeamMemberRequest {
  const AddTeamMemberRequest({
    required this.phoneNumber,
    this.fullName,
    this.role = 'member',
  });

  final String phoneNumber;
  final String? fullName;
  final String role;

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        if (fullName != null) 'fullName': fullName,
        'role': role,
      };
}

class UpdateTeamMemberRequest {
  const UpdateTeamMemberRequest({this.role});

  final String? role;

  Map<String, dynamic> toJson() => {
        if (role != null) 'role': role,
      };
}

class LookupUserResult {
  const LookupUserResult({required this.found, this.user});

  factory LookupUserResult.fromJson(Map<String, dynamic> json) {
    return LookupUserResult(
      found: json['found'] as bool? ?? false,
      user: json['user'] is Map
          ? UserSummary.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
    );
  }

  final bool found;
  final UserSummary? user;
}

