import 'package:sportheroes_mobile/features/auth/models/auth_tokens.dart';
import 'package:sportheroes_mobile/features/auth/models/user_model.dart';

class LoginResponse {
  const LoginResponse({
    required this.isNewUser,
    required this.user,
    required this.tokens,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      isNewUser: json['isNewUser'] as bool? ?? false,
      user: UserModel.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? {}),
      ),
      tokens: AuthTokens.fromJson(
        Map<String, dynamic>.from(json['tokens'] as Map? ?? {}),
      ),
    );
  }

  final bool isNewUser;
  final UserModel user;
  final AuthTokens tokens;
}

class UpdateProfileRequest {
  const UpdateProfileRequest({
    this.fullName,
    this.displayName,
    this.email,
    this.profilePictureUrl,
    this.profilePictureBase64,
    this.profilePictureMimeType,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.state,
    this.country,
  });

  final String? fullName;
  final String? displayName;
  final String? email;
  final String? profilePictureUrl;
  final String? profilePictureBase64;
  final String? profilePictureMimeType;
  final String? dateOfBirth;
  final String? gender;
  final String? city;
  final String? state;
  final String? country;

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'fullName': fullName,
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      if (profilePictureBase64 != null)
        'profilePictureBase64': profilePictureBase64,
      if (profilePictureMimeType != null)
        'profilePictureMimeType': profilePictureMimeType,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
    };
  }
}
