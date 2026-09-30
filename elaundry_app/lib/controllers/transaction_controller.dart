import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_models.dart';
import '../models/transaction_model.dart';
import 'shift_controller.dart';
import '../services/store_context.dart';

class TransactionController {
  TransactionController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ShiftController? shiftController,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _shiftController = shiftController ?? ShiftController();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ShiftController _shiftController;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  Stream<List<TransactionModel>> watchTransactions() async* {
    final storeId =
        (await StoreContextResolver(
              firestore: _firestore,
              auth: _auth,
            ).resolve())
            .storeId;
    yield* _orders
        .where('store_id', isEqualTo: storeId)
        .where('order_status', isEqualTo: 'paid')
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs.map(_fromOrderDocument).toList();
          transactions.sort((left, right) {
            final leftDate = DateTime.tryParse(left.dateTime);
            final rightDate = DateTime.tryParse(right.dateTime);
            if (leftDate == null || rightDate == null) return 0;
            return rightDate.compareTo(leftDate);
          });
          return transactions;
        });
  }

  Future<List<TransactionModel>> getTransactions() async {
    final storeId =
        (await StoreContextResolver(
              firestore: _firestore,
              auth: _auth,
            ).resolve())
            .storeId;
    final snapshot =
        await _orders
            .where('store_id', isEqualTo: storeId)
            .where('order_status', isEqualTo: 'paid')
            .get();
    return snapshot.docs.map(_fromOrderDocument).toList();
  }

  Future<void> markOrderPaid(LaundryOrder order) async {
    final activeShift = await _shiftController.requireActiveShift();
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('A signed-in user is required to process payment.');
    }

    final userDocument =
        await _firestore.collection('users').doc(user.uid).get();
    final profile = userDocument.data() ?? const <String, dynamic>{};
    final token = await user.getIdTokenResult();
    final claims = token.claims ?? const <String, dynamic>{};
    final processorName =
        _nonEmptyString(profile['fullName']) ??
        _nonEmptyString(user.displayName) ??
        _nonEmptyString(user.email) ??
        'Unknown user';
    final processorRole =
        _nonEmptyString(profile['role']) ??
        _nonEmptyString(claims['role']) ??
        'Staff';

    await _orders.doc(order.id).update({
      'order_status': 'paid',
      'shift_id': activeShift.id,
      'discounts_applied.mode_of_payment': order.paymentMethod.toLowerCase(),
      'processed_by_user_id': user.uid,
      'processed_by_name': processorName,
      'processed_by_role': processorRole,
      'processed_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markOrderUnpaid(String orderId) async {
    if (orderId.trim().isEmpty) {
      throw ArgumentError.value(orderId, 'orderId', 'Order ID is required.');
    }

    final activeShift = await _shiftController.requireActiveShift();
    await _orders.doc(orderId).update({
      'order_status': 'unpaid',
      'shift_id': activeShift.id,
      'processed_by_user_id': FieldValue.delete(),
      'processed_by_name': FieldValue.delete(),
      'processed_by_role': FieldValue.delete(),
      'processed_at': FieldValue.delete(),
    });
  }

  TransactionModel _fromOrderDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final order = LaundryOrder.fromMap(data, documentId: document.id);
    return TransactionModel(
      id: order.id,
      customerName: order.customerName,
      contactNumber: order.contactNumber,
      dateTime: order.dateTime,
      time: order.time,
      baskets: order.baskets,
      items: order.items,
      subtotalAmount: order.subtotal,
      discount: order.totalDiscount,
      totalAmount: order.total,
      paymentMethod: order.paymentMethod,
      processedByName:
          _nonEmptyString(data['processed_by_name']) ??
          _nonEmptyString(data['processed_by_user_id']) ??
          'Unknown',
      processedByRole: _nonEmptyString(data['processed_by_role']) ?? 'Staff',
    );
  }

  String? _nonEmptyString(dynamic value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }
}
