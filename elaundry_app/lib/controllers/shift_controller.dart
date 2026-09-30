import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/shift_model.dart';
import '../services/store_context.dart';

class ShiftController {
  ShiftController({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('A signed-in user is required to manage shifts.');
    }
    return user.uid;
  }

  Future<CollectionReference<Map<String, dynamic>>> get _shifts async =>
      _firestore
          .collection('stores')
          .doc(await _storeId())
          .collection('shifts');

  Future<String> _storeId() async =>
      (await StoreContextResolver(firestore: _firestore, auth: _auth).resolve())
          .storeId;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> get _counters =>
      _firestore.collection('counters');

  Stream<List<ShiftModel>> watchShifts() async* {
    final shifts = await _shifts;
    yield* shifts
        .where('opened_by_user_id', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
          final result =
              snapshot.docs
                  .map(
                    (document) =>
                        ShiftModel.fromMap(document.data(), id: document.id),
                  )
                  .toList()
                ..sort((left, right) {
                  final leftDate = left.openedAt;
                  final rightDate = right.openedAt;
                  if (leftDate == null || rightDate == null) return 0;
                  return rightDate.compareTo(leftDate);
                });
          return result;
        });
  }

  Stream<ShiftModel?> watchActiveShift() async* {
    final shifts = await _shifts;
    yield* shifts
        .where('opened_by_user_id', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
          final activeDocuments = snapshot.docs.where(
            (document) => document.data()['is_closed'] != true,
          );
          if (activeDocuments.isEmpty) return null;
          final document = activeDocuments.first;
          return ShiftModel.fromMap(document.data(), id: document.id);
        });
  }

  Future<ShiftModel?> getActiveShift() async {
    final shifts = await _shifts;
    final snapshot =
        await shifts.where('opened_by_user_id', isEqualTo: _userId).get();
    final activeDocuments = snapshot.docs.where(
      (document) => document.data()['is_closed'] != true,
    );
    if (activeDocuments.isEmpty) return null;
    final document = activeDocuments.first;
    return ShiftModel.fromMap(document.data(), id: document.id);
  }

  Future<ShiftModel> requireActiveShift() async {
    final shift = await getActiveShift();
    if (shift == null) {
      throw StateError('Open a shift before creating or processing orders.');
    }
    return shift;
  }

  Future<ShiftModel> openShift(double startingCash) async {
    if (startingCash < 0) {
      throw ArgumentError.value(
        startingCash,
        'startingCash',
        'Starting cash cannot be negative.',
      );
    }

    final userId = _userId;
    final shifts = await _shifts;
    final activeShift =
        await shifts.where('opened_by_user_id', isEqualTo: userId).get();
    if (activeShift.docs.any(
      (document) => document.data()['is_closed'] != true,
    )) {
      throw StateError('A shift is already open for this user.');
    }

    final openedAt = DateTime.now();
    final dateKey = _dateKey(openedAt);
    final counterReference = _counters.doc('shifts-$dateKey');
    late ShiftModel shift;
    await _firestore.runTransaction((transaction) async {
      final counterSnapshot = await transaction.get(counterReference);
      final previousSequence = counterSnapshot.data()?['sequence'];
      final sequence =
          (previousSequence is num ? previousSequence.toInt() : 0) + 1;
      final shiftId = 'SH-$dateKey-${sequence.toString().padLeft(4, '0')}';
      final reference = shifts.doc(shiftId);
      shift = ShiftModel(
        id: shiftId,
        dateTime: openedAt.toLocal().toString(),
        time: _formatTime(openedAt),
        openedAt: openedAt,
        startingCash: startingCash,
        openedByUserId: userId,
      );
      transaction.set(counterReference, {'sequence': sequence});
      transaction.set(reference, shift.toMap());
    });
    return shift;
  }

  Stream<ShiftModel> watchShiftSales(ShiftModel shift) async* {
    final storeId = await _storeId();
    yield* _orders
        .where('store_id', isEqualTo: storeId)
        .where('shift_id', isEqualTo: shift.id)
        .snapshots()
        .map(
          (snapshot) => _withPaidOrderTotals(
            shift,
            snapshot.docs
                .where((document) => document.data()['order_status'] == 'paid')
                .toList(),
          ),
        );
  }

  Future<ShiftModel> closeShift(ShiftModel shift) async {
    final userId = _userId;
    final shifts = await _shifts;
    if (shift.openedByUserId != userId) {
      throw StateError('Only the user who opened this shift can close it.');
    }

    final shiftOrders =
        await _orders
            .where('store_id', isEqualTo: await _storeId())
            .where('shift_id', isEqualTo: shift.id)
            .get();
    final paidOrders =
        shiftOrders.docs
            .where((document) => document.data()['order_status'] == 'paid')
            .toList();
    final unpaidOrderCount =
        shiftOrders.docs
            .where((document) => document.data()['order_status'] == 'unpaid')
            .length;
    final calculated = _withPaidOrderTotals(shift, paidOrders).copyWith(
      isClosed: true,
      closedAt: _formatTime(DateTime.now()),
      pendingOrders: unpaidOrderCount,
    );
    await shifts.doc(shift.id).update({
      'is_closed': true,
      'closed_at': FieldValue.serverTimestamp(),
      'cash_payments': calculated.cashPayments,
      'cashless_payments': calculated.cashlessPayments,
      'gross_sales': calculated.grossSales,
      'net_sales': calculated.netSales,
      'pending_orders': calculated.pendingOrders,
      'total_refund': calculated.totalRefund,
    });
    return calculated;
  }

  ShiftModel _withPaidOrderTotals(
    ShiftModel shift,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
  ) {
    var cash = 0.0;
    var cashless = 0.0;
    var gross = 0.0;
    var net = 0.0;
    for (final order in orders) {
      final data = order.data();
      final summary = _map(data['order_summary']);
      final paymentMetadata = _map(data['discounts_applied']);
      final paymentMethod =
          (paymentMetadata['mode_of_payment'] ?? data['payment_method'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
      final subtotal = _asDouble(summary['subtotal']);
      final total = _asDouble(summary['total_price']);
      gross += subtotal;
      net += total;
      if (paymentMethod == 'cash') {
        cash += total;
      } else {
        cashless += total;
      }
    }
    return shift.copyWith(
      cashPayments: cash,
      cashlessPayments: cashless,
      grossSales: gross,
      netSales: net,
      totalRefund: 0,
    );
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';
}
