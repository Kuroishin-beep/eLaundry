class ShiftModel {
  final String id;
  final String dateTime;
  final String time;
  final DateTime? openedAt;
  final double startingCash;
  final double cashPayments;
  final double cashlessPayments;
  final double grossSales;
  final double netSales;
  final int pendingOrders;
  final double totalRefund;
  final bool isClosed;
  final String? closedAt;
  final String openedByUserId;

  const ShiftModel({
    required this.id,
    required this.dateTime,
    required this.time,
    this.openedAt,
    required this.startingCash,
    this.cashPayments = 0,
    this.cashlessPayments = 0,
    this.grossSales = 0,
    this.netSales = 0,
    this.pendingOrders = 0,
    this.totalRefund = 0,
    this.isClosed = false,
    this.closedAt,
    this.openedByUserId = '',
  });

  factory ShiftModel.fromMap(Map<String, dynamic> map, {required String id}) {
    final rawOpenedAt = map['opened_at'];
    final openedAt = _dateTimeFromValue(rawOpenedAt);
    final dateTime = map['date_time'] as String? ?? '';
    return ShiftModel(
      id: id,
      dateTime:
          dateTime.isNotEmpty ? dateTime : openedAt?.toLocal().toString() ?? '',
      time: map['time'] as String? ?? _timeFromDate(openedAt),
      openedAt: openedAt,
      startingCash: _asDouble(map['starting_cash']),
      cashPayments: _asDouble(map['cash_payments']),
      cashlessPayments: _asDouble(map['cashless_payments']),
      grossSales: _asDouble(map['gross_sales']),
      netSales: _asDouble(map['net_sales']),
      pendingOrders: _asInt(map['pending_orders']),
      totalRefund: _asDouble(map['total_refund']),
      isClosed: map['is_closed'] as bool? ?? false,
      closedAt: _closedAtString(map['closed_at']),
      openedByUserId: map['opened_by_user_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'date_time': dateTime,
    'time': time,
    'opened_at': openedAt,
    'starting_cash': startingCash,
    'cash_payments': cashPayments,
    'cashless_payments': cashlessPayments,
    'gross_sales': grossSales,
    'net_sales': netSales,
    'pending_orders': pendingOrders,
    'total_refund': totalRefund,
    'is_closed': isClosed,
    'closed_at': closedAt,
    'opened_by_user_id': openedByUserId,
  };

  ShiftModel copyWith({
    String? id,
    String? dateTime,
    String? time,
    DateTime? openedAt,
    double? startingCash,
    double? cashPayments,
    double? cashlessPayments,
    double? grossSales,
    double? netSales,
    int? pendingOrders,
    double? totalRefund,
    bool? isClosed,
    String? closedAt,
    String? openedByUserId,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      time: time ?? this.time,
      openedAt: openedAt ?? this.openedAt,
      startingCash: startingCash ?? this.startingCash,
      cashPayments: cashPayments ?? this.cashPayments,
      cashlessPayments: cashlessPayments ?? this.cashlessPayments,
      grossSales: grossSales ?? this.grossSales,
      netSales: netSales ?? this.netSales,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      totalRefund: totalRefund ?? this.totalRefund,
      isClosed: isClosed ?? this.isClosed,
      closedAt: closedAt ?? this.closedAt,
      openedByUserId: openedByUserId ?? this.openedByUserId,
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

DateTime? _dateTimeFromValue(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value != null) {
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
  return null;
}

String? _closedAtString(dynamic value) {
  if (value is String) return value;
  final dateTime = _dateTimeFromValue(value);
  if (dateTime == null) return null;
  final hour =
      dateTime.toLocal().hour % 12 == 0 ? 12 : dateTime.toLocal().hour % 12;
  final minute = dateTime.toLocal().minute.toString().padLeft(2, '0');
  return '$hour:$minute ${dateTime.toLocal().hour >= 12 ? 'PM' : 'AM'}';
}

String _timeFromDate(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
}
