import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/order_models.dart';

class PaymentScreen extends StatefulWidget {
  final LaundryOrder order;

  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _amountStr = '0';
  bool _isExact = false;

  void _onKeyPress(String val) {
    if (_isExact) _isExact = false;
    if (_amountStr == '0') {
      _amountStr = val;
    } else if (_amountStr.length < 9) {
      if (val == '.' && _amountStr.contains('.')) return;
      _amountStr += val;
    }
    setState(() {});
  }

  void _onBackspace() {
    if (_isExact) _isExact = false;
    if (_amountStr.isNotEmpty) {
      _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      if (_amountStr.isEmpty) _amountStr = '0';
      setState(() {});
    }
  }

  void _toggleExact(bool? val) {
    setState(() {
      _isExact = val ?? false;
      if (_isExact) {
        _amountStr = widget.order.total.toInt().toString();
      }
    });
  }

  void _showChangeDialog(double change) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F8A5F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Php ${change.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E2120),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondary[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F8A5F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _markAsPaid() {
    final paidAmt = double.tryParse(_amountStr) ?? 0.0;
    if (paidAmt < widget.order.total) {
      AppSnackBar.showWarning(
        context,
        'Please enter an amount that covers the total bill.',
      );
      return;
    }
    final change = (paidAmt - widget.order.total).clamp(0.0, double.infinity);
    _showChangeDialog(change);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral[400],
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222423),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _markAsPaid,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Mark as Paid',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            Text(
              'Php  $_amountStr',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E201F),
              ),
            ),
            const Spacer(flex: 1),
            // Exact amount selection box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isExact,
                      onChanged: _toggleExact,
                      activeColor: const Color(0xFF0F8A5F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const Text(
                      'Exact amount',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2D2D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Keypad
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _keypadRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _keypadRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _keypadRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _keyItem('.', isSpecial: true),
                      _keyItem('0'),
                      _backspaceKey(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _keypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: keys.map((k) => _keyItem(k)).toList(),
    );
  }

  Widget _keyItem(String key, {bool isSpecial = false}) {
    return InkWell(
      onTap: () => _onKeyPress(key),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 64,
        height: 48,
        alignment: Alignment.center,
        child: Text(
          key,
          style: TextStyle(
            fontSize: isSpecial ? 28 : 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C2D2D),
          ),
        ),
      ),
    );
  }

  Widget _backspaceKey() {
    return InkWell(
      onTap: _onBackspace,
      borderRadius: BorderRadius.circular(28),
      child: const SizedBox(
        width: 64,
        height: 48,
        child: Icon(
          Icons.backspace_outlined,
          color: Color(0xFF333534),
          size: 22,
        ),
      ),
    );
  }
}
