class ShiftModel {
  final String id;
  final String dateTime;
  final String time;
  final double startingCash;
  final double cashPayments;
  final double cashlessPayments;
  final double grossSales;
  final double netSales;
  final int pendingOrders;
  final double totalRefund;
  final bool isClosed;
  final String? closedAt;

  const ShiftModel({
    required this.id,
    required this.dateTime,
    required this.time,
    required this.startingCash,
    this.cashPayments = 3250.00,
    this.cashlessPayments = 2100.00,
    this.grossSales = 6350.00,
    this.netSales = 5500.00,
    this.pendingOrders = 15,
    this.totalRefund = 500.00,
    this.isClosed = false,
    this.closedAt,
  });

  ShiftModel copyWith({
    String? id,
    String? dateTime,
    String? time,
    double? startingCash,
    double? cashPayments,
    double? cashlessPayments,
    double? grossSales,
    double? netSales,
    int? pendingOrders,
    double? totalRefund,
    bool? isClosed,
    String? closedAt,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      time: time ?? this.time,
      startingCash: startingCash ?? this.startingCash,
      cashPayments: cashPayments ?? this.cashPayments,
      cashlessPayments: cashlessPayments ?? this.cashlessPayments,
      grossSales: grossSales ?? this.grossSales,
      netSales: netSales ?? this.netSales,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      totalRefund: totalRefund ?? this.totalRefund,
      isClosed: isClosed ?? this.isClosed,
      closedAt: closedAt ?? this.closedAt,
    );
  }
}
