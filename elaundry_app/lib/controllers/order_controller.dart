import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/catalog_models.dart';
import '../models/order_models.dart';
import 'catalog_controller.dart';

class OrderController {
  OrderController({
    FirebaseFirestore? firestore,
    CatalogController? catalogController,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _catalogController = catalogController ?? CatalogController();

  final FirebaseFirestore _firestore;
  final CatalogController _catalogController;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> get _counters =>
      _firestore.collection('counters');

  Stream<List<LaundryOrder>> watchOrders() => _orders.snapshots().map((
    snapshot,
  ) {
    final orders =
        snapshot.docs
            .map(
              (document) => LaundryOrder.fromMap(
                document.data(),
                documentId: document.id,
              ),
            )
            .toList();
    _sortNewestFirst(orders);
    return orders;
  });

  Future<List<LaundryOrder>> getOrders() async {
    final snapshot = await _orders.get();
    final orders =
        snapshot.docs
            .map(
              (document) => LaundryOrder.fromMap(
                document.data(),
                documentId: document.id,
              ),
            )
            .toList();
    _sortNewestFirst(orders);
    return orders;
  }

  Future<List<OrderLineItem>> getOrderableItems() async {
    final catalogItems = await _catalogController.getItems();
    return catalogItems.map(_toOrderLineItem).toList();
  }

  Future<LaundryOrder> createOrder(LaundryOrder order) async {
    final createdAt = DateTime.now();
    final dateKey = _dateKey(createdAt);
    final counterReference = _counters.doc('orders-$dateKey');
    late LaundryOrder createdOrder;

    await _firestore.runTransaction((transaction) async {
      final counterSnapshot = await transaction.get(counterReference);
      final previousSequence = counterSnapshot.data()?['sequence'];
      final sequence =
          (previousSequence is num ? previousSequence.toInt() : 0) + 1;
      final orderId = 'EL-$dateKey-${sequence.toString().padLeft(4, '0')}';
      final subtotal = order.items.fold<double>(
        0,
        (runningTotal, item) => runningTotal + item.subtotal,
      );
      final summary = OrderSummary(
        subtotal: subtotal,
        totalDiscount: order.discount,
        totalPrice: (subtotal - order.discount).clamp(0.0, double.infinity),
      );
      final metadata = OrderMetadata(
        estimatedEta: createdAt.add(
          Duration(
            seconds: order.items.fold<int>(
              0,
              (runningTotal, item) =>
                  runningTotal +
                  (item.isService ? _durationSeconds(item.duration) : 0),
            ),
          ),
        ),
        fulfillmentStatus: 'pending',
        modeOfPayment: order.paymentMethod.toLowerCase(),
        orderId: orderId,
      );

      createdOrder = LaundryOrder(
        id: orderId,
        customerName: order.customerName,
        contactNumber: order.contactNumber,
        dateTime: _formatDateTime(createdAt),
        dateTimeValue: createdAt,
        time: _formatTime(createdAt),
        baskets: _basketsWithAddOns(order),
        items: order.items,
        discount: order.discount,
        paymentMethod: order.paymentMethod,
        isPaid: false,
        orderStatus: 'unpaid',
        qrReferenceId:
            order.qrReferenceId.isNotEmpty
                ? order.qrReferenceId
                : 'ELQR-${createdAt.millisecondsSinceEpoch}',
        discountsApplied: metadata,
        orderSummary: summary,
      );

      transaction.set(counterReference, {'sequence': sequence});
      transaction.set(_orders.doc(orderId), createdOrder.toMap());
    });

    return createdOrder;
  }

  Future<void> updateOrder(LaundryOrder order) async {
    if (order.id.trim().isEmpty) {
      throw ArgumentError.value(order.id, 'order.id', 'Order ID is required.');
    }
    final orderWithBasketAddOns = order.copyWith(
      baskets: _basketsWithAddOns(order),
    );
    await _orders
        .doc(order.id)
        .set(orderWithBasketAddOns.toMap(), SetOptions(merge: true));
  }

  Future<void> markOrderPaid(LaundryOrder order) =>
      updateOrder(order.copyWith(isPaid: true));

  Future<void> cancelOrder(LaundryOrder order) =>
      updateOrder(order.copyWith(orderStatus: 'cancelled'));

  List<BasketItem> _basketsWithAddOns(LaundryOrder order) {
    if (order.baskets.isEmpty) return order.baskets;

    final addOns =
        order.items
            .where((item) => !item.isService && item.quantity > 0)
            .map(
              (item) => BasketAddon(
                name: item.name,
                quantity: item.quantity,
                unitPrice: item.price,
              ),
            )
            .toList();

    final firstBasket = order.baskets.first;
    final firstBasketWithAddOns = BasketItem(
      number: firstBasket.number,
      kg: firstBasket.kg,
      serviceType: firstBasket.serviceType,
      tier: firstBasket.tier,
      washerMachine: firstBasket.washerMachine,
      dryerMachine: firstBasket.dryerMachine,
      addOns: addOns,
    );
    return [firstBasketWithAddOns, ...order.baskets.skip(1)];
  }

  void _sortNewestFirst(List<LaundryOrder> orders) {
    orders.sort((left, right) {
      final leftDate = left.dateTimeValue;
      final rightDate = right.dateTimeValue;
      if (leftDate == null || rightDate == null) return 0;
      return rightDate.compareTo(leftDate);
    });
  }

  OrderLineItem _toOrderLineItem(CatalogItem item) {
    final isService = item.category.trim().toLowerCase() != 'add-on';
    return OrderLineItem(
      id: item.id,
      name: item.name,
      tier: item.machineType,
      duration: isService ? item.durationLabel : '',
      price: item.price,
      quantity: 0,
      isService: isService,
    );
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';

  int _durationSeconds(String value) {
    final clock = RegExp(r'^(\d+):(\d{1,2}):(\d{1,2})$').firstMatch(value);
    if (clock != null) {
      return int.parse(clock.group(1)!) * 3600 +
          int.parse(clock.group(2)!) * 60 +
          int.parse(clock.group(3)!);
    }
    final minutes = RegExp(
      r'(\d+)\s*(?:mins?|minutes)',
      caseSensitive: false,
    ).firstMatch(value);
    return minutes == null ? 0 : int.parse(minutes.group(1)!) * 60;
  }

  String _formatDateTime(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
  }
}
