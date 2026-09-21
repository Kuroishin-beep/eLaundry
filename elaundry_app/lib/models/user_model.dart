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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      profileImage: map['profileImage'],
      createdAt:
          map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
    );
  }
}
