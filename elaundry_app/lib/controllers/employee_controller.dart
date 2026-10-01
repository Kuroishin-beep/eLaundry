import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/employee_models.dart';
import '../services/store_context.dart';

class EmployeeController {
  EmployeeController({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<String> get _storeId async =>
      (await StoreContextResolver(firestore: _firestore, auth: _auth).resolve())
          .storeId;

  Future<CollectionReference<Map<String, dynamic>>> get _store async =>
      _firestore
          .collection('stores')
          .doc(await _storeId)
          .collection('employees');

  Future<CollectionReference<Map<String, dynamic>>> get _roles async =>
      _firestore.collection('stores').doc(await _storeId).collection('roles');

  Stream<List<RoleItem>> watchRoles() async* {
    final roles = await _roles;
    yield* roles.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => RoleItem.fromMap(doc.data(), doc.id))
              .toList(),
    );
  }

  Stream<List<StaffMember>> watchEmployees() async* {
    final store = await _store;
    yield* store
        .where('record_type', isEqualTo: 'employee')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => StaffMember.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<void> saveRole(RoleItem role) async {
    final roles = await _roles;
    final store = await _store;
    await roles.doc(role.id).set(role.toMap());
    final assignedEmployees =
        await store
            .where('record_type', isEqualTo: 'employee')
            .where('role', isEqualTo: role.name)
            .get();
    for (final employee in assignedEmployees.docs) {
      await employee.reference.update({
        'role_permissions': role.permissions.toMap(),
      });
      final accountUid = employee.data()['account_uid'] as String?;
      if (accountUid != null && accountUid.isNotEmpty) {
        await _userProfile(accountUid).set({
          'role_permissions': role.permissions.toMap(),
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> deleteRole(String roleId) async {
    final roles = await _roles;
    final store = await _store;
    final role = await roles.doc(roleId).get();
    final assigned =
        await store
            .where('record_type', isEqualTo: 'employee')
            .where('role', isEqualTo: role.data()?['name'])
            .limit(1)
            .get();
    if (assigned.docs.isNotEmpty) {
      throw StateError('This role is assigned to an employee.');
    }
    await roles.doc(roleId).delete();
  }

  Future<StaffMember> createEmployee(StaffMember employee) async {
    final roles = await _roles;
    final store = await _store;
    final role =
        await roles.where('name', isEqualTo: employee.role).limit(1).get();
    if (role.docs.isEmpty) {
      throw StateError('Create the employee role before adding staff.');
    }

    final uid = await _createAuthAccount(
      email: employee.email.trim(),
      pin: employee.pin,
    );

    final saved = employee.copyWith(id: uid);
    await store.doc(uid).set({
      ...saved.toMap(),
      'record_type': 'employee',
      'account_uid': uid,
      'role_permissions': role.docs.first.data()['permissions'] ?? {},
    });
    await _userProfile(uid).set({
      'storeId': await _storeId,
      'role': saved.role,
      'record_type': 'employee',
      'role_permissions': role.docs.first.data()['permissions'] ?? {},
    }, SetOptions(merge: true));
    return saved;
  }

  Future<void> updateEmployee(StaffMember employee) async {
    final roles = await _roles;
    final store = await _store;
    final role =
        await roles.where('name', isEqualTo: employee.role).limit(1).get();
    if (role.docs.isEmpty) {
      throw StateError('The selected employee role no longer exists.');
    }
    await store.doc(employee.id).update({
      ...employee.toMap(),
      'role_permissions': role.docs.first.data()['permissions'] ?? {},
    });
    await _userProfile(employee.id).set({
      'storeId': await _storeId,
      'role': employee.role,
      'record_type': 'employee',
      'role_permissions': role.docs.first.data()['permissions'] ?? {},
    }, SetOptions(merge: true));
  }

  Future<void> deleteEmployee(String employeeId) async {
    final store = await _store;
    await store.doc(employeeId).delete();
    // Keep the account profile, but remove its store membership and access.
    await _userProfile(employeeId).set({
      'storeId': null,
      'role': null,
      'record_type': 'employee',
      'role_permissions': const {},
    }, SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> _userProfile(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<String> _createAuthAccount({
    required String email,
    required String pin,
  }) async {
    final secondaryAuth = await _secondaryAuth();
    try {
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: pin,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw StateError('Unable to create the employee account.');
      }
      return uid;
    } finally {
      await secondaryAuth.signOut();
    }
  }

  Future<FirebaseAuth> _secondaryAuth() async {
    const appName = 'employee-account-creation';
    FirebaseApp app;
    try {
      app = Firebase.app(appName);
    } catch (_) {
      app = await Firebase.initializeApp(
        name: appName,
        options: Firebase.app().options,
      );
    }
    return FirebaseAuth.instanceFor(app: app);
  }
}
