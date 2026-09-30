import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/employee_models.dart';

class StoreContext {
  const StoreContext({
    required this.storeId,
    required this.isOwner,
    this.role,
    this.permissions = const RolePermissions(),
  });

  final String storeId;
  final bool isOwner;
  final String? role;
  final RolePermissions permissions;
}

class StoreContextResolver {
  StoreContextResolver({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<StoreContext> resolve() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('A signed-in user is required.');

    final ownerStore = _firestore.collection('stores').doc(user.uid);
    try {
      if ((await ownerStore.get()).exists) {
        return StoreContext(storeId: user.uid, isOwner: true);
      }
    } on FirebaseException {
      // Employee accounts are intentionally denied access to the store root.
    }

    // Employee accounts carry their store membership in their user profile.
    // Reading this document avoids a collection-group query, which cannot be
    // authorized safely for an employee account.
    try {
      final profile = await _firestore.collection('users').doc(user.uid).get();
      if (!profile.exists) {
        throw StateError('This account is not assigned to a store.');
      }
      final data = profile.data()!;
      final storeId = data['storeId'] as String?;
      if (storeId == null || storeId.isEmpty) {
        throw StateError('This account is not assigned to a store.');
      }
      return StoreContext(
        storeId: storeId,
        isOwner: false,
        role: data['role'] as String?,
        permissions: RolePermissions.fromMap(_map(data['role_permissions'])),
      );
    } on FirebaseException catch (error) {
      throw StateError(
        'Unable to resolve the employee store profile '
        '(${error.code}: ${error.message ?? 'Firestore denied the query'}).',
      );
    }
  }

  static Map<String, dynamic>? _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
