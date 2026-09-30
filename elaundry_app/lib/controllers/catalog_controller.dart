import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/catalog_models.dart';
import '../models/store_model.dart';
import '../services/store_context.dart';

class CatalogController {
  CatalogController({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  static const _catalogCollection = 'catalog';
  static const _itemType = 'item';
  static const _categoryType = 'category';
  static const _discountType = 'discount';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentStoreId => currentUserId;

  Stream<List<CatalogItem>> watchItems() async* {
    final scope = await _catalogScope();
    yield* scope.collection
        .where('type', isEqualTo: _itemType)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_itemFromDocument).toList());
  }

  Future<List<CatalogItem>> getItems() async {
    final scope = await _catalogScope();
    final snapshot =
        await scope.collection.where('type', isEqualTo: _itemType).get();
    return snapshot.docs.map(_itemFromDocument).toList();
  }

  Future<void> createItem(CatalogItem item) async {
    final scope = await _catalogScope();
    await _writeDocument(
      scope: scope,
      type: _itemType,
      id: item.id,
      data: _itemToMap(item),
      isCreate: true,
    );
  }

  Future<void> updateItem(CatalogItem item) async {
    final scope = await _catalogScope();
    await _writeDocument(
      scope: scope,
      type: _itemType,
      id: item.id,
      data: _itemToMap(item),
    );
  }

  Future<void> deleteItem(String id) async {
    final scope = await _catalogScope();
    await _deleteDocument(scope: scope, type: _itemType, id: id);
  }

  Stream<List<CatalogCategory>> watchCategories() async* {
    final scope = await _catalogScope();
    yield* scope.collection.snapshots().map(
      (snapshot) => _categoriesFromSnapshot(snapshot),
    );
  }

  Stream<List<CatalogCategory>> watchCategoriesAndDiscounts() async* {
    final scope = await _catalogScope();
    yield* scope.collection.snapshots().map(
      (snapshot) => _categoriesFromSnapshot(snapshot, includeDiscounts: true),
    );
  }

  Future<List<CatalogCategory>> getCategories() async {
    final scope = await _catalogScope();
    final snapshot = await scope.collection.get();
    return _categoriesFromSnapshot(snapshot);
  }

  Future<void> createCategory(CatalogCategory category) async {
    _validateCategoryType(category, isDiscount: false);
    final scope = await _catalogScope();
    await _writeDocument(
      scope: scope,
      type: _categoryType,
      id: category.id,
      data: _categoryToMap(category, type: _categoryType),
      isCreate: true,
    );
  }

  Future<void> updateCategory(CatalogCategory category) async {
    _validateCategoryType(category, isDiscount: false);
    final scope = await _catalogScope();
    await _writeDocument(
      scope: scope,
      type: _categoryType,
      id: category.id,
      data: _categoryToMap(category, type: _categoryType),
    );
  }

  Future<void> deleteCategory(String id) async {
    final scope = await _catalogScope();
    await _deleteDocument(scope: scope, type: _categoryType, id: id);
  }

  Stream<List<CatalogCategory>> watchDiscounts() async* {
    final scope = await _catalogScope();
    yield* scope.collection
        .where('type', isEqualTo: _discountType)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_categoryFromDocument).toList());
  }

  Future<List<CatalogCategory>> getDiscounts() async {
    final scope = await _catalogScope();
    final snapshot =
        await scope.collection.where('type', isEqualTo: _discountType).get();
    return snapshot.docs.map(_categoryFromDocument).toList();
  }

  Future<void> createDiscount(CatalogCategory discount) async {
    _validateCategoryType(discount, isDiscount: true);
    final scope = await _catalogScope();
    await _writeDocument(
      scope: scope,
      type: _discountType,
      id: discount.id,
      data: _categoryToMap(discount, type: _discountType),
      isCreate: true,
    );
  }

  Future<void> updateDiscount(CatalogCategory discount) async {
    _validateCategoryType(discount, isDiscount: true);
    final scope = await _catalogScope();
    await _writeDocument(
      scope: scope,
      type: _discountType,
      id: discount.id,
      data: _categoryToMap(discount, type: _discountType),
    );
  }

  Future<void> deleteDiscount(String id) async {
    final scope = await _catalogScope();
    await _deleteDocument(scope: scope, type: _discountType, id: id);
  }

  Future<_CatalogScope> _catalogScope() async {
    final context =
        await StoreContextResolver(
          firestore: _firestore,
          auth: _auth,
        ).resolve();

    final storeReference = _firestore.collection('stores').doc(context.storeId);
    final storeSnapshot = await storeReference.get();
    if (!storeSnapshot.exists) {
      await storeReference.set(
        StoreModel(id: context.storeId).toMap(),
        SetOptions(merge: true),
      );
    }

    return _CatalogScope(
      userId: _auth.currentUser!.uid,
      storeId: storeReference.id,
      collection: storeReference.collection(_catalogCollection),
    );
  }

  Future<void> _writeDocument({
    required _CatalogScope scope,
    required String type,
    required String id,
    required Map<String, dynamic> data,
    bool isCreate = false,
  }) async {
    _validateId(id);
    data.addAll({
      'id': id,
      'type': type,
      'userId': scope.userId,
      'storeId': scope.storeId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (isCreate) data['createdAt'] = FieldValue.serverTimestamp();

    await scope.collection
        .doc(_documentId(type, id))
        .set(data, isCreate ? null : SetOptions(merge: true));
  }

  Future<void> _deleteDocument({
    required _CatalogScope scope,
    required String type,
    required String id,
  }) async {
    _validateId(id);
    await scope.collection.doc(_documentId(type, id)).delete();
  }

  String _documentId(String type, String id) {
    _validateId(id);
    return '${type}_$id';
  }

  void _validateCategoryType(
    CatalogCategory category, {
    required bool isDiscount,
  }) {
    if (category.isBuiltIn) {
      throw ArgumentError('Built-in catalog categories cannot be modified.');
    }
    if (category.isDiscount != isDiscount) {
      throw ArgumentError.value(
        category.isDiscount,
        'category.isDiscount',
        'Must be $isDiscount for this catalog operation.',
      );
    }
  }

  List<CatalogCategory> _categoriesFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot, {
    bool includeDiscounts = false,
  }) {
    final itemCounts = <String, int>{};
    for (final document in snapshot.docs) {
      final data = document.data();
      if (data['type'] != _itemType) continue;
      final categoryName = data['category'];
      if (categoryName is String && categoryName.trim().isNotEmpty) {
        final key = categoryName.trim().toLowerCase();
        itemCounts.update(
          key,
          (existingCount) => existingCount + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final categories =
        snapshot.docs
            .where((document) {
              final type = document.data()['type'];
              return type == _categoryType ||
                  (includeDiscounts && type == _discountType);
            })
            .map(_categoryFromDocument)
            .map(
              (category) =>
                  category.isDiscount
                      ? category
                      : category.copyWith(
                        quantity:
                            itemCounts[category.name.trim().toLowerCase()] ?? 0,
                      ),
            )
            .toList();
    return _includeBuiltInCategories(categories, itemCounts);
  }

  List<CatalogCategory> _includeBuiltInCategories(
    List<CatalogCategory> categories,
    Map<String, int> itemCounts,
  ) {
    final existingNames =
        categories
            .map((category) => category.name.trim().toLowerCase())
            .toSet();
    final builtIns = builtInCatalogCategories
        .where(
          (category) => !existingNames.contains(category.name.toLowerCase()),
        )
        .map(
          (category) => category.copyWith(
            quantity: itemCounts[category.name.toLowerCase()] ?? 0,
          ),
        );
    return [...builtIns, ...categories];
  }

  void _validateId(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Document ID cannot be empty.');
    }
  }

  Map<String, dynamic> _itemToMap(CatalogItem item) => {
    'id': item.id,
    'name': item.name,
    'category': item.category,
    'machineType': item.machineType,
    'price': item.price,
    'quantity': item.quantity,
    'minWeightKg': item.minWeightKg,
    'maxWeightKg': item.maxWeightKg,
    'durationSeconds': item.durationSeconds,
    'tier': item.tier,
    'serviceType': item.serviceType,
    'note': item.note,
    'imageUrl': item.imageUrl,
  };

  CatalogItem _itemFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final legacyWeights = _numericValues(data['capacity']);
    return CatalogItem(
      id: data['id'] as String? ?? document.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      machineType: data['machineType'] as String? ?? '',
      price: _numberValue(data['price']),
      quantity: _intValue(data['quantity'], fallback: 1),
      minWeightKg: _numberValue(
        data['minWeightKg'],
        fallback: legacyWeights.isNotEmpty ? legacyWeights.first : 0,
      ),
      maxWeightKg: _numberValue(
        data['maxWeightKg'],
        fallback: legacyWeights.length > 1 ? legacyWeights[1] : 0,
      ),
      durationSeconds: _durationSeconds(
        data['durationSeconds'] ?? data['duration'],
      ),
      tier: data['tier'] as String? ?? 'STANDARD',
      serviceType: data['serviceType'] as String? ?? 'SERVICE',
      note: data['note'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> _categoryToMap(
    CatalogCategory category, {
    required String type,
  }) => {
    'id': category.id,
    'type': type,
    'name': category.name,
    'quantity': category.quantity,
    'minSpend': category.minSpend,
    'discountAmount': category.discountAmount,
    'discountType': category.discountType,
    'isDiscount': category.isDiscount,
    'isBuiltIn': category.isBuiltIn,
    'note': category.note,
    'imageUrl': category.imageUrl,
  };

  CatalogCategory _categoryFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return CatalogCategory(
      id: data['id'] as String? ?? document.id,
      name: data['name'] as String? ?? '',
      quantity: _intValue(data['quantity']),
      minSpend:
          data['minSpend'] == null ? null : _numberValue(data['minSpend']),
      discountAmount: _numberValue(data['discountAmount']),
      discountType: data['discountType'] as String? ?? 'Percentage',
      isDiscount: data['isDiscount'] as bool? ?? false,
      isBuiltIn: data['isBuiltIn'] as bool? ?? false,
      note: data['note'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
    );
  }

  double _numberValue(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final numericText = value.replaceAll(',', '');
      final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(numericText);
      return double.tryParse(match?.group(0) ?? '') ?? fallback;
    }
    return fallback;
  }

  int _intValue(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  List<double> _numericValues(dynamic value) {
    if (value is! String) return const [];
    return RegExp(r'-?\d+(?:\.\d+)?')
        .allMatches(value.replaceAll(',', ''))
        .map((match) => double.parse(match.group(0)!))
        .toList();
  }

  int _durationSeconds(dynamic value) {
    if (value is num) return value.toInt();
    if (value is! String) return 0;

    final clock = RegExp(r'^(\d+):(\d{1,2}):(\d{1,2})$').firstMatch(value);
    if (clock != null) {
      return int.parse(clock.group(1)!) * 3600 +
          int.parse(clock.group(2)!) * 60 +
          int.parse(clock.group(3)!);
    }

    final hours = RegExp(
      r'(\d+)\s*(?:hours?|hrs?)',
      caseSensitive: false,
    ).firstMatch(value);
    final minutes = RegExp(
      r'(\d+)\s*(?:minutes?|mins?)',
      caseSensitive: false,
    ).firstMatch(value);
    final seconds = RegExp(
      r'(\d+)\s*(?:seconds?|secs?)',
      caseSensitive: false,
    ).firstMatch(value);
    if (hours != null || minutes != null || seconds != null) {
      return (int.tryParse(hours?.group(1) ?? '') ?? 0) * 3600 +
          (int.tryParse(minutes?.group(1) ?? '') ?? 0) * 60 +
          (int.tryParse(seconds?.group(1) ?? '') ?? 0);
    }
    return 0;
  }
}

class _CatalogScope {
  const _CatalogScope({
    required this.userId,
    required this.storeId,
    required this.collection,
  });

  final String userId;
  final String storeId;
  final CollectionReference<Map<String, dynamic>> collection;
}
