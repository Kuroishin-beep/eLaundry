import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/catalog_models.dart';
import 'edit_item_screen.dart';
import 'item_details_screen.dart';

class ItemCatalogSubview extends StatelessWidget {
  final List<CatalogItem> items;
  final bool isGridView;
  final VoidCallback onAddItem;

  const ItemCatalogSubview({
    super.key,
    required this.items,
    required this.isGridView,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        if (isGridView)
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
            itemBuilder: (context, index) => _ItemGridCard(item: items[index]),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _ItemListCard(item: items[index]),
          ),
      ],
    );
  }
}

class _ItemListCard extends StatelessWidget {
  final CatalogItem item;

  const _ItemListCard({required this.item});

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
                child: const Center(
                  child: Icon(
                    Icons.local_laundry_service_rounded,
                    size: 36,
                    color: Color(0xFF637371),
                  ),
                ),
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
                        const SizedBox(width: 6),
                        _ItemTag(label: item.tier, color: AppColors.accent),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Capacity: ${item.capacity}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary[500],
                      ),
                    ),
                    Text(
                      'Time: ${item.duration}',
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
                item.price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              _ViewItemButton(item: item),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemGridCard extends StatelessWidget {
  final CatalogItem item;

  const _ItemGridCard({required this.item});

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
              child: const Center(
                child: Icon(
                  Icons.local_laundry_service_rounded,
                  size: 36,
                  color: Color(0xFF637371),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          Text(
            item.price,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: _ViewItemButton(item: item, compact: true),
          ),
        ],
      ),
    );
  }
}

class _ViewItemButton extends StatelessWidget {
  final CatalogItem item;
  final bool compact;

  const _ViewItemButton({required this.item, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(item: item),
          ),
        );
      },
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
