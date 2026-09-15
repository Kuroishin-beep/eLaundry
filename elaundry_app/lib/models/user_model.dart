class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImage;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    this.createdAt,
  });
}
