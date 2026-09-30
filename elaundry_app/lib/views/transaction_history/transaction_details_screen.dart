import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../models/transaction_model.dart';
import '../catalog/widgets/icon_section_card.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  void _showMarkAsUnpaidDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Mark as Unpaid?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This transaction will be converted back to an active pending order for ${transaction.customerName}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.secondary[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: AppColors.neutral[400], height: 1),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC7C9C8),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogCtx).pop();
                              Navigator.of(context).pop('unpaid');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Confirm',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Delete Transaction?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Are you sure you want to delete transaction ${transaction.id} for ${transaction.customerName}? This will permanently remove it from records.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.secondary[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: AppColors.neutral[400], height: 1),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC7C9C8),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogCtx).pop();
                              Navigator.of(context).pop('deleted');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Delete',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.primary[100]!;
    final services = transaction.items.where((i) => i.isService).toList();
    final addons = transaction.items.where((i) => !i.isService).toList();

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              transaction.id,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222423),
              ),
            ),
            Text(
              transaction.dateTime,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.secondary[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.secondary[900],
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.secondary[900],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (val) {
              if (val == 'unpaid') {
                _showMarkAsUnpaidDialog(context);
              } else if (val == 'delete') {
                _showDeleteDialog(context);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'unpaid',
                    child: Row(
                      children: [
                        Icon(
                          Icons.replay_rounded,
                          size: 18,
                          color: Color(0xFF2C2D2D),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Mark as Unpaid',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C2D2D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete Transaction',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. CUSTOMER
                  IconSectionCard(
                    icon: Icons.person_rounded,
                    title: 'CUSTOMER',
                    children: [
                      _twoColRow('NAME', transaction.customerName),
                      const SizedBox(height: 8),
                      _twoColRow('CONTACT NO.', transaction.contactNumber),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. BASKET
                  IconSectionCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'BASKET',
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BASKET #',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary[500],
                            ),
                          ),
                          Text(
                            'WEIGHT',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary[500],
                            ),
                          ),
                        ],
                      ),
                      Divider(color: AppColors.neutral[400], height: 12),
                      ...transaction.baskets.map(
                        (b) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${b.number}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF2C2D2D),
                                ),
                              ),
                              Text(
                                '${b.weight.toInt()} KG',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF2C2D2D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. ORDER DETAILS (Breakdown)
                  IconSectionCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'ORDER DETAILS',
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ITEM',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary[500],
                            ),
                          ),
                          Text(
                            'AMOUNT',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary[500],
                            ),
                          ),
                        ],
                      ),
                      Divider(color: AppColors.neutral[400], height: 12),
                      if (services.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Services',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2C2D2D),
                              ),
                            ),
                            Text(
                              'P${services.fold(0.0, (s, i) => s + (i.price * i.quantity)).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        ...services.map(
                          (s) => _breakdownSubRow(
                            '${s.name}  x ${s.quantity}',
                            s.price * s.quantity,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (addons.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Add-ons',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2C2D2D),
                              ),
                            ),
                            Text(
                              'P${addons.fold(0.0, (s, i) => s + (i.price * i.quantity)).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        ...addons.map(
                          (a) => _breakdownSubRow(
                            '${a.name}  x ${a.quantity}',
                            a.price * a.quantity,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. ORDER SUMMARY
                  IconSectionCard(
                    icon: Icons.list_alt_rounded,
                    title: 'ORDER SUMMARY',
                    children: [
                      _twoColRow(
                        'Subtotal',
                        'P${transaction.subtotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 6),
                      _twoColRow(
                        'Discount',
                        '-P${transaction.discount.toStringAsFixed(2)}',
                      ),
                      Divider(color: AppColors.neutral[400], height: 16),
                      _twoColRow(
                        'Total',
                        'P${transaction.total.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 5. PAYMENT METHOD
                  IconSectionCard(
                    icon: Icons.credit_card_rounded,
                    title: 'PAYMENT METHOD',
                    children: [
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.neutral[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      transaction.paymentMethod == 'CASH'
                                          ? AppColors.accent
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'CASH',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        transaction.paymentMethod == 'CASH'
                                            ? Colors.white
                                            : AppColors.secondary[400],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      transaction.paymentMethod == 'CASHLESS'
                                          ? AppColors.accent
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'CASHLESS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        transaction.paymentMethod == 'CASHLESS'
                                            ? Colors.white
                                            : AppColors.secondary[400],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 6. PROCESSED BY
                  IconSectionCard(
                    icon: Icons.person_outline_rounded,
                    title: 'PROCESSED BY',
                    children: [
                      _twoColRow('NAME', transaction.processedByName),
                      const SizedBox(height: 8),
                      _twoColRow('ROLE', transaction.processedByRole),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _twoColRow(String left, String right, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? const Color(0xFF2C2D2D) : AppColors.secondary[500],
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: const Color(0xFF2C2D2D),
          ),
        ),
      ],
    );
  }

  Widget _breakdownSubRow(String text, double amt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              text,
              style: TextStyle(fontSize: 11.5, color: AppColors.secondary[500]),
            ),
          ),
          Text(
            amt.toStringAsFixed(2),
            style: TextStyle(fontSize: 11.5, color: AppColors.secondary[500]),
          ),
        ],
      ),
    );
  }
}
