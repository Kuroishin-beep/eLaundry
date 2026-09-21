class StoreModel {
  final String id;
  final String storeName;
  final String address;
  final String pin;
  final bool notificationsEnabled;
  final DateTime? updatedAt;

  StoreModel({
    required this.id,
    this.storeName = '',
    this.address = '',
    this.pin = '',
    this.notificationsEnabled = true,
    this.updatedAt,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map, String id) {
    return StoreModel(
      id: id,
      storeName: map['storeName'] ?? '',
      address: map['address'] ?? '',
      pin: map['pin'] ?? '',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as dynamic).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeName': storeName,
      'address': address,
      'pin': pin,
      'notificationsEnabled': notificationsEnabled,
      'updatedAt': DateTime.now(),
    };
  }
}
