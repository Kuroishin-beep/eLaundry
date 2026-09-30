import 'order_models.dart';

class TransactionModel {
  final String id;
  final String customerName;
  final String contactNumber;
  final String dateTime;
  final String time;
  final List<BasketItem> baskets;
  final List<OrderLineItem> items;
  final double? subtotalAmount;
  final double discount;
  final double? totalAmount;
  final String paymentMethod;
  final String processedByName;
  final String processedByRole;

  const TransactionModel({
    required this.id,
    required this.customerName,
    required this.contactNumber,
    required this.dateTime,
    required this.time,
    required this.baskets,
    required this.items,
    this.subtotalAmount,
    this.discount = 0.0,
    this.totalAmount,
    required this.paymentMethod,
    required this.processedByName,
    required this.processedByRole,
  });

  double get subtotal =>
      subtotalAmount ?? items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get total =>
      totalAmount ?? (subtotal - discount).clamp(0.0, double.infinity);
}
