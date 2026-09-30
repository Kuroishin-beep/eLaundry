import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../models/order_models.dart';
import '../../shared/input_decoration.dart';
import '../../shared/search_filter_bar.dart';
import '../catalog/widgets/icon_section_card.dart';
import 'new_order_summary_screen.dart';

class AddToCartScreen extends StatefulWidget {
  const AddToCartScreen({super.key});

  @override
  State<AddToCartScreen> createState() => _AddToCartScreenState();
}

class _AddToCartScreenState extends State<AddToCartScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = false;

  final List<BasketItem> _baskets = [const BasketItem(number: 1, weight: 0)];
  final List<TextEditingController> _basketControllers = [];

  final List<OrderLineItem> _availableItems = [
    const OrderLineItem(
      id: 's1',
      name: 'Regular Full Service',
      tier: 'STANDARD',
      duration: 'Wash: 38 mins | Dry: 40 mins',
      price: 200,
      isService: true,
    ),
    const OrderLineItem(
      id: 's2',
      name: 'Premium Full Service',
      tier: 'STANDARD',
      duration: 'Wash: 48 mins | Dry: 50 mins',
      price: 220,
      isService: true,
    ),
    const OrderLineItem(
      id: 's3',
      name: 'Regular Full Service',
      tier: 'PLUS+',
      duration: 'Wash: 38 mins | Dry: 40 mins',
      price: 350,
      isService: true,
    ),
    const OrderLineItem(
      id: 's4',
      name: 'Premium Full Service',
      tier: 'PLUS+',
      duration: 'Wash: 48 mins | Dry: 50 mins',
      price: 370,
      isService: true,
    ),
    const OrderLineItem(
      id: 'a1',
      name: 'Fold',
      tier: 'STANDARD',
      price: 40,
      isService: false,
    ),
    const OrderLineItem(
      id: 'a2',
      name: 'Fold',
      tier: 'PLUS+',
      price: 60,
      isService: false,
    ),
    const OrderLineItem(
      id: 'a3',
      name: 'Fabric Softener',
      tier: 'PLUS+',
      price: 15,
      isService: false,
    ),
    const OrderLineItem(
      id: 'a4',
      name: 'Detergent',
      tier: 'PLUS+',
      price: 30,
      isService: false,
    ),
    const OrderLineItem(
      id: 'a5',
      name: 'Plastic Bag',
      tier: 'STANDARD',
      price: 5,
      isService: false,
    ),
    const OrderLineItem(
      id: 'a6',
      name: 'Plastic Bag',
      tier: 'PLUS+',
      price: 10,
      isService: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _basketControllers.add(TextEditingController(text: ''));
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final c in _basketControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncBasketWeights() {
    final updated = <BasketItem>[];
    for (int i = 0; i < _baskets.length; i++) {
      final text =
          i < _basketControllers.length ? _basketControllers[i].text : '0';
      final weight = double.tryParse(text) ?? 0.0;
      updated.add(BasketItem(number: i + 1, weight: weight));
    }
    _baskets
      ..clear()
      ..addAll(updated);
  }

  void _addBasket() {
    _syncBasketWeights();
    setState(() {
      _baskets.add(BasketItem(number: _baskets.length + 1, weight: 0));
      _basketControllers.add(TextEditingController(text: ''));
    });
  }

  void _removeBasket(int index) {
    _syncBasketWeights();
    setState(() {
      _baskets.removeAt(index);
      _basketControllers[index].dispose();
      _basketControllers.removeAt(index);
    });
  }

  void _updateQuantity(String id, int delta) {
    setState(() {
      final idx = _availableItems.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final current = _availableItems[idx];
        final next = (current.quantity + delta).clamp(0, 99);
        _availableItems[idx] = current.copyWith(quantity: next);
      }
    });
  }

  void _proceed() async {
    _syncBasketWeights();
    final selectedItems = _availableItems.where((i) => i.quantity > 0).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service or add-on.'),
        ),
      );
      return;
    }

    final createdOrder = await Navigator.of(context).push<LaundryOrder>(
      MaterialPageRoute(
        builder:
            (context) => NewOrderSummaryScreen(
              baskets: _baskets,
              selectedItems: selectedItems,
            ),
      ),
    );

    if (createdOrder != null && mounted) {
      Navigator.of(context).pop(createdOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.primary[100]!;
    final q = _searchController.text.trim().toLowerCase();
    final filtered =
        _availableItems.where((i) => i.name.toLowerCase().contains(q)).toList();
    final services = filtered.where((i) => i.isService).toList();
    final addons = filtered.where((i) => !i.isService).toList();

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: const Text(
          'Add to Cart',
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
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: SafeArea(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _proceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Proceed',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
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

                  // 1. ADD BASKET (Interactive weights)
                  IconSectionCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'ADD BASKET',
                    children: [
                      ..._baskets.asMap().entries.map((entry) {
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

                  // 2. SERVICES (List vs Grid)
                  IconSectionCard(
                    icon: Icons.local_laundry_service_outlined,
                    title: 'SERVICES',
                    children: [
                      _isGridView
                          ? _buildGridItems(services)
                          : _buildListItems(services),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. ADD-ONS (List vs Grid)
                  IconSectionCard(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'ADD-ONS',
                    children: [
                      _isGridView
                          ? _buildGridItems(addons)
                          : _buildListItems(addons),
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

  Widget _buildListItems(List<OrderLineItem> items) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E7E6), width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: List.generate(items.length, (index) {
            final i = items[index];
            final isLast = index == items.length - 1;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                border:
                    isLast
                        ? null
                        : const Border(
                          bottom: BorderSide(
                            color: Color(0xFFEBEFEF),
                            width: 1.0,
                          ),
                        ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.neutral[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      i.isService
                          ? Icons.local_laundry_service_outlined
                          : Icons.shopping_basket_outlined,
                      color: const Color(0xFF676E6C),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    i.tier == 'PLUS+'
                                        ? const Color(0xFF7E1035)
                                        : AppColors.accent,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                i.tier,
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
                                i.name,
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
                        if (i.duration.isNotEmpty)
                          Text(
                            i.duration,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.secondary[400],
                            ),
                          ),
                        Text(
                          'P${i.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
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
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          icon: const Icon(Icons.remove, size: 14),
                          onPressed: () => _updateQuantity(i.id, -1),
                        ),
                        Text(
                          '${i.quantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          icon: const Icon(Icons.add, size: 14),
                          onPressed: () => _updateQuantity(i.id, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // Matches _ItemGridCard layout and adds the subtle light gray border
  Widget _buildGridItems(List<OrderLineItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E7E6), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.neutral[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(
                      item.isService
                          ? Icons.local_laundry_service_rounded
                          : Icons.shopping_basket_rounded,
                      size: 36,
                      color: const Color(0xFF637371),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                'P${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.neutral[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        icon: const Icon(Icons.remove, size: 12),
                        onPressed: () => _updateQuantity(item.id, -1),
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        icon: const Icon(Icons.add, size: 12),
                        onPressed: () => _updateQuantity(item.id, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
