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
    this.city,
    this.country,
    this.gender,
  });

  final String? fullName;
  final String? displayName;
  final String? city;
  final String? country;
  final String? gender;

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'fullName': fullName,
      if (displayName != null) 'displayName': displayName,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (gender != null) 'gender': gender,
    };
  }
}
