import 'package:flutter/material.dart';

import '../../../controllers/shift_controller.dart';
import '../../../core/themes/theme.dart';
import '../../../models/shift_model.dart';

class ShiftDetailsScreen extends StatelessWidget {
  final ShiftModel shift;
  final ShiftController controller;

  const ShiftDetailsScreen({
    super.key,
    required this.shift,
    required this.controller,
  });

  Future<void> _closeShift(
    BuildContext context,
    ShiftModel currentShift,
  ) async {
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

    try {
      final closedShift = await controller.closeShift(currentShift);
      if (context.mounted) Navigator.of(context).pop(closedShift);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 15),
          content: Text('Unable to close shift: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ShiftModel>(
      stream: controller.watchShiftSales(shift),
      initialData: shift,
      builder: (context, snapshot) {
        final currentShift = snapshot.data ?? shift;
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.neutral[400],
            body: Center(
              child: Text('Unable to load shift sales: ${snapshot.error}'),
            ),
          );
        }
        return _buildScreen(context, currentShift);
      },
    );
  }

  Widget _buildScreen(BuildContext context, ShiftModel currentShift) {
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
          currentShift.isClosed
              ? null
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _closeShift(context, currentShift),
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
                          currentShift.id,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222423),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentShift.dateTime,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondary[500],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: 'Status',
                          value: currentShift.isClosed ? 'Closed' : 'Active',
                        ),
                        if (currentShift.closedAt != null)
                          _DetailRow(
                            label: 'Closed at',
                            value: currentShift.closedAt!,
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
                          value: _formatAmount(currentShift.startingCash),
                        ),
                        _DetailRow(
                          label: 'Cash payments',
                          value: _formatAmount(currentShift.cashPayments),
                        ),
                        _DetailRow(
                          label: 'Cashless payments',
                          value: _formatAmount(currentShift.cashlessPayments),
                        ),
                        _DetailRow(
                          label: 'Gross sales',
                          value: _formatAmount(currentShift.grossSales),
                        ),
                        _DetailRow(
                          label: 'Refunds',
                          value: _formatAmount(currentShift.totalRefund),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Net sales',
                          value: _formatAmount(currentShift.netSales),
                          emphasized: true,
                        ),
                        _DetailRow(
                          label: 'Pending orders',
                          value: currentShift.pendingOrders.toString(),
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
