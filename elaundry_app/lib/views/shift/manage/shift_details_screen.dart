import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/shift_model.dart';

class ShiftDetailsScreen extends StatelessWidget {
  final ShiftModel shift;

  const ShiftDetailsScreen({super.key, required this.shift});

  Future<void> _closeShift(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Email this report?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A copy of this report will be sent to\njuan********@gmail.com.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondary[600],
                      height: 1.45,
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
                            onPressed:
                                () => Navigator.of(dialogCtx).pop('save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC7C9C8),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Save Only',
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
                            onPressed:
                                () => Navigator.of(dialogCtx).pop('send_save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Send & Save',
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

    if (result == null || !context.mounted) return;

    final closedAt = TimeOfDay.fromDateTime(DateTime.now()).format(context);
    Navigator.of(
      context,
    ).pop(shift.copyWith(isClosed: true, closedAt: closedAt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral[400],
      appBar: AppBar(
        title: Text(
          'Shift Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary[900],
          ),
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
      ),
      bottomNavigationBar:
          shift.isClosed
              ? null
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _closeShift(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Close Shift',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shift.id,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222423),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          shift.dateTime,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondary[500],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: 'Status',
                          value: shift.isClosed ? 'Closed' : 'Active',
                        ),
                        if (shift.closedAt != null)
                          _DetailRow(
                            label: 'Closed at',
                            value: shift.closedAt!,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Starting cash',
                          value: _formatAmount(shift.startingCash),
                        ),
                        _DetailRow(
                          label: 'Cash payments',
                          value: _formatAmount(shift.cashPayments),
                        ),
                        _DetailRow(
                          label: 'Cashless payments',
                          value: _formatAmount(shift.cashlessPayments),
                        ),
                        _DetailRow(
                          label: 'Gross sales',
                          value: _formatAmount(shift.grossSales),
                        ),
                        _DetailRow(
                          label: 'Refunds',
                          value: _formatAmount(shift.totalRefund),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Net sales',
                          value: _formatAmount(shift.netSales),
                          emphasized: true,
                        ),
                        _DetailRow(
                          label: 'Pending orders',
                          value: shift.pendingOrders.toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) => 'P${amount.toStringAsFixed(2)}';
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: emphasized ? 15 : 13,
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
      color: emphasized ? AppColors.secondary[900] : AppColors.secondary[600],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
