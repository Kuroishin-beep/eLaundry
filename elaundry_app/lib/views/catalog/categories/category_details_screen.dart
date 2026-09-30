import 'package:flutter/material.dart';

import '../../../../core/themes/theme.dart';
import '../../../../models/catalog_models.dart';
import '../../../../shared/field_label.dart';
import '../widgets/icon_section_card.dart';
import 'edit_category_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final CatalogCategory category;

  const CategoryDetailsScreen({super.key, required this.category});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  late CatalogCategory _currentCategory;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category;
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Delete Category?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2D2D),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete "${_currentCategory.name}"? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.secondary[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: AppColors.neutral[400], height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC7C9C8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF333333)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).pop('deleted');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                            ),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _navigateToEdit() async {
    final updated = await Navigator.of(context).push<CatalogCategory>(
      MaterialPageRoute(
        builder:
            (context) => EditCategoryScreen(categoryToEdit: _currentCategory),
      ),
    );

    if (updated != null) {
      setState(() => _currentCategory = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.primary[100]!;

    final noteDisplay =
        _currentCategory.note.trim().isEmpty
            ? 'No additional notes provided.'
            : _currentCategory.note;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: const Text(
          'Category Details',
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
          onPressed: () => Navigator.of(context).pop(_currentCategory),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.secondary[900],
            ),
            onSelected: (val) {
              if (val == 'edit') _navigateToEdit();
              if (val == 'delete') _showDeleteDialog();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit Category'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete Category',
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: pageBgColor,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed:
                        () => Navigator.of(context).pop(_currentCategory),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppColors.neutral[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _navigateToEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Edit',
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
                  // --- 1. BASIC INFORMATION ---
                  IconSectionCard(
                    icon: Icons.category_rounded,
                    title: 'BASIC INFORMATION',
                    children: [
                      const FieldLabel(
                        label: 'CATEGORY NAME',
                        letterSpacing: 0,
                      ),
                      _ReadOnlyFieldBox(
                        icon: Icons.label_outline_rounded,
                        value:
                            _currentCategory.name.isEmpty
                                ? 'None'
                                : _currentCategory.name,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- 2. INVENTORY & DETAILS ---
                  IconSectionCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'INVENTORY & DETAILS',
                    children: [
                      const FieldLabel(label: 'QUANTITY', letterSpacing: 0),
                      _ReadOnlyFieldBox(
                        icon: Icons.dialpad_rounded,
                        value: '${_currentCategory.quantity}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- 3. OPTIONAL ---
                  IconSectionCard(
                    icon: Icons.note_alt_outlined,
                    title: 'OPTIONAL',
                    children: [
                      const FieldLabel(label: 'NOTES', letterSpacing: 0),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 70),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.neutral[500]!),
                        ),
                        child: Text(
                          noteDisplay,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                _currentCategory.note.trim().isEmpty
                                    ? AppColors.secondary[300]
                                    : const Color(0xFF2C2D2D),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyFieldBox extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ReadOnlyFieldBox({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral[500]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.secondary[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF2C2D2D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
