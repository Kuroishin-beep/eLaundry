import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/catalog_models.dart';

class CategoryCatalogSubview extends StatelessWidget {
  final List<CatalogCategory> categories;
  final VoidCallback onAddDiscount;
  final VoidCallback onAddCategory;
  final ValueChanged<CatalogCategory> onCategoryTap;
  final bool isGridView;

  const CategoryCatalogSubview({
    super.key,
    required this.categories,
    required this.onAddDiscount,
    required this.onAddCategory,
    required this.onCategoryTap,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: onAddDiscount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD81B60),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Discount', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onAddCategory,
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
              label: const Text('Add Category', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (isGridView)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.88,
            ),
            itemBuilder:
                (context, index) => _CategoryGridCard(
                  category: categories[index],
                  onView: () => onCategoryTap(categories[index]),
                ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder:
                (context, index) => _CategoryListCard(
                  category: categories[index],
                  onView: () => onCategoryTap(categories[index]),
                ),
          ),
      ],
    );
  }
}

class _CategoryListCard extends StatelessWidget {
  final CatalogCategory category;
  final VoidCallback onView;

  const _CategoryListCard({required this.category, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  category.isDiscount
                      ? const Color(0xFFE57B00)
                      : const Color(0xFF5E8B88),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_laundry_service_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.isDiscount
                      ? '${category.discountAmount.toStringAsFixed(2)} ${category.discountType} off, ${category.minSpendLabel}'
                      : 'Qty: ${category.quantity}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.secondary[500],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onView,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(68, 32),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'View',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGridCard extends StatelessWidget {
  final CatalogCategory category;
  final VoidCallback onView;

  const _CategoryGridCard({required this.category, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    category.isDiscount
                        ? const Color(0xFFE57B00)
                        : const Color(0xFF5E8B88),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_laundry_service_outlined,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: Color(0xFF2C2D2D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            category.isDiscount
                ? '${category.discountAmount.toStringAsFixed(2)} ${category.discountType} off, ${category.minSpendLabel}'
                : 'Qty: ${category.quantity}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppColors.secondary[500]),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onView,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(60, 28),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'View',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
