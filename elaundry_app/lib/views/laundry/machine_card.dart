import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/machine_model.dart';
import '../../../shared/media_picker.dart';

class MachineCard extends StatelessWidget {
  final MachineItem item;
  final VoidCallback onTap;

  const MachineCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.025),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.neutral[500]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.neutral[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _MachineMediaPreview(item: item),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${item.name} (${item.count})',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF2D2E2E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.tier.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MachineMediaPreview extends StatelessWidget {
  final MachineItem item;

  const _MachineMediaPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl?.trim();

    if (imageUrl == null || imageUrl.isEmpty) {
      return _fallbackIcon();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.primary[300]!, width: 4),
        ),
        child: Center(
          child: Icon(
            iconForName(item.iconName),
            size: 32,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
