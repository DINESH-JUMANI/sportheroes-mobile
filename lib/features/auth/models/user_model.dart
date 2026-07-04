class UserModel {
  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.phoneNumber,
    this.fullName,
    this.displayName,
    this.city,
    this.country,
    this.gender,
    this.isProfileComplete = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firebaseUid: json['firebaseUid']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      fullName: json['fullName'] as String?,
      displayName: json['displayName'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      gender: json['gender'] as String?,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
    );
  }

  final String id;
  final String firebaseUid;
  final String phoneNumber;
  final String? fullName;
  final String? displayName;
  final String? city;
  final String? country;
  final String? gender;
  final bool isProfileComplete;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'displayName': displayName,
      'city': city,
      'country': country,
      'gender': gender,
      'isProfileComplete': isProfileComplete,
    };
  }

  UserModel copyWith({
    String? id,
    String? firebaseUid,
    String? phoneNumber,
    String? fullName,
    String? displayName,
    String? city,
    String? country,
    String? gender,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      city: city ?? this.city,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
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
