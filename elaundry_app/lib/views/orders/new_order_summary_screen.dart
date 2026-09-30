import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../models/order_models.dart';
import '../../shared/field_label.dart';
import '../../shared/input_decoration.dart';
import '../catalog/widgets/catalog_section_card.dart';

class NewOrderSummaryScreen extends StatefulWidget {
  final List<BasketItem> baskets;
  final List<OrderLineItem> selectedItems;

  const NewOrderSummaryScreen({
    super.key,
    required this.baskets,
    required this.selectedItems,
  });

  @override
  State<NewOrderSummaryScreen> createState() => _NewOrderSummaryScreenState();
}

class _NewOrderSummaryScreenState extends State<NewOrderSummaryScreen> {
  final _nameController = TextEditingController(text: 'Juan Dela Cruz');
  final _contactController = TextEditingController(text: '+63 987 123 4560');
  String _paymentMethod = 'CASH';

  double get subtotal =>
      widget.selectedItems.fold(0.0, (s, i) => s + (i.price * i.quantity));
  double get discount => 0.0;
  double get total => (subtotal - discount).clamp(0.0, double.infinity);

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _addToOrder() {
    final order = LaundryOrder(
      id: '#123456',
      customerName:
          _nameController.text.trim().isEmpty
              ? 'Guest'
              : _nameController.text.trim(),
      contactNumber: _contactController.text.trim(),
      dateTime: 'August 21, 2026 • 10:00 AM',
      time: '10:00 AM',
      baskets: widget.baskets,
      items: widget.selectedItems,
      discount: discount,
      paymentMethod: _paymentMethod,
    );
    Navigator.of(context).pop(order);
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.primary[100]!;
    final services = widget.selectedItems.where((i) => i.isService).toList();
    final addons = widget.selectedItems.where((i) => !i.isService).toList();

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              '#123456',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222423),
              ),
            ),
            Text(
              'August 21, 2026 • 10:00 AM',
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
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.secondary[900],
            ),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    'P${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: AppColors.neutral[600]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _addToOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Add to Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. CUSTOMER INFORMATION
                  CatalogSectionCard(
                    stepNumber: '1',
                    title: 'CUSTOMER INFORMATION',
                    children: [
                      const FieldLabel(label: 'FULL NAME', letterSpacing: 0),
                      TextFormField(
                        controller: _nameController,
                        decoration: appInputDecoration(
                          hintText: 'Juan Dela Cruz',
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const FieldLabel(
                        label: 'CONTACT NUMBER',
                        letterSpacing: 0,
                      ),
                      TextFormField(
                        controller: _contactController,
                        decoration: appInputDecoration(
                          hintText: '+63 987 123 4560',
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. ORDER DETAILS
                  CatalogSectionCard(
                    stepNumber: '2',
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

                  // 3. ORDER SUMMARY
                  CatalogSectionCard(
                    stepNumber: '3',
                    title: 'ORDER SUMMARY',
                    children: [
                      _twoColRow('Subtotal', 'P${subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 6),
                      _twoColRow('Discount', 'P${discount.toStringAsFixed(2)}'),
                      Divider(color: AppColors.neutral[400], height: 16),
                      _twoColRow(
                        'Total',
                        'P${total.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. PAYMENT METHOD
                  CatalogSectionCard(
                    stepNumber: '4',
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
                              child: GestureDetector(
                                onTap:
                                    () =>
                                        setState(() => _paymentMethod = 'CASH'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        _paymentMethod == 'CASH'
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
                                          _paymentMethod == 'CASH'
                                              ? Colors.white
                                              : AppColors.secondary[400],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    () => setState(
                                      () => _paymentMethod = 'CASHLESS',
                                    ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        _paymentMethod == 'CASHLESS'
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
                                          _paymentMethod == 'CASHLESS'
                                              ? Colors.white
                                              : AppColors.secondary[400],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
