import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../models/order_models.dart';
import '../../shared/laundry_navigation_fab.dart';
import '../../shared/search_filter_bar.dart';
import 'add_to_cart_screen.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = false;

  final List<LaundryOrder> _orders = [
    LaundryOrder(
      id: '#123456',
      customerName: 'Juan Dela Cruz',
      contactNumber: '0967 676 7676',
      dateTime: 'August 21, 2026 • 10:00 AM',
      time: '10:00 AM',
      baskets: const [
        BasketItem(number: 1, weight: 6),
        BasketItem(number: 2, weight: 7),
      ],
      items: const [
        OrderLineItem(
          id: '1',
          name: 'Regular Wash',
          tier: 'STANDARD',
          duration: '38 mins',
          price: 80,
          quantity: 2,
          isService: true,
        ),
        OrderLineItem(
          id: '2',
          name: 'Regular Dry',
          tier: 'STANDARD',
          duration: '40 mins',
          price: 80,
          quantity: 2,
          isService: true,
        ),
        OrderLineItem(
          id: '3',
          name: 'Fabric Softener',
          tier: 'STANDARD',
          price: 10,
          quantity: 1,
          isService: false,
        ),
        OrderLineItem(
          id: '4',
          name: 'Plastic Bag',
          tier: 'STANDARD',
          price: 5,
          quantity: 4,
          isService: false,
        ),
      ],
    ),
    const LaundryOrder(
      id: '#123457',
      customerName: 'Kyle Mariano',
      contactNumber: '0912 345 6789',
      dateTime: 'August 21, 2026 • 09:48 AM',
      time: '09:48 AM',
      baskets: [BasketItem(number: 1, weight: 5)],
      items: [
        OrderLineItem(
          id: '1',
          name: 'Regular Wash',
          tier: 'STANDARD',
          duration: '38 mins',
          price: 80,
          quantity: 2,
          isService: true,
        ),
      ],
      discount: 0,
    ),
    const LaundryOrder(
      id: '#123458',
      customerName: 'Sean Almendral',
      contactNumber: '0922 456 7890',
      dateTime: 'August 21, 2026 • 09:25 AM',
      time: '09:25 AM',
      baskets: [BasketItem(number: 1, weight: 5)],
      items: [
        OrderLineItem(
          id: '1',
          name: 'Regular Wash',
          tier: 'STANDARD',
          duration: '38 mins',
          price: 80,
          quantity: 1,
          isService: true,
        ),
      ],
      discount: 0,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddOrder() async {
    final newOrder = await Navigator.of(context).push<LaundryOrder>(
      MaterialPageRoute(builder: (context) => const AddToCartScreen()),
    );

    if (newOrder != null) {
      setState(() => _orders.insert(0, newOrder));
    }
  }

  void _onOrderTap(LaundryOrder order) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
    );

    if (result is String && result == 'paid') {
      setState(() => _orders.removeWhere((o) => o.id == order.id));
    } else if (result is LaundryOrder) {
      final idx = _orders.indexWhere((o) => o.id == result.id);
      if (idx != -1) setState(() => _orders[idx] = result);
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
                  o.customerName.toLowerCase().contains(query) ||
                  o.id.toLowerCase().contains(query),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
          ),
        ),
      ),
    );
  }
}
