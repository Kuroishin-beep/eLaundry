class BasketItem {
  final int number;
  final double weight;

  const BasketItem({required this.number, required this.weight});
}

class OrderLineItem {
  final String id;
  final String name;
  final String tier; // 'STANDARD' or 'PLUS+'
  final String duration; // e.g. '38 mins' or empty for addons
  final double price;
  final int quantity;
  final bool isService;

  const OrderLineItem({
    required this.id,
    required this.name,
    required this.tier,
    this.duration = '',
    required this.price,
    this.quantity = 0,
    required this.isService,
  });

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

class LaundryOrder {
  final String id;
  final String customerName;
  final String contactNumber;
  final String dateTime;
  final String time;
  final List<BasketItem> baskets;
  final List<OrderLineItem> items;
  final double discount;
  final String paymentMethod; // 'CASH' or 'CASHLESS'
  final bool isPaid;

  const LaundryOrder({
    required this.id,
    required this.customerName,
    required this.contactNumber,
    required this.dateTime,
    required this.time,
    required this.baskets,
    required this.items,
    this.discount = 100.0,
    this.paymentMethod = 'CASH',
    this.isPaid = false,
  });

  double get subtotal =>
      items.fold(0.0, (sum, i) => sum + (i.price * i.quantity));
  double get total => (subtotal - discount).clamp(0.0, double.infinity);

  LaundryOrder copyWith({
    List<BasketItem>? baskets,
    List<OrderLineItem>? items,
    String? paymentMethod,
    bool? isPaid,
  }) {
    return LaundryOrder(
      id: id,
      customerName: customerName,
      contactNumber: contactNumber,
      dateTime: dateTime,
      time: time,
      baskets: baskets ?? this.baskets,
      items: items ?? this.items,
      discount: discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
