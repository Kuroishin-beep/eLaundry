import 'package:flutter/material.dart';

import '../../controllers/catalog_controller.dart';
import '../../controllers/machine_controller.dart';
import '../../core/themes/theme.dart';
import '../../models/catalog_models.dart';
import '../../shared/laundry_navigation_fab.dart';
import '../../shared/search_filter_bar.dart';
import './categories/category_catalog_subview.dart';
import './categories/category_details_screen.dart';
import './categories/edit_category_screen.dart';
import './categories/edit_discount_screen.dart';
import './items/edit_item_screen.dart';
import './items/item_details_screen.dart';
import './items/item_catalog_subview.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final CatalogController _catalogController = CatalogController();
  final MachineController _machineController = MachineController();
  final _searchController = TextEditingController();
  int _selectedTabIndex = 0; // 0: Item, 1: Category
  bool _isGridView = false;
  late Stream<List<CatalogItem>> _itemsStream;
  late Stream<List<CatalogCategory>> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _itemsStream = _catalogController.watchItems();
    _categoriesStream = _catalogController.watchCategoriesAndDiscounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddItem() async {
    try {
      final categoryOptions = await _getItemCategoryOptions();
      final machineOptions = await _getItemMachineOptions();
      if (!mounted) return;
      final newItem = await Navigator.of(context).push<CatalogItem>(
        MaterialPageRoute(
          builder:
              (context) => EditItemScreen(
                categoryOptions: categoryOptions,
                machineOptions: machineOptions,
              ),
        ),
      );
      if (newItem != null) await _catalogController.createItem(newItem);
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _openAddCategory() async {
    try {
      final newCategory = await Navigator.of(context).push<CatalogCategory>(
        MaterialPageRoute(builder: (context) => const EditCategoryScreen()),
      );
      if (newCategory != null) {
        await _catalogController.createCategory(newCategory);
      }
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _openAddDiscount() async {
    try {
      final newDiscount = await Navigator.of(context).push<CatalogCategory>(
        MaterialPageRoute(builder: (context) => const EditDiscountScreen()),
      );
      if (newDiscount != null) {
        await _catalogController.createDiscount(newDiscount);
      }
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _openItemDetails(CatalogItem item) async {
    final categoryOptions = await _getItemCategoryOptions();
    final machineOptions = await _getItemMachineOptions();
    if (!mounted) return;
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder:
            (context) => ItemDetailsScreen(
              item: item,
              categoryOptions: categoryOptions,
              machineOptions: machineOptions,
            ),
      ),
    );
    if (!mounted || result == null) return;

    try {
      if (result == 'deleted') {
        await _catalogController.deleteItem(item.id);
      } else if (result is CatalogItem) {
        await _catalogController.updateItem(result);
      }
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<List<String>> _getItemCategoryOptions() async {
    final categories = await _catalogController.getCategories();
    return categories
        .where((category) => !category.isDiscount)
        .map((category) => category.name)
        .toSet()
        .toList();
  }

  Future<List<String>> _getItemMachineOptions() async {
    final machines = await _machineController.getMachines();
    return machines
        .map((machine) => machine.tier.trim())
        .where((tier) => tier.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> _openCategoryDetails(CatalogCategory category) async {
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder: (context) => CategoryDetailsScreen(category: category),
      ),
    );
    if (!mounted || result == null || category.isBuiltIn) return;

    try {
      if (result == 'deleted') {
        if (category.isDiscount) {
          await _catalogController.deleteDiscount(category.id);
        } else {
          await _catalogController.deleteCategory(category.id);
        }
      } else if (result is CatalogCategory) {
        if (result.isDiscount) {
          await _catalogController.updateDiscount(result);
        } else {
          await _catalogController.updateCategory(result);
        }
      }
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Catalog update failed: $error')));
  }

  void _selectTab(int tabIndex) {
    if (_selectedTabIndex == tabIndex) return;

    setState(() {
      _selectedTabIndex = tabIndex;
      if (tabIndex == 0) {
        _itemsStream = _catalogController.watchItems();
      } else {
        _categoriesStream = _catalogController.watchCategoriesAndDiscounts();
      }
    });
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
                          onTap: () => _selectTab(0),
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
                          onTap: () => _selectTab(1),
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

                if (_selectedTabIndex == 0)
                  StreamBuilder<List<CatalogItem>>(
                    stream: _itemsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _CatalogLoadError(error: snapshot.error!);
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ItemCatalogSubview(
                        items: snapshot.data!,
                        isGridView: _isGridView,
                        onAddItem: _openAddItem,
                        onItemTap: _openItemDetails,
                      );
                    },
                  )
                else
                  StreamBuilder<List<CatalogCategory>>(
                    stream: _categoriesStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _CatalogLoadError(error: snapshot.error!);
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return CategoryCatalogSubview(
                        categories: snapshot.data!,
                        isGridView: _isGridView,
                        onAddDiscount: _openAddDiscount,
                        onAddCategory: _openAddCategory,
                        onCategoryTap: _openCategoryDetails,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogLoadError extends StatelessWidget {
  final Object error;

  const _CatalogLoadError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'Unable to load catalog: $error',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.secondary[600]),
      ),
    );
  }
}
