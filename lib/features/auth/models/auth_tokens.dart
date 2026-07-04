class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
    this.expiresAt,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: json['expiresIn']?.toString(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
    );
  }

  final String accessToken;
  final String tokenType;
  final String? expiresIn;
  final DateTime? expiresAt;

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}
