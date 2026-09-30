import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/machine_model.dart';
import '../models/store_model.dart';
import '../services/store_context.dart';

class MachineController {
  MachineController({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<List<MachineItem>> watchMachines() async* {
    final collection = await _machinesCollection();
    yield* collection.snapshots().map(
      (snapshot) => snapshot.docs.map(_fromDocument).toList(),
    );
  }

  Future<List<MachineItem>> getMachines() async {
    final collection = await _machinesCollection();
    final snapshot = await collection.get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  Future<void> createMachine(MachineItem machine) async {
    _validate(machine);
    final collection = await _machinesCollection();
    final context = await _storeContext();
    final userId = currentUserId!;
    await collection.doc(machine.id).set({
      ..._toMap(machine),
      'userId': userId,
      'storeId': context.storeId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMachine(MachineItem machine) async {
    _validate(machine);
    final collection = await _machinesCollection();
    final context = await _storeContext();
    final userId = currentUserId!;
    await collection.doc(machine.id).set({
      ..._toMap(machine),
      'userId': userId,
      'storeId': context.storeId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteMachine(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Document ID cannot be empty.');
    }
    final collection = await _machinesCollection();
    await collection.doc(id).delete();
  }

  Future<CollectionReference<Map<String, dynamic>>>
  _machinesCollection() async {
    final context = await _storeContext();

    final storeReference = _firestore.collection('stores').doc(context.storeId);
    final storeSnapshot = await storeReference.get();
    if (!storeSnapshot.exists) {
      await storeReference.set(
        StoreModel(id: context.storeId).toMap(),
        SetOptions(merge: true),
      );
    }
    return storeReference.collection('machines');
  }

  Future<StoreContext> _storeContext() =>
      StoreContextResolver(firestore: _firestore, auth: _auth).resolve();

  void _validate(MachineItem machine) {
    if (machine.id.trim().isEmpty) {
      throw ArgumentError.value(
        machine.id,
        'machine.id',
        'Document ID cannot be empty.',
      );
    }
    if (machine.name.trim().isEmpty) {
      throw ArgumentError.value(
        machine.name,
        'machine.name',
        'Machine name cannot be empty.',
      );
    }
    if (machine.count < 0) {
      throw ArgumentError.value(
        machine.count,
        'machine.count',
        'Machine count cannot be negative.',
      );
    }
  }

  Map<String, dynamic> _toMap(MachineItem machine) => {
    'id': machine.id,
    'name': machine.name,
    'count': machine.count,
    'tier': machine.tier,
    'type': machine.type.name,
    'isAvailable': machine.isAvailable,
    'note': machine.note,
    'imageUrl': machine.imageUrl,
  };

  MachineItem _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final type = (data['type'] as String? ?? '').toLowerCase();
    return MachineItem(
      id: data['id'] as String? ?? document.id,
      name: data['name'] as String? ?? '',
      count: data['count'] is num ? (data['count'] as num).toInt() : 0,
      tier: data['tier'] as String? ?? 'STANDARD',
      type:
          type == MachineType.dryer.name
              ? MachineType.dryer
              : MachineType.washer,
      isAvailable: data['isAvailable'] as bool? ?? true,
      note: data['note'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
    );
  }
}
