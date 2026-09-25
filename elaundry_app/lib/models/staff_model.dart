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
    );
  }
}
