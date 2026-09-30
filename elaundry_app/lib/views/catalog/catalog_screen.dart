import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../models/catalog_models.dart';
import '../../shared/laundry_navigation_fab.dart';
import '../../shared/search_filter_bar.dart';
import './categories/category_catalog_subview.dart';
import './categories/edit_category_screen.dart';
import './categories/edit_discount_screen.dart';
import './items/edit_item_screen.dart';
import './items/item_catalog_subview.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  int _selectedTabIndex = 0; // 0: Item, 1: Category
  bool _isGridView = false;

  final List<CatalogItem> _items = [
    const CatalogItem(
      id: '1',
      name: 'Regular Wash',
      category: 'Services',
      machineType: 'Standard',
      price: 'P80.00',
      capacity: '5kg to 13kg',
      duration: '38 mins',
    ),
    const CatalogItem(
      id: '2',
      name: 'Regular Wash',
      category: 'Services',
      machineType: 'Standard',
      price: 'P80.00',
      capacity: '5kg to 13kg',
      duration: '38 mins',
    ),
    const CatalogItem(
      id: '3',
      name: 'Regular Wash',
      category: 'Services',
      machineType: 'Standard',
      price: 'P80.00',
      capacity: '5kg to 13kg',
      duration: '38 mins',
    ),
  ];

  final List<CatalogCategory> _categories = [
    const CatalogCategory(id: '1', name: 'Services', quantity: 10),
    const CatalogCategory(id: '2', name: 'Add-on', quantity: 10),
    const CatalogCategory(
      id: '3',
      name: 'P100 off',
      quantity: 1,
      minSpend: 'Min. Spend P0',
      isDiscount: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddItem() async {
    final newItem = await Navigator.of(context).push<CatalogItem>(
      MaterialPageRoute(builder: (context) => const EditItemScreen()),
    );
    if (newItem != null) {
      setState(() => _items.add(newItem));
    }
  }

  void _openAddCategory() async {
    final newCat = await Navigator.of(context).push<CatalogCategory>(
      MaterialPageRoute(builder: (context) => const EditCategoryScreen()),
    );
    if (newCat != null) {
      setState(() => _categories.add(newCat));
    }
  }

  void _openAddDiscount() async {
    final newDiscount = await Navigator.of(context).push<CatalogCategory>(
      MaterialPageRoute(builder: (context) => const EditDiscountScreen()),
    );
    if (newDiscount != null) {
      setState(() => _categories.add(newDiscount));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral[400],
      appBar: AppBar(
        title: Text(
          'Catalog',
          style: theme.textTheme.titleLarge?.copyWith(
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
                // Segmented Switcher (Item | Category)
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  _selectedTabIndex == 0
                                      ? AppColors.neutral[200]
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Item',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color:
                                    _selectedTabIndex == 0
                                        ? AppColors.secondary[900]
                                        : AppColors.secondary[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.neutral[400],
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  _selectedTabIndex == 1
                                      ? AppColors.neutral[200]
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color:
                                    _selectedTabIndex == 1
                                        ? AppColors.secondary[900]
                                        : AppColors.secondary[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Separated Capsule Search, Filter & View Toggle Bar
                CapsuleSearchFilterBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  onFilterTap: () {},
                  isGridView: _isGridView,
                  onToggleView:
                      () => setState(() => _isGridView = !_isGridView),
                  hintText: 'Search',
                ),
                const SizedBox(height: 16),

                // Subview Content
                _selectedTabIndex == 0
                    ? ItemCatalogSubview(
                      items: _items,
                      isGridView: _isGridView,
                      onAddItem: _openAddItem,
                    )
                    : CategoryCatalogSubview(
                      categories: _categories,
                      isGridView: _isGridView, // Forwarded grid view state
                      onAddDiscount: _openAddDiscount,
                      onAddCategory: _openAddCategory,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
