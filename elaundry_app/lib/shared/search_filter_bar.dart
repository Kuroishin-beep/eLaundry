import 'package:flutter/material.dart';

import '../core/themes/theme.dart';
import 'input_decoration.dart';

class CapsuleSearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback onFilterTap;
  final String hintText;
  final bool isGridView;
  final VoidCallback? onToggleView;

  const CapsuleSearchFilterBar({
    super.key,
    required this.controller,
    required this.onFilterTap,
    this.onChanged,
    this.hintText = 'Search',
    this.isGridView = false,
    this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasToggle = onToggleView != null;

    // Corner radii specifications
    const double outerRadius =
        24.0; // Full pill rounding on the outer extremities
    const double innerRadius =
        6.0; // Subtle rounding on the interior adjacent sides

    return Row(
      children: [
        // 1. Search Box (Far Left: full rounding on left, subtle on right)
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(outerRadius),
                bottomLeft: Radius.circular(outerRadius),
                topRight: Radius.circular(innerRadius),
                bottomRight: Radius.circular(innerRadius),
              ),
              border: Border.all(color: const Color(0xFFC4C4C4), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF757575),
                    size: 20,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2C2C2C),
                      height: 1.0,
                    ),
                    decoration: appInputDecoration(hintText: hintText).copyWith(
                      hintStyle: const TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontSize: 15,
                        height: 1.0,
                      ),
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 6),

        // 2. Filter Button (Middle piece if toggle exists, or far right if not)
        Material(
          color: AppColors.primary[600],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(innerRadius),
            bottomLeft: const Radius.circular(innerRadius),
            topRight: Radius.circular(hasToggle ? innerRadius : outerRadius),
            bottomRight: Radius.circular(hasToggle ? innerRadius : outerRadius),
          ),
          child: InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(innerRadius),
              bottomLeft: const Radius.circular(innerRadius),
              topRight: Radius.circular(hasToggle ? innerRadius : outerRadius),
              bottomRight: Radius.circular(
                hasToggle ? innerRadius : outerRadius,
              ),
            ),
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.tune_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),

        // 3. Grid / List View Toggle Button (Far Right: subtle on left, full rounding on right)
        if (hasToggle) ...[
          const SizedBox(width: 6),
          Material(
            color: AppColors.primary[600],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(innerRadius),
              bottomLeft: Radius.circular(innerRadius),
              topRight: Radius.circular(outerRadius),
              bottomRight: Radius.circular(outerRadius),
            ),
            child: InkWell(
              onTap: onToggleView,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(innerRadius),
                bottomLeft: Radius.circular(innerRadius),
                topRight: Radius.circular(outerRadius),
                bottomRight: Radius.circular(outerRadius),
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  isGridView
                      ? Icons.format_list_bulleted_rounded
                      : Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
