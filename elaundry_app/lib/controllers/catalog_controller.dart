import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/catalog_models.dart';
import '../models/store_model.dart';
import '../services/store_context.dart';

class CatalogController {
  CatalogController({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentStoreId => currentUserId;

  Stream<List<CatalogItem>> watchItems() async* {
    final scope = await _catalogScope();
    yield* scope.items.snapshots().map(
      (snapshot) => snapshot.docs.map(_itemFromDocument).toList(),
    );
  }

  Future<List<CatalogItem>> getItems() async {
    final scope = await _catalogScope();
    final snapshot = await scope.items.get();
    return snapshot.docs.map(_itemFromDocument).toList();
  }

  Future<void> createItem(CatalogItem item) async {
    final scope = await _catalogScope();
    await _writeDocument(
      collection: scope.items,
      id: item.id,
      data: _itemToMap(item),
      isCreate: true,
    );
    await _adjustCategoryQuantity(scope.categories, item.category, 1);
  }

  Future<void> updateItem(CatalogItem item) async {
    final scope = await _catalogScope();
    final previousSnapshot = await scope.items.doc(item.id).get();
    final previousCategory = previousSnapshot.data()?['category'] as String?;
    await _writeDocument(
      collection: scope.items,
      id: item.id,
      data: _itemToMap(item),
    );
    if (_categoryKey(previousCategory) != _categoryKey(item.category)) {
      if (previousCategory != null) {
        await _adjustCategoryQuantity(scope.categories, previousCategory, -1);
      }
      await _adjustCategoryQuantity(scope.categories, item.category, 1);
    }
  }

  Future<void> deleteItem(String id) async {
    final scope = await _catalogScope();
    final itemSnapshot = await scope.items.doc(id).get();
    await _deleteDocument(collection: scope.items, id: id);
    final category = itemSnapshot.data()?['category'] as String?;
    if (category != null) {
      await _adjustCategoryQuantity(scope.categories, category, -1);
    }
  }

  Stream<List<CatalogCategory>> watchCategories() async* {
    final scope = await _catalogScope();
    await _ensureBuiltInCategories(scope.categories);
    await _syncCategoryQuantities(scope.categories, await scope.items.get());
    yield* scope.categories.snapshots().asyncMap(
      (snapshot) async => _categoriesFromSnapshots(
        categories: snapshot,
        items: await scope.items.get(),
      ),
    );
  }

  Stream<List<CatalogCategory>> watchCategoriesAndDiscounts() async* {
    final scope = await _catalogScope();
    await _ensureBuiltInCategories(scope.categories);
    await _syncCategoryQuantities(scope.categories, await scope.items.get());
    final controller = StreamController<List<CatalogCategory>>();
    QuerySnapshot<Map<String, dynamic>>? categoriesSnapshot;
    QuerySnapshot<Map<String, dynamic>>? itemsSnapshot;
    QuerySnapshot<Map<String, dynamic>>? discountsSnapshot;

    void emit() {
      if (categoriesSnapshot == null ||
          itemsSnapshot == null ||
          discountsSnapshot == null) {
        return;
      }
      controller.add(
        _categoriesFromSnapshots(
          categories: categoriesSnapshot!,
          items: itemsSnapshot!,
          discounts: discountsSnapshot,
        ),
      );
    }

    final categorySubscription = scope.categories.snapshots().listen((
      snapshot,
    ) {
      categoriesSnapshot = snapshot;
      emit();
    });
    final itemSubscription = scope.items.snapshots().listen((snapshot) {
      itemsSnapshot = snapshot;
      emit();
    });
    final discountSubscription = scope.discounts.snapshots().listen((snapshot) {
      discountsSnapshot = snapshot;
      emit();
    });

    try {
      yield* controller.stream;
    } finally {
      await categorySubscription.cancel();
      await itemSubscription.cancel();
      await discountSubscription.cancel();
      await controller.close();
    }
  }

  Future<List<CatalogCategory>> getCategories() async {
    final scope = await _catalogScope();
    await _ensureBuiltInCategories(scope.categories);
    await _syncCategoryQuantities(scope.categories, await scope.items.get());
    return _categoriesFromSnapshots(
      categories: await scope.categories.get(),
      items: await scope.items.get(),
    );
  }

  Future<void> createCategory(CatalogCategory category) async {
    _validateCategoryType(category, isDiscount: false);
    final scope = await _catalogScope();
    await _ensureBuiltInCategories(scope.categories);
    await _writeDocument(
      collection: scope.categories,
      id: category.id,
      data: _categoryToMap(category),
      isCreate: true,
    );
    await _removeDiscountFields(scope.categories.doc(category.id));
  }

  Future<void> updateCategory(CatalogCategory category) async {
    _validateCategoryType(category, isDiscount: false);
    final scope = await _catalogScope();
    await _writeDocument(
      collection: scope.categories,
      id: category.id,
      data: _categoryToMap(category),
    );
    await _removeDiscountFields(scope.categories.doc(category.id));
  }

  Future<void> deleteCategory(String id) async {
    final scope = await _catalogScope();
    await _deleteDocument(collection: scope.categories, id: id);
  }

  Stream<List<CatalogCategory>> watchDiscounts() async* {
    final scope = await _catalogScope();
    yield* scope.discounts.snapshots().map(
      (snapshot) => snapshot.docs.map(_discountFromDocument).toList(),
    );
  }

  Future<List<CatalogCategory>> getDiscounts() async {
    final scope = await _catalogScope();
    final snapshot = await scope.discounts.get();
    return snapshot.docs.map(_discountFromDocument).toList();
  }

  Future<void> createDiscount(CatalogCategory discount) async {
    _validateCategoryType(discount, isDiscount: true);
    final scope = await _catalogScope();
    await _writeDocument(
      collection: scope.discounts,
      id: discount.id,
      data: _discountToMap(discount),
      isCreate: true,
    );
  }

  Future<void> updateDiscount(CatalogCategory discount) async {
    _validateCategoryType(discount, isDiscount: true);
    final scope = await _catalogScope();
    await _writeDocument(
      collection: scope.discounts,
      id: discount.id,
      data: _discountToMap(discount),
    );
  }

  Future<void> deleteDiscount(String id) async {
    final scope = await _catalogScope();
    await _deleteDocument(collection: scope.discounts, id: id);
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
      items: storeReference.collection('catalogItem'),
      categories: storeReference.collection('catalogCategories'),
      discounts: storeReference.collection('catalogDiscount'),
    );
  }

  Future<void> _ensureBuiltInCategories(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final batch = _firestore.batch();
    for (final category in builtInCatalogCategories) {
      batch.set(collection.doc(category.id), {
        ..._categoryToMap(category),
        'updatedAt': FieldValue.serverTimestamp(),
        ..._discountFieldDeletes,
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> _removeDiscountFields(
    DocumentReference<Map<String, dynamic>> document,
  ) => document.update(_discountFieldDeletes);

  Future<void> _adjustCategoryQuantity(
    CollectionReference<Map<String, dynamic>> categories,
    String categoryName,
    int delta,
  ) async {
    final categoryReference = await _categoryReference(
      categories,
      categoryName,
    );
    await categoryReference.update({
      'quantity': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _syncCategoryQuantities(
    CollectionReference<Map<String, dynamic>> categories,
    QuerySnapshot<Map<String, dynamic>> items,
  ) async {
    final counts = <String, int>{};
    for (final item in items.docs) {
      final category = item.data()['category'];
      if (category is String && category.trim().isNotEmpty) {
        final key = _categoryKey(category);
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    final categorySnapshot = await categories.get();
    final batch = _firestore.batch();
    for (final category in categorySnapshot.docs) {
      final name = category.data()['name'];
      if (name is! String) continue;
      batch.update(category.reference, {
        'quantity': counts[_categoryKey(name)] ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    if (categorySnapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> _categoryReference(
    CollectionReference<Map<String, dynamic>> categories,
    String categoryName,
  ) async {
    final normalizedName = categoryName.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(
        categoryName,
        'categoryName',
        'An item category is required.',
      );
    }

    final builtInCategory = builtInCatalogCategories.where(
      (category) => category.name.toLowerCase() == normalizedName.toLowerCase(),
    );
    if (builtInCategory.isNotEmpty) {
      return categories.doc(builtInCategory.first.id);
    }

    final snapshot =
        await categories
            .where('name', isEqualTo: normalizedName)
            .limit(1)
            .get();
    if (snapshot.docs.isEmpty) {
      throw StateError('Category "$normalizedName" does not exist.');
    }
    return snapshot.docs.first.reference;
  }

  String _categoryKey(String? category) => category?.trim().toLowerCase() ?? '';

  static final _discountFieldDeletes = <String, dynamic>{
    'minSpend': FieldValue.delete(),
    'discountAmount': FieldValue.delete(),
    'discountType': FieldValue.delete(),
    'isDiscount': FieldValue.delete(),
  };

  Future<void> _writeDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String id,
    required Map<String, dynamic> data,
    bool isCreate = false,
  }) async {
    _validateId(id);
    data.addAll({'id': id, 'updatedAt': FieldValue.serverTimestamp()});
    if (isCreate) data['createdAt'] = FieldValue.serverTimestamp();

    await collection
        .doc(id)
        .set(data, isCreate ? null : SetOptions(merge: true));
  }

  Future<void> _deleteDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String id,
  }) async {
    _validateId(id);
    await collection.doc(id).delete();
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

  List<CatalogCategory> _categoriesFromSnapshots({
    required QuerySnapshot<Map<String, dynamic>> categories,
    required QuerySnapshot<Map<String, dynamic>> items,
    QuerySnapshot<Map<String, dynamic>>? discounts,
  }) {
    final itemCounts = <String, int>{};
    for (final document in items.docs) {
      final data = document.data();
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

    final categoryModels =
        categories.docs
            .map(_categoryFromDocument)
            .map(
              (category) => category.copyWith(
                quantity: itemCounts[category.name.trim().toLowerCase()] ?? 0,
              ),
            )
            .toList();
    final discountModels =
        (discounts?.docs ??
                const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
            .map(_categoryFromDocument)
            .toList();
    return _includeBuiltInCategories([
      ...categoryModels,
      ...discountModels,
    ], itemCounts);
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
    'iconName': item.iconName,
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
      iconName: data['iconName'] as String? ?? 'Local Laundry Service',
    );
  }

  Map<String, dynamic> _categoryToMap(CatalogCategory category) => {
    'id': category.id,
    'name': category.name,
    'quantity': category.quantity,
    'isBuiltIn': category.isBuiltIn,
    'note': category.note,
    'imageUrl': category.imageUrl,
    'iconName': category.iconName,
  };

  Map<String, dynamic> _discountToMap(CatalogCategory discount) => {
    'id': discount.id,
    'name': discount.name,
    'minSpend': discount.minSpend,
    'discountAmount': discount.discountAmount,
    'discountType': discount.discountType,
    'note': discount.note,
    'imageUrl': discount.imageUrl,
    'iconName': discount.iconName,
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
      iconName: data['iconName'] as String? ?? 'Inventory',
    );
  }

  CatalogCategory _discountFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return CatalogCategory(
      id: data['id'] as String? ?? document.id,
      name: data['name'] as String? ?? '',
      quantity: 0,
      minSpend:
          data['minSpend'] == null ? null : _numberValue(data['minSpend']),
      discountAmount: _numberValue(data['discountAmount']),
      discountType: data['discountType'] as String? ?? 'Percentage',
      isDiscount: true,
      note: data['note'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      iconName: data['iconName'] as String? ?? 'Assessment',
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
    required this.items,
    required this.categories,
    required this.discounts,
  });

  final String userId;
  final String storeId;
  final CollectionReference<Map<String, dynamic>> items;
  final CollectionReference<Map<String, dynamic>> categories;
  final CollectionReference<Map<String, dynamic>> discounts;
}
