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

    final employees = _firestore.collectionGroup('employees');
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot =
          await employees
              .where('account_uid', isEqualTo: user.uid)
              .limit(1)
              .get();
      if (snapshot.docs.isEmpty && user.email != null) {
        snapshot =
            await employees
                .where('email', isEqualTo: user.email!.trim().toLowerCase())
                .limit(1)
                .get();
      }
    } on FirebaseException catch (error) {
      throw StateError(
        'Unable to resolve the employee store membership '
        '(${error.code}: ${error.message ?? 'Firestore denied the query'}).',
      );
    }
    if (snapshot.docs.isEmpty) {
      throw StateError('This account is not assigned to a store.');
    }

    final employee = snapshot.docs.first;
    final store = employee.reference.parent.parent;
    if (store == null) {
      throw StateError('The employee store membership is invalid.');
    }
    return StoreContext(
      storeId: store.id,
      isOwner: false,
      role: employee.data()['role'] as String?,
      permissions: RolePermissions.fromMap(
        _map(employee.data()['role_permissions']),
      ),
    );
  }

  static Map<String, dynamic>? _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
