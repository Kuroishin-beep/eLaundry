class CatalogItem {
  final String id;
  final String name;
  final String category;
  final String machineType;
  final double price;
  final int quantity;
  final double minWeightKg;
  final double maxWeightKg;
  final int durationSeconds;
  final String tier;
  final String serviceType;
  final String note;
  final String? imageUrl;

  const CatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.machineType,
    required this.price,
    this.quantity = 1,
    required this.minWeightKg,
    required this.maxWeightKg,
    required this.durationSeconds,
    this.tier = 'STANDARD',
    this.serviceType = 'SERVICE',
    this.note = '',
    this.imageUrl,
  });

  String get priceLabel => 'P${price.toStringAsFixed(2)}';

  String get capacityLabel =>
      '${_formatWeight(minWeightKg)}kg to ${_formatWeight(maxWeightKg)}kg';

  String get durationLabel {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  CatalogItem copyWith({String? imageUrl}) => CatalogItem(
    id: id,
    name: name,
    category: category,
    machineType: machineType,
    price: price,
    quantity: quantity,
    minWeightKg: minWeightKg,
    maxWeightKg: maxWeightKg,
    durationSeconds: durationSeconds,
    tier: tier,
    serviceType: serviceType,
    note: note,
    imageUrl: imageUrl ?? this.imageUrl,
  );
}

class CatalogCategory {
  final String id;
  final String name;
  final int quantity;
  final double? minSpend;
  final double discountAmount;
  final String discountType;
  final bool isDiscount;
  final bool isBuiltIn;
  final String note;
  final String? imageUrl;

  const CatalogCategory({
    required this.id,
    required this.name,
    required this.quantity,
    this.minSpend,
    this.discountAmount = 0,
    this.discountType = 'Percentage',
    this.isDiscount = false,
    this.isBuiltIn = false,
    this.note = '',
    this.imageUrl,
  });

  String get minSpendLabel =>
      minSpend == null ? '' : 'Min. Spend P${minSpend!.toStringAsFixed(2)}';

  CatalogCategory copyWith({int? quantity, String? imageUrl}) =>
      CatalogCategory(
        id: id,
        name: name,
        quantity: quantity ?? this.quantity,
        minSpend: minSpend,
        discountAmount: discountAmount,
        discountType: discountType,
        isDiscount: isDiscount,
        isBuiltIn: isBuiltIn,
        note: note,
        imageUrl: imageUrl ?? this.imageUrl,
      );
}

const builtInCatalogCategories = <CatalogCategory>[
  CatalogCategory(
    id: 'builtin-services',
    name: 'Services',
    quantity: 0,
    isBuiltIn: true,
  ),
  CatalogCategory(
    id: 'builtin-add-on',
    name: 'Add-on',
    quantity: 0,
    isBuiltIn: true,
  ),
];

String _formatWeight(double weight) =>
    weight == weight.roundToDouble()
        ? weight.toInt().toString()
        : weight.toString();
