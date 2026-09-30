class CatalogItem {
  final String id;
  final String name;
  final String category;
  final String machineType;
  final String price;
  final String capacity;
  final String duration;
  final String tier;
  final String serviceType;
  final String note;

  const CatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.machineType,
    required this.price,
    required this.capacity,
    required this.duration,
    this.tier = 'STANDARD',
    this.serviceType = 'SERVICE',
    this.note = '',
  });
}

class CatalogCategory {
  final String id;
  final String name;
  final int quantity;
  final String? minSpend;
  final bool isDiscount;
  final String note;

  const CatalogCategory({
    required this.id,
    required this.name,
    required this.quantity,
    this.minSpend,
    this.isDiscount = false,
    this.note = '',
  });
}
