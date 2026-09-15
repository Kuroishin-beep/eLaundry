import 'user_model.dart';

class AuthModel {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final DateTime? expiresAt;
  final UserModel user;

  const AuthModel({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresAt,
    required this.user,
  });
}
