import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../models/order_models.dart';
import '../../models/transaction_model.dart';
import '../../shared/laundry_navigation_fab.dart';
import '../../shared/search_filter_bar.dart';
import 'transaction_details_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = false;

  final List<TransactionModel> _transactions = [
    const TransactionModel(
      id: '#123456',
      customerName: 'Juan Dela Cruz',
      contactNumber: '0967 676 7676',
      dateTime: 'August 21, 2026 • 10:00 AM',
      time: '10:00 AM',
      baskets: [
        BasketItem(number: 1, weight: 6),
        BasketItem(number: 2, weight: 7),
      ],
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
      discount: 0,
      paymentMethod: 'CASH',
      processedByName: 'John Doe',
      processedByRole: 'Cashier',
    ),
    const TransactionModel(
      id: '#123457',
      customerName: 'Juan Dela Cruz',
      contactNumber: '0967 676 7676',
      dateTime: 'August 21, 2026 • 10:00 AM',
      time: '10:00 AM',
      baskets: [BasketItem(number: 1, weight: 8)],
      items: [
        OrderLineItem(
          id: '1',
          name: 'Regular Wash',
          tier: 'STANDARD',
          price: 80,
          quantity: 2,
          isService: true,
        ),
      ],
      discount: 0,
      paymentMethod: 'CASH',
      processedByName: 'Maria Santos',
      processedByRole: 'Cashier',
    ),
    const TransactionModel(
      id: '#123458',
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
          price: 80,
          quantity: 2,
          isService: true,
        ),
      ],
      discount: 0,
      paymentMethod: 'CASHLESS',
      processedByName: 'John Doe',
      processedByRole: 'Cashier',
    ),
    const TransactionModel(
      id: '#123459',
      customerName: 'Sean Almendral',
      contactNumber: '0922 456 7890',
      dateTime: 'August 21, 2026 • 09:25 AM',
      time: '09:25 AM',
      baskets: [BasketItem(number: 1, weight: 4)],
      items: [
        OrderLineItem(
          id: '1',
          name: 'Regular Wash',
          tier: 'STANDARD',
          price: 80,
          quantity: 1,
          isService: true,
        ),
      ],
      discount: 0,
      paymentMethod: 'CASH',
      processedByName: 'John Doe',
      processedByRole: 'Cashier',
    ),
    const TransactionModel(
      id: '#123460',
      customerName: 'Joshua Perez',
      contactNumber: '0933 654 3210',
      dateTime: 'August 21, 2026 • 08:52 AM',
      time: '08:52 AM',
      baskets: [BasketItem(number: 1, weight: 14)],
      items: [
        OrderLineItem(
          id: '1',
          name: 'Premium Full Service',
          tier: 'PLUS+',
          price: 350,
          quantity: 2,
          isService: true,
        ),
      ],
      discount: 0,
      paymentMethod: 'CASHLESS',
      processedByName: 'Maria Santos',
      processedByRole: 'Cashier',
    ),
    const TransactionModel(
      id: '#123461',
      customerName: 'Eya Yalung',
      contactNumber: '0944 876 5432',
      dateTime: 'August 21, 2026 • 09:25 AM',
      time: '09:25 AM',
      baskets: [BasketItem(number: 1, weight: 5)],
      items: [
        OrderLineItem(
          id: '1',
          name: 'Regular Wash',
          tier: 'STANDARD',
          price: 80,
          quantity: 1,
          isService: true,
        ),
      ],
      discount: 0,
      paymentMethod: 'CASH',
      processedByName: 'John Doe',
      processedByRole: 'Cashier',
    ),
    const TransactionModel(
      id: '#123462',
      customerName: 'Angelica Tadique',
      contactNumber: '0955 123 7890',
      dateTime: 'August 21, 2026 • 09:48 AM',
      time: '09:48 AM',
      baskets: [BasketItem(number: 1, weight: 6)],
      items: [
        OrderLineItem(
          id: '1',
          name: 'Regular Wash',
          tier: 'STANDARD',
          price: 80,
          quantity: 2,
          isService: true,
        ),
      ],
      discount: 0,
      paymentMethod: 'CASH',
      processedByName: 'Maria Santos',
      processedByRole: 'Cashier',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTransactionTap(TransactionModel tx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionDetailsScreen(transaction: tx),
      ),
    );
  }

  IconData _getTransactionIcon(int index) {
    if (index % 3 == 0) return Icons.checkroom_rounded;
    if (index % 3 == 1) return Icons.dry_cleaning_rounded;
    return Icons.local_laundry_service_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered =
        _transactions
            .where(
              (t) =>
                  t.customerName.toLowerCase().contains(query) ||
                  t.id.toLowerCase().contains(query),
            )
            .toList();

    return Scaffold(
      backgroundColor: AppColors.neutral[400],
      appBar: AppBar(
        title: Text(
          'Transaction History',
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
                const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B4F4E),
                  ),
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
                      final tx = filtered[index];
                      return InkWell(
                        onTap: () => _onTransactionTap(tx),
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
                                      _getTransactionIcon(index),
                                      color: AppColors.accent,
                                      size: 20,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    tx.time,
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
                                    tx.customerName,
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
                                    'P${tx.total.toStringAsFixed(2)}',
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
                      final tx = filtered[index];
                      return InkWell(
                        onTap: () => _onTransactionTap(tx),
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
                                  _getTransactionIcon(index),
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
                                      tx.customerName,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2C2D2D),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      tx.time,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.secondary[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'P${tx.total.toStringAsFixed(2)}',
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
