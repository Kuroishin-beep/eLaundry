import 'dart:async';

import 'package:flutter/material.dart';

import '../../controllers/order_controller.dart';
import '../../controllers/shift_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/themes/theme.dart';
import '../../models/order_models.dart';
import '../../models/shift_model.dart';
import '../../shared/empty_states.dart';
import '../../shared/laundry_navigation_fab.dart';
import '../../shared/search_filter_bar.dart';
import 'add_to_cart_screen.dart';
import 'order_details_screen.dart';
import '../shift/manage/open_shift_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderController _orderController = OrderController();
  final ShiftController _shiftController = ShiftController();
  final TransactionController _transactionController = TransactionController();
  final _searchController = TextEditingController();
  bool _isGridView = false;
  final List<LaundryOrder> _orders = [];
  StreamSubscription<List<LaundryOrder>>? _ordersSubscription;
  StreamSubscription<ShiftModel?>? _shiftSubscription;
  ShiftModel? _activeShift;
  Object? _shiftError;
  bool _isLoadingShift = true;
  Object? _ordersError;
  bool _isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    _ordersSubscription = _orderController.watchOrders().listen(
      (orders) {
        if (!mounted) return;
        setState(() {
          _orders
            ..clear()
            ..addAll(orders);
          _ordersError = null;
          _isLoadingOrders = false;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _ordersError = error;
          _isLoadingOrders = false;
        });
      },
    );
    _shiftSubscription = _shiftController.watchActiveShift().listen(
      (shift) {
        if (!mounted) return;
        setState(() {
          _activeShift = shift;
          _shiftError = null;
          _isLoadingShift = false;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _shiftError = error;
          _isLoadingShift = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    unawaited(_ordersSubscription?.cancel());
    unawaited(_shiftSubscription?.cancel());
    super.dispose();
  }

  Future<void> _openShift() async {
    try {
      final startingCash = await Navigator.of(context).push<double>(
        MaterialPageRoute(builder: (context) => const OpenShiftScreen()),
      );
      if (startingCash == null || !mounted) return;
      await _shiftController.openShift(startingCash);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 15),
          content: Text('Unable to open shift: $error'),
        ),
      );
    }
  }

  void _openAddOrder() async {
    try {
      await _shiftController.requireActiveShift();
      if (!mounted) return;
      final newOrder = await Navigator.of(context).push<LaundryOrder>(
        MaterialPageRoute(builder: (context) => const AddToCartScreen()),
      );
      if (newOrder != null) await _orderController.createOrder(newOrder);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 15),
            content: Text('Unable to create order: $error'),
          ),
        );
      }
    }
  }

  void _onOrderTap(LaundryOrder order) async {
    if (_activeShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 15),
          content: Text('Open a shift before processing an order.'),
        ),
      );
      return;
    }
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
    );

    try {
      if (result == 'paid') {
        await _transactionController.markOrderPaid(order);
      } else if (result == 'cancelled') {
        await _orderController.cancelOrder(order);
      } else if (result is LaundryOrder) {
        await _orderController.updateOrder(result);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 15),
            content: Text('Unable to update order: $error'),
          ),
        );
      }
    }
  }

  IconData _getOrderIcon(int index) {
    if (index % 3 == 0) return Icons.checkroom_rounded;
    if (index % 3 == 1) return Icons.dry_cleaning_rounded;
    return Icons.local_laundry_service_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered =
        _orders
            .where(
              (o) =>
                  !o.isPaid &&
                  o.orderStatus != 'cancelled' &&
                  (o.customerName.toLowerCase().contains(query) ||
                      o.id.toLowerCase().contains(query)),
            )
            .toList();

    return Scaffold(
      backgroundColor: AppColors.neutral[400],
      appBar: AppBar(
        title: Text(
          'Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary[900],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const LaundryNavigationFab(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CapsuleSearchFilterBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  onFilterTap: () {},
                  isGridView: _isGridView,
                  onToggleView:
                      () => setState(() => _isGridView = !_isGridView),
                  hintText: 'Search',
                ),
                const SizedBox(height: 14),
                if (_isLoadingOrders)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_isLoadingShift)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_ordersError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Unable to load orders: $_ordersError',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.secondary[600]),
                    ),
                  )
                else if (_shiftError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Unable to load shift: $_shiftError',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.secondary[600]),
                    ),
                  )
                else if (_activeShift == null)
                  SizedBox(
                    height: 360,
                    child: Center(
                      child: EmptyState(
                        icon: Icons.lock_clock_outlined,
                        title: 'No Active Shift',
                        description:
                            'Open a shift before creating or processing orders.',
                        actionLabel: 'Open Shift',
                        onAction: _openShift,
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  SizedBox(
                    height: 360,
                    child: Center(
                      child: EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Open Orders',
                        description:
                            'Create an order to start tracking customer laundry.',
                        actionLabel: 'Add Order',
                        onAction: _openAddOrder,
                      ),
                    ),
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B4F4E),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _openAddOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Add Order',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isGridView)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.15,
                          ),
                      itemBuilder: (context, index) {
                        final order = filtered[index];
                        return InkWell(
                          onTap: () => _onOrderTap(order),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.neutral[500]!,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        _getOrderIcon(index),
                                        color: AppColors.accent,
                                        size: 20,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      order.time,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.secondary[400],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.customerName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2C2D2D),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'P${order.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1F2221),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final order = filtered[index];
                        return InkWell(
                          onTap: () => _onOrderTap(order),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.neutral[500]!,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    _getOrderIcon(index),
                                    color: AppColors.accent,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.customerName,
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF2C2D2D),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        order.time,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.secondary[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'P${order.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF202221),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
