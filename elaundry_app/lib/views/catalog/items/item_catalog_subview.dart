import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/catalog_models.dart';
import '../../../shared/empty_states.dart';
import '../../../shared/media_picker.dart';

bool _hasMachineTag(String machineType) {
  final value = machineType.trim();
  return value.isNotEmpty && value.toLowerCase() != 'none';
}

class ItemCatalogSubview extends StatelessWidget {
  final List<CatalogItem> items;
  final bool isGridView;
  final VoidCallback onAddItem;
  final ValueChanged<CatalogItem> onItemTap;

  const ItemCatalogSubview({
    super.key,
    required this.items,
    required this.isGridView,
    required this.onAddItem,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onAddItem,
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
              label: const Text('Add Item', style: TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (items.isEmpty)
          SizedBox(
            height: MediaQuery.sizeOf(context).height - 280,
            child: Center(
              child: EmptyState(
                icon: Icons.sell_outlined,
                title: 'No Items Yet',
                description:
                    'Add an item to start building your laundry catalog.',
                actionLabel: 'Add Item',
                onAction: onAddItem,
              ),
            ),
          )
        else if (isGridView)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder:
                (context, index) => _ItemGridCard(
                  item: items[index],
                  onTap: () => onItemTap(items[index]),
                ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder:
                (context, index) => _ItemListCard(
                  item: items[index],
                  onTap: () => onItemTap(items[index]),
                ),
          ),
      ],
    );
  }
}

class _ItemListCard extends StatelessWidget {
  final CatalogItem item;
  final VoidCallback onTap;

  const _ItemListCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.neutral[300],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: _ItemMediaPreview(item: item),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _ItemTag(
                          label: item.serviceType,
                          color: const Color(0xFF86A8A4),
                        ),
                        if (_hasMachineTag(item.machineType)) ...[
                          const SizedBox(width: 6),
                          _ItemTag(
                            label: item.machineType.toUpperCase(),
                            color: AppColors.accent,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Capacity: ${item.capacityLabel}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary[500],
                      ),
                    ),
                    Text(
                      'Time: ${item.durationLabel}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEDEDED)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.priceLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              _ViewItemButton(onTap: onTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemGridCard extends StatelessWidget {
  final CatalogItem item;
  final VoidCallback onTap;

  const _ItemGridCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
              child: _ItemMediaPreview(item: item),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          if (_hasMachineTag(item.machineType)) ...[
            const SizedBox(height: 6),
            _ItemTag(label: item.machineType, color: AppColors.accent),
          ],
          Text(
            item.priceLabel,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: _ViewItemButton(onTap: onTap, compact: true),
          ),
        ],
      ),
    );
  }
}

class _ItemMediaPreview extends StatelessWidget {
  final CatalogItem item;

  const _ItemMediaPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl?.trim();

    if (imageUrl == null || imageUrl.isEmpty) {
      return _fallbackIcon();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
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
      child: Icon(
        iconForName(item.iconName),
        size: 36,
        color: const Color(0xFF637371),
      ),
    );
  }
}

class _ViewItemButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool compact;

  const _ViewItemButton({required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        minimumSize: compact ? const Size(60, 26) : const Size(72, 32),
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
        ),
      ),
      child: Text(
        'View',
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: compact ? FontWeight.normal : FontWeight.w600,
        ),
      ),
    );
  }
}

class _ItemTag extends StatelessWidget {
  final String label;
  final Color color;

  const _ItemTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
