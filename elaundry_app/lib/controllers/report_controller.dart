import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/report_model.dart';
import '../services/store_context.dart';

class ReportController {
  ReportController({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<CollectionReference<Map<String, dynamic>>> get _reports async =>
      _firestore
          .collection('stores')
          .doc(
            (await StoreContextResolver(
                  firestore: _firestore,
                  auth: _auth,
                ).resolve())
                .storeId,
          )
          .collection('reports');

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  Stream<ReportSummary> watchReport(String timeframe) async* {
    final storeId =
        (await StoreContextResolver(
              firestore: _firestore,
              auth: _auth,
            ).resolve())
            .storeId;
    yield* _orders.where('store_id', isEqualTo: storeId).snapshots().asyncMap((
      snapshot,
    ) async {
      final report = _calculate(timeframe, snapshot.docs);
      await (await _reports).doc(timeframe).set(report.toMap());
      return report;
    });
  }

  Future<ReportSummary> getReport(String timeframe) async {
    final storeId =
        (await StoreContextResolver(
              firestore: _firestore,
              auth: _auth,
            ).resolve())
            .storeId;
    final snapshot = await _orders.where('store_id', isEqualTo: storeId).get();
    final report = _calculate(timeframe, snapshot.docs);
    await (await _reports).doc(timeframe).set(report.toMap());
    return report;
  }

  ReportSummary _calculate(
    String timeframe,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    final now = DateTime.now();
    final start = _startOfTimeframe(timeframe, now);
    final paidOrders =
        documents.where((document) {
          final data = document.data();
          if (data['order_status'] != 'paid') return false;
          final date = _asDateTime(data['date_time']);
          return date != null && !date.isBefore(start) && !date.isAfter(now);
        }).toList();

    var grossSales = 0.0;
    var netSales = 0.0;
    var cashOrders = 0;
    var services = 0.0;
    var addons = 0.0;
    final employeeCounts = <String, int>{};

    for (final document in paidOrders) {
      final data = document.data();
      final summary = _map(data['order_summary']);
      grossSales += _asDouble(summary['subtotal']);
      netSales += _asDouble(summary['total_price']);
      final metadata = _map(data['discounts_applied']);
      final paymentMethod =
          (metadata['mode_of_payment'] ?? '').toString().toLowerCase();
      if (paymentMethod == 'cash') cashOrders++;

      final details = data['order_details'];
      if (details is List) {
        for (final detail in details.whereType<Map>()) {
          final isService = detail['is_service'] == true;
          final quantity = _asDouble(detail['qty'] ?? detail['quantity']);
          if (isService) {
            services += quantity;
          } else {
            addons += quantity;
          }
        }
      }

      final employee = (data['processed_by_name'] as String?)?.trim();
      if (employee != null && employee.isNotEmpty) {
        employeeCounts[employee] = (employeeCounts[employee] ?? 0) + 1;
      }
    }

    final totalOrders = paidOrders.length;
    final employeeStats =
        employeeCounts.entries
            .map(
              (entry) => ReportEmployeeStat(
                name: entry.key,
                percentage:
                    totalOrders == 0 ? 0 : entry.value * 100 / totalOrders,
              ),
            )
            .toList()
          ..sort((left, right) => right.percentage.compareTo(left.percentage));

    return ReportSummary(
      id: timeframe,
      timeframe: timeframe,
      generatedAt: now,
      totalOrders: totalOrders,
      netSales: netSales,
      grossSales: grossSales,
      cashPercentage: totalOrders == 0 ? 0 : cashOrders * 100 / totalOrders,
      servicesCount: services,
      addonsCount: addons,
      othersCount: 0,
      employeeStats: employeeStats,
    );
  }

  DateTime _startOfTimeframe(String timeframe, DateTime now) {
    switch (timeframe) {
      case 'today':
        return DateTime(now.year, now.month, now.day);
      case 'weekly':
        return DateTime(now.year, now.month, now.day - 6);
      case 'monthly':
        return DateTime(now.year, now.month, 1);
      default:
        throw ArgumentError.value(timeframe, 'timeframe');
    }
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
}
