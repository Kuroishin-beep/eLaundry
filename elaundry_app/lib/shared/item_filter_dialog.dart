import 'package:flutter/material.dart';

import '../core/themes/theme.dart';

class ItemFilterSelection {
  final Set<String> categories;
  final bool alphabetical;

  const ItemFilterSelection({
    required this.categories,
    required this.alphabetical,
  });
}

Future<ItemFilterSelection?> showItemFilterDialog(
  BuildContext context, {
  required List<String> categories,
  required Set<String> selectedCategories,
  required bool alphabetical,
}) {
  return showDialog<ItemFilterSelection>(
    context: context,
    builder: (dialogContext) {
      final checkedCategories = {...selectedCategories};
      var sortAlphabetically = alphabetical;
      return StatefulBuilder(
        builder:
            (context, setState) => AlertDialog(
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
                      'Filter items',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2D2D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...categories.map(
                      (category) => CheckboxListTile(
                        value: checkedCategories.contains(category),
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.accent,
                        dense: true,
                        title: Text(category),
                        onChanged:
                            (checked) => setState(() {
                              if (checked == true) {
                                checkedCategories.add(category);
                              } else {
                                checkedCategories.remove(category);
                              }
                            }),
                      ),
                    ),
                    CheckboxListTile(
                      value: sortAlphabetically,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.accent,
                      dense: true,
                      title: const Text('Name (A-Z)'),
                      onChanged:
                          (checked) => setState(
                            () => sortAlphabetically = checked ?? false,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Divider(color: AppColors.neutral[400], height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterButton(
                            label: 'Cancel',
                            backgroundColor: const Color(0xFFC7C9C8),
                            foregroundColor: const Color(0xFF333333),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FilterButton(
                            label: 'Apply',
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            onPressed:
                                () => Navigator.of(dialogContext).pop(
                                  ItemFilterSelection(
                                    categories: checkedCategories,
                                    alphabetical: sortAlphabetically,
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
    },
  );
}

class _FilterButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const _FilterButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ),
  );
}
