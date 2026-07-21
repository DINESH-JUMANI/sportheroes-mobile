class UserModel {
  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.phoneNumber,
    this.email,
    this.fullName,
    this.displayName,
    this.profilePictureUrl,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.state,
    this.country,
    this.isActive = true,
    this.isProfileComplete = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firebaseUid: json['firebaseUid']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      displayName: json['displayName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String id;
  final String firebaseUid;
  final String phoneNumber;
  final String? email;
  final String? fullName;
  final String? displayName;
  final String? profilePictureUrl;
  final String? dateOfBirth;
  final String? gender;
  final String? city;
  final String? state;
  final String? country;
  final bool isActive;
  final bool isProfileComplete;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'phoneNumber': phoneNumber,
      'email': email,
      'fullName': fullName,
      'displayName': displayName,
      'profilePictureUrl': profilePictureUrl,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'city': city,
      'state': state,
      'country': country,
      'isActive': isActive,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? firebaseUid,
    String? phoneNumber,
    String? email,
    String? fullName,
    String? displayName,
    String? profilePictureUrl,
    String? dateOfBirth,
    String? gender,
    String? city,
    String? state,
    String? country,
    bool? isActive,
    bool? isProfileComplete,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      isActive: isActive ?? this.isActive,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayLabel {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    if (phoneNumber.trim().isNotEmpty) return phoneNumber.trim();
    return 'Player';
  }

  String get avatarInitial {
    final label = displayLabel;
    if (label.isEmpty) return '?';
    return label.substring(0, 1).toUpperCase();
  }
}

/// Lightweight user summary nested in team/match responses.
class UserSummary {
  const UserSummary({
    required this.id,
    this.fullName,
    this.displayName,
    this.phoneNumber,
    this.profilePictureUrl,
    this.city,
    this.country,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] as String?,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }

  final String id;
  final String? fullName;
  final String? displayName;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final String? city;
  final String? country;

  String get displayLabel {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    return 'Player';
  }
}
