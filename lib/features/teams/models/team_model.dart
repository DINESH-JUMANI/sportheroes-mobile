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
      userId: json['userId']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      joinedAt: json['joinedAt'] as String?,
      leftAt: json['leftAt'] as String?,
      isActive: json['isActive'] as bool? ?? true,
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
    this.createdAt,
    this.updatedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final membersRaw = json['members'];
    return TeamModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortName: json['shortName'] as String?,
      logoUrl: json['logoUrl'] as String?,
      hasLogo: json['hasLogo'] as bool? ?? false,
      logoMimeType: json['logoMimeType'] as String?,
      description: json['description'] as String?,
      captainId: json['captainId']?.toString(),
      viceCaptainId: json['viceCaptainId']?.toString(),
      createdBy: json['createdBy']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      members: membersRaw is List
          ? membersRaw
              .map((e) => TeamMember.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
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
  final String? createdAt;
  final String? updatedAt;

  static const List<String> assignableRoles = [
    'member',
    'admin',
    'captain',
    'vice_captain',
  ];

  String get captainName {
    final captain = members.where((m) => m.role == 'captain').firstOrNull;
    if (captain != null) return captain.user?.displayLabel ?? '—';
    if (captainId != null) {
      final byId = members.where((m) => m.userId == captainId).firstOrNull;
      return byId?.user?.displayLabel ?? '—';
    }
    return '—';
  }

  int get memberCount => members.where((m) => m.isActive).length;

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

