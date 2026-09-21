class StoreModel {
  final String id; // Matches the owner's userId
  final String storeName;
  final String address;
  final String pin;
  final bool notificationsEnabled;
  final DateTime? updatedAt;

  StoreModel({
    required this.id,
    required this.storeName,
    required this.address,
    required this.pin,
    this.notificationsEnabled = true,
    this.updatedAt,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map, String id) {
    return StoreModel(
      id: id,
      storeName: map['storeName'] ?? 'eLaundry Central Branch',
      address: map['address'] ?? 'Mabalacat Pampanga',
      pin: map['pin'] ?? '1234',
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

  StoreModel copyWith({
    String? storeName,
    String? address,
    String? pin,
    bool? notificationsEnabled,
    DateTime? updatedAt,
  }) {
    return StoreModel(
      id: id,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      pin: pin ?? this.pin,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
