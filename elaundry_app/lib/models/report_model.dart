class ReportSummary {
  final String id;
  final String timeframe;
  final DateTime generatedAt;
  final int totalOrders;
  final double netSales;
  final double grossSales;
  final double cashPercentage;
  final double servicesCount;
  final double addonsCount;
  final double othersCount;
  final List<ReportEmployeeStat> employeeStats;

  const ReportSummary({
    required this.id,
    required this.timeframe,
    required this.generatedAt,
    this.totalOrders = 0,
    this.netSales = 0,
    this.grossSales = 0,
    this.cashPercentage = 0,
    this.servicesCount = 0,
    this.addonsCount = 0,
    this.othersCount = 0,
    this.employeeStats = const [],
  });

  double get cashlessPercentage => 100 - cashPercentage;

  factory ReportSummary.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    final rawEmployees = map['employee_stats'];
    return ReportSummary(
      id: id,
      timeframe: map['timeframe'] as String? ?? id,
      generatedAt: _asDateTime(map['generated_at']) ?? DateTime.now(),
      totalOrders: _asInt(map['total_orders']),
      netSales: _asDouble(map['net_sales']),
      grossSales: _asDouble(map['gross_sales']),
      cashPercentage: _asDouble(map['cash_percentage']),
      servicesCount: _asDouble(map['services_count']),
      addonsCount: _asDouble(map['addons_count']),
      othersCount: _asDouble(map['others_count']),
      employeeStats:
          rawEmployees is List
              ? rawEmployees
                  .whereType<Map>()
                  .map(
                    (employee) => ReportEmployeeStat.fromMap(
                      Map<String, dynamic>.from(employee),
                    ),
                  )
                  .toList()
              : const [],
    );
  }

  Map<String, dynamic> toMap() => {
    'timeframe': timeframe,
    'generated_at': generatedAt,
    'total_orders': totalOrders,
    'net_sales': netSales,
    'gross_sales': grossSales,
    'cash_percentage': cashPercentage,
    'services_count': servicesCount,
    'addons_count': addonsCount,
    'others_count': othersCount,
    'employee_stats':
        employeeStats.map((employee) => employee.toMap()).toList(),
  };
}

class ReportEmployeeStat {
  final String name;
  final double percentage;

  const ReportEmployeeStat({required this.name, required this.percentage});

  factory ReportEmployeeStat.fromMap(Map<String, dynamic> map) =>
      ReportEmployeeStat(
        name: map['name'] as String? ?? 'Unknown',
        percentage: _asDouble(map['percentage']),
      );

  Map<String, dynamic> toMap() => {'name': name, 'percentage': percentage};
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
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
  return null;
}
