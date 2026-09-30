import 'package:flutter/material.dart';

import '../../controllers/order_controller.dart';
import '../../core/themes/theme.dart';
import '../../models/order_models.dart';
import '../../shared/input_decoration.dart';
import '../catalog/widgets/icon_section_card.dart';
import 'payment_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final LaundryOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderController _orderController = OrderController();
  late LaundryOrder _order;
  final List<TextEditingController> _basketControllers = [];
  List<OrderLineItem> _availableItems = [];
  bool _isLoadingCatalog = true;
  Object? _catalogError;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _initBasketControllers();
    _loadCatalogItems();
  }

  Future<void> _loadCatalogItems() async {
    try {
      final items = await _orderController.getOrderableItems();
      if (!mounted) return;
      setState(() {
        _availableItems = items;
        _isLoadingCatalog = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _catalogError = error;
        _isLoadingCatalog = false;
      });
    }
  }

  void _initBasketControllers() {
    _basketControllers.clear();
    for (final b in _order.baskets) {
      _basketControllers.add(
        TextEditingController(
          text: b.weight > 0 ? b.weight.toInt().toString() : '',
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _basketControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncBasketWeights() {
    final updated = <BasketItem>[];
    for (int i = 0; i < _order.baskets.length; i++) {
      final text =
          i < _basketControllers.length ? _basketControllers[i].text : '0';
      final weight = double.tryParse(text) ?? 0.0;
      updated.add(BasketItem(number: i + 1, weight: weight));
    }
    _order = _order.copyWith(baskets: updated);
  }

  void _showDeleteDialog() {
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
                    'Cancel Order?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Are you sure you want to cancel order ${_order.id} for ${_order.customerName}?',
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
                              Navigator.of(context).pop('cancelled');
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
                              'Cancel Order',
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

  void _addBasket() {
    _syncBasketWeights();
    setState(() {
      final nextNum = _order.baskets.length + 1;
      _order = _order.copyWith(
        baskets: [..._order.baskets, BasketItem(number: nextNum, weight: 0)],
      );
      _basketControllers.add(TextEditingController(text: ''));
    });
  }

  void _removeBasket(int index) {
    _syncBasketWeights();
    setState(() {
      final updated = List<BasketItem>.from(_order.baskets)..removeAt(index);
      _basketControllers[index].dispose();
      _basketControllers.removeAt(index);
      _order = _order.copyWith(baskets: updated);
    });
  }

  void _updateQuantity(String id, int delta) {
    _syncBasketWeights();
    setState(() {
      final updated =
          _order.items
              .map((i) {
                if (i.id == id) {
                  final nextQ = (i.quantity + delta).clamp(0, 99);
                  return i.copyWith(quantity: nextQ);
                }
                return i;
              })
              .where((i) => i.quantity > 0)
              .toList();

      _order = _order.copyWith(items: updated);
    });
  }

  void _openAddItemModal({required bool isService}) {
    final catalogList =
        _availableItems.where((item) => item.isService == isService).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isService ? 'Add Service' : 'Add Add-on',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2D2D),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 1),
                const SizedBox(height: 8),
                if (_isLoadingCatalog)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_catalogError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Unable to load catalog: $_catalogError',
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (catalogList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      isService
                          ? 'No services are available in the catalog.'
                          : 'No add-ons are available in the catalog.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.secondary[500]),
                    ),
                  )
                else
                  ...catalogList.map((avail) {
                    final existing = _order.items.any(
                      (item) => item.id == avail.id,
                    );
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        avail.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: Text(
                        'P${avail.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _syncBasketWeights();
                          setState(() {
                            final currentList = List<OrderLineItem>.from(
                              _order.items,
                            );
                            final index = currentList.indexWhere(
                              (item) => item.id == avail.id,
                            );
                            if (index != -1) {
                              currentList[index] = currentList[index].copyWith(
                                quantity: currentList[index].quantity + 1,
                              );
                            } else {
                              currentList.add(avail.copyWith(quantity: 1));
                            }
                            _order = _order.copyWith(items: currentList);
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size(60, 30),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          existing ? '+1 More' : 'Add',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _proceedToPayment() async {
    _syncBasketWeights();
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => PaymentScreen(order: _order)),
    );

    if (paid == true && mounted) {
      Navigator.of(context).pop('paid');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.primary[100]!;
    final services = _order.items.where((i) => i.isService).toList();
    final addons = _order.items.where((i) => !i.isService).toList();

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              _order.id,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222423),
              ),
            ),
            Text(
              _order.dateTime,
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
          onPressed: () {
            _syncBasketWeights();
            Navigator.of(context).pop(_order);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.secondary[900],
            ),
            onSelected: (val) {
              if (val == 'delete') {
                _showDeleteDialog();
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder:
                (context) => [
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
                          'Cancel Order',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
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
                    'P${_order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Proceed to Payment',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
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
                  // 1. CUSTOMER
                  IconSectionCard(
                    icon: Icons.person_rounded,
                    title: 'CUSTOMER',
                    children: [
                      _twoColRow('NAME', _order.customerName),
                      const SizedBox(height: 8),
                      _twoColRow('CONTACT NO.', _order.contactNumber),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. BASKET
                  IconSectionCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'BASKET',
                    children: [
                      ..._order.baskets.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final b = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: Text(
                                  'Basket ${b.number}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C2D2D),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _basketControllers[idx],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2C2D2D),
                                  ),
                                  decoration: appInputDecoration(
                                    hintText: '0',
                                    suffixText: 'kg',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFF6B7472),
                                  size: 22,
                                ),
                                onPressed: () => _removeBasket(idx),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _addBasket,
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
                            'Basket',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. ORDERS
                  IconSectionCard(
                    icon: Icons.shopping_cart_outlined,
                    title: 'ORDERS',
                    children: [
                      // Services Group
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.neutral[400]!),
                        ),
                        child: Column(
                          children:
                              services.map((s) => _buildItemTile(s)).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _openAddItemModal(isService: true),
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
                            'Service',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Add-ons Group
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.neutral[400]!),
                        ),
                        child: Column(
                          children:
                              addons.map((a) => _buildItemTile(a)).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _openAddItemModal(isService: false),
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
                            'Add-on',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. ORDER DETAILS (Breakdown)
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
                  ),
                  const SizedBox(height: 14),

                  // 5. ORDER SUMMARY
                  IconSectionCard(
                    icon: Icons.list_alt_rounded,
                    title: 'ORDER SUMMARY',
                    children: [
                      _twoColRow(
                        'Subtotal',
                        'P${_order.subtotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 6),
                      _twoColRow(
                        'Discount',
                        '-P${_order.discount.toStringAsFixed(2)}',
                      ),
                      Divider(color: AppColors.neutral[400], height: 16),
                      _twoColRow(
                        'Total',
                        'P${_order.total.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 6. PAYMENT METHOD
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
                              child: GestureDetector(
                                onTap:
                                    () => setState(
                                      () =>
                                          _order = _order.copyWith(
                                            paymentMethod: 'CASH',
                                          ),
                                    ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        _order.paymentMethod == 'CASH'
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
                                          _order.paymentMethod == 'CASH'
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
                                      () =>
                                          _order = _order.copyWith(
                                            paymentMethod: 'CASHLESS',
                                          ),
                                    ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        _order.paymentMethod == 'CASHLESS'
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
                                          _order.paymentMethod == 'CASHLESS'
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

  Widget _buildItemTile(OrderLineItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.neutral[400]!, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.neutral[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              item.isService
                  ? Icons.local_laundry_service_outlined
                  : Icons.shopping_basket_outlined,
              color: const Color(0xFF676E6C),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        item.tier,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C2D2D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                if (item.duration.isNotEmpty)
                  Text(
                    item.duration,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.secondary[400],
                    ),
                  ),
                Text(
                  'P${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.neutral[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  icon: const Icon(Icons.remove, size: 14),
                  onPressed: () => _updateQuantity(item.id, -1),
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  icon: const Icon(Icons.add, size: 14),
                  onPressed: () => _updateQuantity(item.id, 1),
                ),
              ],
            ),
          ),
        ],
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
