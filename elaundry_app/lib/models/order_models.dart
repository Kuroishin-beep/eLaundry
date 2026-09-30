class BasketAddon {
  final String name;
  final int quantity;
  final double unitPrice;

  const BasketAddon({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  factory BasketAddon.fromMap(Map<String, dynamic> map) => BasketAddon(
    name: map['name'] as String? ?? '',
    quantity: _asInt(map['qty']),
    unitPrice: _asDouble(map['unitPrice']),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'qty': quantity,
    'unitPrice': unitPrice,
  };
}

class BasketItem {
  // Number is a UI-only basket position; Firestore stores each basket's data.
  final int number;
  final double kg;
  final String serviceType;
  final String tier;
  final String? washerMachine;
  final String? dryerMachine;
  final List<BasketAddon> addOns;

  const BasketItem({
    this.number = 0,
    double? weight,
    double? kg,
    this.serviceType = 'washAndDry',
    this.tier = 'regular',
    this.washerMachine,
    this.dryerMachine,
    this.addOns = const [],
  }) : kg = kg ?? weight ?? 0;

  double get weight => kg;

  factory BasketItem.fromMap(Map<String, dynamic> map, {int number = 0}) {
    final rawAddOns = map['addOns'];
    return BasketItem(
      number: number,
      kg: _asDouble(map['kg'] ?? map['weight']),
      serviceType: map['serviceType'] as String? ?? '',
      tier: map['tier'] as String? ?? '',
      washerMachine: map['washerMachine'] as String?,
      dryerMachine: map['dryerMachine'] as String?,
      addOns:
          rawAddOns is List
              ? rawAddOns
                  .whereType<Map>()
                  .map(
                    (addOn) =>
                        BasketAddon.fromMap(Map<String, dynamic>.from(addOn)),
                  )
                  .toList()
              : const [],
    );
  }

  Map<String, dynamic> toMap() => {
    'kg': kg,
    'serviceType': serviceType,
    'tier': tier,
    'washerMachine': washerMachine,
    'dryerMachine': dryerMachine,
    'addOns': addOns.map((addOn) => addOn.toMap()).toList(),
  };
}

class OrderLineItem {
  final String id;
  final String name;
  final String tier;
  final String duration;
  final double price;
  final int quantity;
  final bool isService;
  final double subtotal;

  const OrderLineItem({
    required this.id,
    required this.name,
    required this.tier,
    this.duration = '',
    required this.price,
    this.quantity = 0,
    this.isService = false,
    double? subtotal,
  }) : subtotal = subtotal ?? price * quantity;

  factory OrderLineItem.fromMap(
    Map<String, dynamic> map, {
    String? id,
    bool defaultIsService = false,
  }) {
    final quantity = _asInt(map['qty'] ?? map['quantity']);
    final subtotal = _asDouble(map['subtotal']);
    return OrderLineItem(
      id: id ?? map['id'] as String? ?? map['item_name'] as String? ?? '',
      name: map['item_name'] as String? ?? map['name'] as String? ?? '',
      tier: map['tier'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      price: quantity == 0 ? subtotal : subtotal / quantity,
      quantity: quantity,
      isService: map['is_service'] as bool? ?? defaultIsService,
      subtotal: subtotal,
    );
  }

  Map<String, dynamic> toMap() => {
    'item_name': name,
    'qty': quantity,
    'subtotal': subtotal,
    'tier': tier,
    'duration': duration,
    'is_service': isService,
  };

  OrderLineItem copyWith({int? quantity}) {
    return OrderLineItem(
      id: id,
      name: name,
      tier: tier,
      duration: duration,
      price: price,
      quantity: quantity ?? this.quantity,
      isService: isService,
    );
  }
}

class OrderSummary {
  final double subtotal;
  final double totalDiscount;
  final double totalPrice;

  const OrderSummary({
    required this.subtotal,
    required this.totalDiscount,
    required this.totalPrice,
  });

  factory OrderSummary.fromMap(Map<String, dynamic> map) => OrderSummary(
    subtotal: _asDouble(map['subtotal']),
    totalDiscount: _asDouble(map['total_discount']),
    totalPrice: _asDouble(map['total_price']),
  );

  Map<String, dynamic> toMap() => {
    'subtotal': subtotal,
    'total_discount': totalDiscount,
    'total_price': totalPrice,
  };
}

class OrderMetadata {
  final DateTime? estimatedEta;
  final String fulfillmentStatus;
  final String modeOfPayment;
  final String orderId;

  const OrderMetadata({
    this.estimatedEta,
    this.fulfillmentStatus = 'pending',
    this.modeOfPayment = 'cash',
    required this.orderId,
  });

  factory OrderMetadata.fromMap(Map<String, dynamic> map) => OrderMetadata(
    estimatedEta: _asDateTime(map['estimated_eta']),
    fulfillmentStatus: map['fulfillment_status'] as String? ?? 'pending',
    modeOfPayment: map['mode_of_payment'] as String? ?? 'cash',
    orderId: map['order_ID'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'estimated_eta': estimatedEta,
    'fulfillment_status': fulfillmentStatus,
    'mode_of_payment': modeOfPayment,
    'order_ID': orderId,
  };
}

class LaundryOrder {
  final String id;
  final String customerName;
  final String contactNumber;
  final String dateTime;
  final DateTime? dateTimeValue;
  final String time;
  final List<BasketItem> baskets;
  final List<OrderLineItem> items;
  final double discount;
  final String paymentMethod;
  final bool isPaid;
  final String orderStatus;
  final String qrReferenceId;
  final String shiftId;
  final OrderMetadata? discountsApplied;
  final OrderSummary? orderSummary;

  const LaundryOrder({
    required this.id,
    required this.customerName,
    required this.contactNumber,
    required this.dateTime,
    this.dateTimeValue,
    required this.time,
    required this.baskets,
    required this.items,
    this.discount = 0.0,
    this.paymentMethod = 'CASH',
    this.isPaid = false,
    this.orderStatus = 'unpaid',
    this.qrReferenceId = '',
    this.shiftId = '',
    this.discountsApplied,
    this.orderSummary,
  });

  double get subtotal =>
      orderSummary?.subtotal ??
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get totalDiscount => orderSummary?.totalDiscount ?? discount;

  double get total =>
      orderSummary?.totalPrice ??
      (subtotal - totalDiscount).clamp(0.0, double.infinity);

  factory LaundryOrder.fromMap(Map<String, dynamic> map, {String? documentId}) {
    final rawMetadata = map['discounts_applied'];
    final metadata =
        rawMetadata is Map
            ? OrderMetadata.fromMap(Map<String, dynamic>.from(rawMetadata))
            : null;
    final rawSummary = map['order_summary'];
    final summary =
        rawSummary is Map
            ? OrderSummary.fromMap(Map<String, dynamic>.from(rawSummary))
            : null;
    final rawBaskets = map['baskets'];
    final rawDetails = map['order_details'];
    final baskets =
        rawBaskets is List
            ? rawBaskets.indexed
                .where((entry) => entry.$2 is Map)
                .map(
                  (entry) => BasketItem.fromMap(
                    Map<String, dynamic>.from(entry.$2 as Map),
                    number: entry.$1 + 1,
                  ),
                )
                .toList()
            : const <BasketItem>[];
    final addOnNames =
        baskets
            .expand((basket) => basket.addOns)
            .map((addOn) => addOn.name.trim().toLowerCase())
            .toSet();
    final rawDateTime = map['date_time'];
    final dateTimeValue = _asDateTime(rawDateTime);
    final dateTime =
        rawDateTime is String
            ? rawDateTime
            : dateTimeValue?.toLocal().toString() ?? '';
    final status = map['order_status'] as String? ?? 'unpaid';

    return LaundryOrder(
      id:
          metadata?.orderId.isNotEmpty == true
              ? metadata!.orderId
              : map['order_ID'] as String? ?? documentId ?? '',
      customerName: map['customer_name'] as String? ?? '',
      contactNumber: map['contact_no'] as String? ?? '',
      dateTime: dateTime,
      dateTimeValue: dateTimeValue,
      time: map['time'] as String? ?? _timeFromDate(dateTimeValue),
      baskets: baskets,
      items:
          rawDetails is List
              ? rawDetails.indexed
                  .where((entry) => entry.$2 is Map)
                  .map(
                    (entry) => OrderLineItem.fromMap(
                      Map<String, dynamic>.from(entry.$2 as Map),
                      id: '${entry.$1}',
                      defaultIsService:
                          !addOnNames.contains(
                            ((entry.$2 as Map)['item_name'] ?? '')
                                .toString()
                                .trim()
                                .toLowerCase(),
                          ),
                    ),
                  )
                  .toList()
              : const [],
      discount: summary?.totalDiscount ?? 0,
      paymentMethod: (metadata?.modeOfPayment ?? 'cash').toUpperCase(),
      isPaid: status.toLowerCase() == 'paid',
      orderStatus: status,
      qrReferenceId: map['qr_reference_id'] as String? ?? '',
      shiftId: map['shift_id'] as String? ?? '',
      discountsApplied: metadata,
      orderSummary: summary,
    );
  }

  Map<String, dynamic> toMap() {
    final summary =
        orderSummary ??
        OrderSummary(
          subtotal: subtotal,
          totalDiscount: discount,
          totalPrice: total,
        );
    final metadata =
        discountsApplied ??
        OrderMetadata(orderId: id, modeOfPayment: paymentMethod.toLowerCase());

    return {
      'baskets': baskets.map((basket) => basket.toMap()).toList(),
      'customer_name': customerName,
      'contact_no': contactNumber,
      'date_time': dateTimeValue ?? dateTime,
      'discounts_applied': metadata.toMap(),
      'order_details': items.map((item) => item.toMap()).toList(),
      'order_status': isPaid ? 'paid' : orderStatus,
      'order_summary': summary.toMap(),
      'qr_reference_id': qrReferenceId,
      if (shiftId.isNotEmpty) 'shift_id': shiftId,
    };
  }

  LaundryOrder copyWith({
    String? id,
    List<BasketItem>? baskets,
    List<OrderLineItem>? items,
    String? paymentMethod,
    bool? isPaid,
    String? orderStatus,
    String? shiftId,
  }) {
    return LaundryOrder(
      id: id ?? this.id,
      customerName: customerName,
      contactNumber: contactNumber,
      dateTime: dateTime,
      dateTimeValue: dateTimeValue,
      time: time,
      baskets: baskets ?? this.baskets,
      items: items ?? this.items,
      discount: discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      orderStatus: orderStatus ?? (isPaid == true ? 'paid' : this.orderStatus),
      qrReferenceId: qrReferenceId,
      shiftId: shiftId ?? this.shiftId,
      discountsApplied: discountsApplied,
      orderSummary: orderSummary,
    );
  }
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime? _asDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value != null) {
    try {
      final converted = (value as dynamic).toDate();
      if (converted is DateTime) return converted;
    } catch (_) {
      return null;
    }
  }
  return null;
}

String _timeFromDate(DateTime? dateTime) {
  if (dateTime == null) return '';
  final local = dateTime.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
