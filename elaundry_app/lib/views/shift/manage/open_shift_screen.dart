import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';

class OpenShiftScreen extends StatefulWidget {
  const OpenShiftScreen({super.key});

  @override
  State<OpenShiftScreen> createState() => _OpenShiftScreenState();
}

class _OpenShiftScreenState extends State<OpenShiftScreen> {
  String _amountStr = '0';

  void _onKeyPress(String val) {
    if (_amountStr == '0') {
      _amountStr = val;
    } else if (_amountStr.length < 9) {
      if (val == '.' && _amountStr.contains('.')) return;
      _amountStr += val;
    }
    setState(() {});
  }

  void _onBackspace() {
    if (_amountStr.isNotEmpty) {
      _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      if (_amountStr.isEmpty) _amountStr = '0';
      setState(() {});
    }
  }

  String _formatDisplay(String val) {
    if (val.isEmpty) return '0';
    final parts = val.split('.');
    final integerPart = parts[0];
    final formattedInt = integerPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    if (parts.length > 1) {
      return '$formattedInt.${parts[1]}';
    }
    return formattedInt;
  }

  void _confirm() {
    final parsed = double.tryParse(_amountStr.replaceAll(',', '')) ?? 0.0;
    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral[400],
      appBar: AppBar(
        title: const Text(
          'Open Shift',
          style: TextStyle(
            fontSize: 20,
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
            height: 50,
            child: ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Open Shift',
                style: TextStyle(
                  fontSize: 15,
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
            const SizedBox(height: 24),
            // Header prompt
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter Cash Amount:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondary[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),

            // Cash Display
            Text(
              'Php  ${_formatDisplay(_amountStr)}',
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E201F),
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(flex: 2),

            // Keypad Grid Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: 18),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: 18),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildKeyItem('.', isSpecial: true),
                      _buildKeyItem('0'),
                      _buildBackspaceKey(),
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

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: keys.map((k) => _buildKeyItem(k)).toList(),
    );
  }

  Widget _buildKeyItem(String key, {bool isSpecial = false}) {
    return InkWell(
      onTap: () => _onKeyPress(key),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 64,
        height: 52,
        alignment: Alignment.center,
        child: Text(
          key,
          style: TextStyle(
            fontSize: isSpecial ? 30 : 23,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C2D2D),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return InkWell(
      onTap: _onBackspace,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 64,
        height: 52,
        alignment: Alignment.center,
        child: const Icon(
          Icons.backspace_outlined,
          color: Color(0xFF333534),
          size: 22,
        ),
      ),
    );
  }
}
