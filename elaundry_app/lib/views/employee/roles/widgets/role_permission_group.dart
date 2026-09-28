import 'package:flutter/material.dart';

import '../../../../core/themes/theme.dart';

class RolePermissionItem {
  final String label;
  final bool isChecked;
  final ValueChanged<bool>? onToggle;

  const RolePermissionItem({
    required this.label,
    required this.isChecked,
    this.onToggle,
  });
}

class RolePermissionGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<RolePermissionItem> items;
  final EdgeInsetsGeometry padding;
  final bool compact;

  const RolePermissionGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    this.padding = const EdgeInsets.all(12),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E7E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF4B4F4E)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D403F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: compact ? const Color(0xFFE8ECEC) : const Color(0xFFE5ECEB),
          ),
          SizedBox(height: compact ? 8 : 6),
          ...items.map(_buildItem),
        ],
      ),
    );
  }

  Widget _buildItem(RolePermissionItem item) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            item.isChecked
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            size: compact ? 18 : 20,
            color:
                item.isChecked
                    ? (AppColors.primary[500] ?? AppColors.accent)
                    : const Color(0xFF9EA7A6),
          ),
          SizedBox(width: compact ? 8 : 10),
          Text(
            item.label,
            style: TextStyle(
              fontSize: compact ? 12 : 12.5,
              fontWeight:
                  compact && item.isChecked ? FontWeight.w600 : FontWeight.w400,
              color: const Color(0xFF333534),
            ),
          ),
        ],
      ),
    );

    if (item.onToggle == null) return row;

    return InkWell(
      onTap: () => item.onToggle!(!item.isChecked),
      borderRadius: BorderRadius.circular(4),
      child: row,
    );
  }
}
