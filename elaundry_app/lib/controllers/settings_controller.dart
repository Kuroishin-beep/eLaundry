import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/store_model.dart';
import '../models/user_model.dart';
import '../services/store_context.dart';

class SettingsController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;

  /// Fetch user profile from Firestore
  Future<UserModel?> getUserProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return UserModel(
        id: uid,
        fullName: _auth.currentUser?.displayName ?? 'Juan Dela Cruz',
        email: _auth.currentUser?.email ?? 'you@example.com',
        phone: _auth.currentUser?.phoneNumber,
        profileImage: _auth.currentUser?.photoURL,
        createdAt: DateTime.now(),
      );
    }
    return UserModel.fromMap(doc.data()!, uid);
  }

  /// Fetch or initialize store settings for the current user
  Future<StoreModel> getStoreSettings() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('No user logged in.');

    final storeId =
        (await StoreContextResolver(
              firestore: _firestore,
              auth: _auth,
            ).resolve())
            .storeId;
    final doc = await _firestore.collection('stores').doc(storeId).get();
    if (!doc.exists || doc.data() == null) {
      final initialStore = StoreModel(
        id: storeId,
        storeName: '',
        address: '',
        pin: '',
        notificationsEnabled: true,
      );
      await _firestore
          .collection('stores')
          .doc(storeId)
          .set(initialStore.toMap());
      return initialStore;
    }
    return StoreModel.fromMap(doc.data()!, storeId);
  }

  /// Update Account Name
  Future<void> updateAccountName(String newName) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _auth.currentUser?.updateDisplayName(newName);
    await _firestore.collection('users').doc(uid).update({'fullName': newName});
  }

  /// Update Email Address
  Future<void> updateEmail(String newEmail) async {
    final uid = currentUserId;
    if (uid == null) return;

    await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
    await _firestore.collection('users').doc(uid).update({'email': newEmail});
  }

  /// Update Password
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in.');
    await user.updatePassword(newPassword);
  }

  /// Update Store Settings field-by-field or all at once
  Future<void> updateStoreSettings({
    String? storeName,
    String? address,
    String? pin,
    bool? notificationsEnabled,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    final updates = <String, dynamic>{'updatedAt': DateTime.now()};
    if (storeName != null) updates['storeName'] = storeName;
    if (address != null) updates['address'] = address;
    if (pin != null) updates['pin'] = pin;
    if (notificationsEnabled != null) {
      updates['notificationsEnabled'] = notificationsEnabled;
    }

    await _firestore
        .collection('stores')
        .doc(
          (await StoreContextResolver(
                firestore: _firestore,
                auth: _auth,
              ).resolve())
              .storeId,
        )
        .set(updates, SetOptions(merge: true));
  }
}
