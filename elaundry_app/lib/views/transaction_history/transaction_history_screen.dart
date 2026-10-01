import 'dart:async';

import 'package:flutter/material.dart';

import '../../controllers/transaction_controller.dart';
import '../../core/themes/theme.dart';
import '../../models/transaction_model.dart';
import '../../shared/empty_states.dart';
import '../../shared/laundry_navigation_fab.dart';
import '../../shared/search_filter_bar.dart';
import '../../shared/sort_dialog.dart';
import 'transaction_details_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TransactionController _transactionController = TransactionController();
  final _searchController = TextEditingController();
  bool _isGridView = false;
  ListSortOption _sortOption = ListSortOption.dateNewest;
  final List<TransactionModel> _transactions = [];
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;
  Object? _loadError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _transactionsSubscription = _transactionController
        .watchTransactions()
        .listen(
          (transactions) {
            if (!mounted) return;
            setState(() {
              _transactions
                ..clear()
                ..addAll(transactions);
              _loadError = null;
              _isLoading = false;
            });
          },
          onError: (Object error) {
            if (!mounted) return;
            setState(() {
              _loadError = error;
              _isLoading = false;
            });
          },
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    unawaited(_transactionsSubscription?.cancel());
    super.dispose();
  }

  Future<void> _onTransactionTap(TransactionModel tx) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => TransactionDetailsScreen(transaction: tx),
      ),
    );
    if (result != 'unpaid') return;

    try {
      await _transactionController.markOrderUnpaid(tx.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 15),
          content: Text('Order marked as unpaid.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 15),
          content: Text('Unable to mark order as unpaid: $error'),
        ),
      );
    }
  }

  IconData _getTransactionIcon(int index) {
    if (index % 3 == 0) return Icons.checkroom_rounded;
    if (index % 3 == 1) return Icons.dry_cleaning_rounded;
    return Icons.local_laundry_service_outlined;
  }

  Future<void> _openSortDialog() async {
    final option = await showListSortDialog(
      context,
      selected: _sortOption,
      title: 'Filter transactions',
    );
    if (option != null && mounted) setState(() => _sortOption = option);
  }

  void _sortTransactions(List<TransactionModel> transactions) {
    transactions.sort((left, right) {
      switch (_sortOption) {
        case ListSortOption.nameAscending:
          return left.customerName.toLowerCase().compareTo(
            right.customerName.toLowerCase(),
          );
        case ListSortOption.priceDescending:
          return right.total.compareTo(left.total);
        case ListSortOption.priceAscending:
          return left.total.compareTo(right.total);
        case ListSortOption.dateNewest:
          return _dateValue(right.dateTime).compareTo(_dateValue(left.dateTime));
        case ListSortOption.dateOldest:
          return _dateValue(left.dateTime).compareTo(_dateValue(right.dateTime));
      }
    });
  }

  DateTime _dateValue(String value) =>
      DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);

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
    _sortTransactions(filtered);

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
                  onFilterTap: _openSortDialog,
                  isGridView: _isGridView,
                  onToggleView:
                      () => setState(() => _isGridView = !_isGridView),
                  hintText: 'Search',
                ),
                const SizedBox(height: 14),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_loadError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Unable to load transactions: $_loadError',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.secondary[600]),
                    ),
                  )
                else if (filtered.isEmpty)
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height - 300,
                    child: Center(
                      child: const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Transactions Yet',
                        description:
                            'Orders will appear here after payment is completed.',
                      ),
                    ),
                  )
                else ...[
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
