import 'package:flutter/foundation.dart';

class StaffMember {
  final String id;
  final String name;
  final String role;
  final bool isClockedIn;
  final String lastClockTime;
  final String pin;
  final String email;
  final String contactNumber;
  final String startDate;
  final String totalSales;
  final int attendanceDays;
  final String note;
  final String? imageUrl;

  const StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.isClockedIn,
    required this.lastClockTime,
    required this.pin,
    required this.email,
    required this.contactNumber,
    required this.startDate,
    this.totalSales = '₱0.00',
    this.attendanceDays = 0,
    this.note = '',
    this.imageUrl,
  });

  StaffMember copyWith({
    String? id,
    String? name,
    String? role,
    bool? isClockedIn,
    String? lastClockTime,
    String? pin,
    String? email,
    String? contactNumber,
    String? startDate,
    String? totalSales,
    int? attendanceDays,
    String? note,
    String? imageUrl,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isClockedIn: isClockedIn ?? this.isClockedIn,
      lastClockTime: lastClockTime ?? this.lastClockTime,
      pin: pin ?? this.pin,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      startDate: startDate ?? this.startDate,
      totalSales: totalSales ?? this.totalSales,
      attendanceDays: attendanceDays ?? this.attendanceDays,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory StaffMember.fromMap(Map<String, dynamic> map, String id) {
    return StaffMember(
      id: id,
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? '',
      isClockedIn: map['is_clocked_in'] as bool? ?? false,
      lastClockTime: map['last_clock_time'] as String? ?? '',
      pin: map['pin'] as String? ?? '',
      email: map['email'] as String? ?? '',
      contactNumber: map['contact_number'] as String? ?? '',
      startDate: map['start_date'] as String? ?? '',
      totalSales: map['total_sales'] as String? ?? '₱0.00',
      attendanceDays: (map['attendance_days'] as num?)?.toInt() ?? 0,
      note: map['note'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'role': role,
    'is_clocked_in': isClockedIn,
    'last_clock_time': lastClockTime,
    'pin': pin,
    'email': email,
    'contact_number': contactNumber,
    'start_date': startDate,
    'total_sales': totalSales,
    'attendance_days': attendanceDays,
    'note': note,
    'imageUrl': imageUrl,
  };
}

@immutable
class RolePermissions {
  final bool processPayments;
  final bool transactionHistory;
  final bool manageItems;
  final bool manageCategory;
  final bool manageMachines;
  final bool shiftManagement;
  final bool shiftReport;
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

  Map<String, dynamic> toMap() => {
    'processPayments': processPayments,
    'transactionHistory': transactionHistory,
    'manageItems': manageItems,
    'manageCategory': manageCategory,
    'manageMachines': manageMachines,
    'shiftManagement': shiftManagement,
    'shiftReport': shiftReport,
    'accessReport': accessReport,
  };

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
  final String? imageUrl;

  const RoleItem({
    required this.id,
    required this.name,
    required this.assignedStaffCount,
    required this.description,
    this.iconName = 'Point of Sale',
    this.permissions = const RolePermissions(),
    this.imageUrl,
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
    String? imageUrl,
  }) {
    return RoleItem(
      id: id ?? this.id,
      name: name ?? this.name,
      assignedStaffCount: assignedStaffCount ?? this.assignedStaffCount,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      permissions: permissions ?? this.permissions,
      imageUrl: imageUrl ?? this.imageUrl,
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
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'assignedStaffCount': assignedStaffCount,
    'description': description,
    'iconName': iconName,
    'permissions': permissions.toMap(),
    'imageUrl': imageUrl,
  };

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
