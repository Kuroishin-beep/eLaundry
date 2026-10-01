import 'package:flutter/material.dart';

import '../core/themes/theme.dart';

enum RoleSortOption { nameAscending, quantityAscending, quantityDescending }

Future<RoleSortOption?> showRoleFilterDialog(
  BuildContext context, {
  required RoleSortOption selected,
}) {
  return showDialog<RoleSortOption>(
    context: context,
    builder: (dialogContext) {
      var selectedOption = selected;
      const options = [
        (RoleSortOption.nameAscending, 'Name (A-Z)'),
        (RoleSortOption.quantityAscending, 'Quantity (Lowest to highest)'),
        (RoleSortOption.quantityDescending, 'Quantity (Highest to lowest)'),
      ];
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
                      'Filter roles',
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
                        'Sort by',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...options.map(
                      (option) => RadioListTile<RoleSortOption>(
                        value: option.$1,
                        groupValue: selectedOption,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.accent,
                        dense: true,
                        title: Text(option.$2),
                        onChanged:
                            (value) => setState(() {
                              if (value != null) selectedOption = value;
                            }),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(color: AppColors.neutral[400], height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleFilterButton(
                            label: 'Cancel',
                            backgroundColor: const Color(0xFFC7C9C8),
                            foregroundColor: const Color(0xFF333333),
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleFilterButton(
                            label: 'Apply',
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            onPressed: () => Navigator.of(dialogContext).pop(
                              selectedOption,
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

class _RoleFilterButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const _RoleFilterButton({
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
