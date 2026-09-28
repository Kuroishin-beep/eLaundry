import 'package:flutter/foundation.dart';

@immutable
class RolePermissions {
  // Orders
  final bool processPayments;
  final bool transactionHistory;

  // Catalog
  final bool manageItems;
  final bool manageCategory;

  // Laundry
  final bool manageMachines;

  // Shift
  final bool shiftManagement;
  final bool shiftReport;

  // Analytics & Reports
  final bool accessReport;

  const RolePermissions({
    this.processPayments = false,
    this.transactionHistory = false,
    this.manageItems = false,
    this.manageCategory = false,
    this.manageMachines = false,
    this.shiftManagement = false,
    this.shiftReport = false,
    this.accessReport = false,
  });

  RolePermissions copyWith({
    bool? processPayments,
    bool? transactionHistory,
    bool? manageItems,
    bool? manageCategory,
    bool? manageMachines,
    bool? shiftManagement,
    bool? shiftReport,
    bool? accessReport,
  }) {
    return RolePermissions(
      processPayments: processPayments ?? this.processPayments,
      transactionHistory: transactionHistory ?? this.transactionHistory,
      manageItems: manageItems ?? this.manageItems,
      manageCategory: manageCategory ?? this.manageCategory,
      manageMachines: manageMachines ?? this.manageMachines,
      shiftManagement: shiftManagement ?? this.shiftManagement,
      shiftReport: shiftReport ?? this.shiftReport,
      accessReport: accessReport ?? this.accessReport,
    );
  }

  factory RolePermissions.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const RolePermissions();
    return RolePermissions(
      processPayments: map['processPayments'] as bool? ?? false,
      transactionHistory: map['transactionHistory'] as bool? ?? false,
      manageItems: map['manageItems'] as bool? ?? false,
      manageCategory: map['manageCategory'] as bool? ?? false,
      manageMachines: map['manageMachines'] as bool? ?? false,
      shiftManagement: map['shiftManagement'] as bool? ?? false,
      shiftReport: map['shiftReport'] as bool? ?? false,
      accessReport: map['accessReport'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'processPayments': processPayments,
      'transactionHistory': transactionHistory,
      'manageItems': manageItems,
      'manageCategory': manageCategory,
      'manageMachines': manageMachines,
      'shiftManagement': shiftManagement,
      'shiftReport': shiftReport,
      'accessReport': accessReport,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RolePermissions &&
          runtimeType == other.runtimeType &&
          processPayments == other.processPayments &&
          transactionHistory == other.transactionHistory &&
          manageItems == other.manageItems &&
          manageCategory == other.manageCategory &&
          manageMachines == other.manageMachines &&
          shiftManagement == other.shiftManagement &&
          shiftReport == other.shiftReport &&
          accessReport == other.accessReport;

  @override
  int get hashCode => Object.hash(
    processPayments,
    transactionHistory,
    manageItems,
    manageCategory,
    manageMachines,
    shiftManagement,
    shiftReport,
    accessReport,
  );
}

@immutable
class RoleItem {
  final String id;
  final String name;
  final int assignedStaffCount;
  final String description;
  final String iconName;
  final RolePermissions permissions;

  const RoleItem({
    required this.id,
    required this.name,
    required this.assignedStaffCount,
    required this.description,
    this.iconName = 'Point of Sale',
    this.permissions = const RolePermissions(),
  });

  static const RoleItem empty = RoleItem(
    id: '',
    name: '',
    assignedStaffCount: 0,
    description: '',
  );

  RoleItem copyWith({
    String? id,
    String? name,
    int? assignedStaffCount,
    String? description,
    String? iconName,
    RolePermissions? permissions,
  }) {
    return RoleItem(
      id: id ?? this.id,
      name: name ?? this.name,
      assignedStaffCount: assignedStaffCount ?? this.assignedStaffCount,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      permissions: permissions ?? this.permissions,
    );
  }

  factory RoleItem.fromMap(Map<String, dynamic> map, String id) {
    return RoleItem(
      id: id,
      name: map['name'] as String? ?? '',
      assignedStaffCount: (map['assignedStaffCount'] as num?)?.toInt() ?? 0,
      description: map['description'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'Point of Sale',
      permissions: RolePermissions.fromMap(
        map['permissions'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'assignedStaffCount': assignedStaffCount,
      'description': description,
      'iconName': iconName,
      'permissions': permissions.toMap(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          assignedStaffCount == other.assignedStaffCount &&
          description == other.description &&
          iconName == other.iconName &&
          permissions == other.permissions;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    assignedStaffCount,
    description,
    iconName,
    permissions,
  );
}
