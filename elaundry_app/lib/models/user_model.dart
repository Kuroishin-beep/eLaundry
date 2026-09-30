import 'employee_models.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImage;
  final DateTime? createdAt;
  final String? storeId;
  final String? role;
  final RolePermissions permissions;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    this.createdAt,
    this.storeId,
    this.role,
    this.permissions = const RolePermissions(),
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
      'storeId': storeId,
      'role': role,
      'role_permissions': permissions.toMap(),
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
      storeId: map['storeId'] as String?,
      role: map['role'] as String?,
      permissions: RolePermissions.fromMap(
        map['role_permissions'] as Map<String, dynamic>?,
      ),
    );
  }
}
