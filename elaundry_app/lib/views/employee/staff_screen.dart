import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../models/staff_model.dart';
import '../../shared/widgets/search_filter_bar.dart';
import '../../shared/widgets/laundry_navigation_fab.dart';
import 'edit_staff_screen.dart';
import 'staff_details_screen.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _searchController = TextEditingController();
  int _selectedTabIndex = 0; // 0 for Staff, 1 for Roles
  String _selectedFilter = 'All';

  final List<StaffMember> _staffList = [
    const StaffMember(
      id: '1',
      name: 'Juan Dela Cruz',
      role: 'Cashier',
      isClockedIn: true,
      lastClockTime: '08/21/2026 – 10:00 AM',
      pin: '1234',
      email: 'juandlc@gmail.com',
      contactNumber: '+63 987 123 4560',
      startDate: 'August 1, 2026',
      totalSales: '₱5,232.00',
      attendanceDays: 15,
      note: 'Assigned to morning cash shifts.',
    ),
    const StaffMember(
      id: '2',
      name: 'Maria Santos',
      role: 'Cashier',
      isClockedIn: false,
      lastClockTime: '08/21/2026 – 10:00 AM',
      pin: '5678',
      email: 'maria.santos@gmail.com',
      contactNumber: '+63 912 345 6789',
      startDate: 'July 15, 2026',
      totalSales: '₱12,450.00',
      attendanceDays: 28,
      note: 'Senior floor supervisor.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StaffMember> get _filteredStaff {
    return _staffList.where((staff) {
      final matchesQuery =
          staff.name.toLowerCase().contains(
            _searchController.text.toLowerCase().trim(),
          ) ||
          staff.role.toLowerCase().contains(
            _searchController.text.toLowerCase().trim(),
          );
      if (_selectedFilter == 'Active') {
        return matchesQuery && staff.isClockedIn;
      }
      if (_selectedFilter == 'Inactive') {
        return matchesQuery && !staff.isClockedIn;
      }
      return matchesQuery;
    }).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Staff Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary[900],
                  ),
                ),
                const SizedBox(height: 16),
                ...['All', 'Active', 'Inactive'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      filter,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.secondary[800],
                      ),
                    ),
                    trailing:
                        isSelected
                            ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                            )
                            : null,
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigateToAddStaff() async {
    final newStaff = await Navigator.of(context).push<StaffMember>(
      MaterialPageRoute(builder: (context) => const EditStaffScreen()),
    );

    if (newStaff != null) {
      setState(() => _staffList.add(newStaff));
    }
  }

  void _openStaffDetails(StaffMember staff) async {
    final updatedStaff = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (context) => StaffDetailsScreen(staff: staff)),
    );

    if (updatedStaff == 'deleted') {
      setState(() => _staffList.removeWhere((s) => s.id == staff.id));
    } else if (updatedStaff is StaffMember) {
      final index = _staffList.indexWhere((s) => s.id == updatedStaff.id);
      if (index != -1) {
        setState(() => _staffList[index] = updatedStaff);
      }
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : 'EM';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral[400],
      appBar: AppBar(
        title: Text(
          'Employee',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary[900],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const LaundryNavigationFab(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Segmented Switcher (Staff / Roles)
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  _selectedTabIndex == 0
                                      ? AppColors.neutral[200]
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Staff',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color:
                                    _selectedTabIndex == 0
                                        ? AppColors.secondary[900]
                                        : AppColors.secondary[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.neutral[400],
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  _selectedTabIndex == 1
                                      ? AppColors.neutral[200]
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Roles',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color:
                                    _selectedTabIndex == 1
                                        ? AppColors.secondary[900]
                                        : AppColors.secondary[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                CapsuleSearchFilterBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  onFilterTap: _showFilterSheet,
                  hintText: 'Search staff or role...',
                ),
                const SizedBox(height: 14),

                // Add Staff Button & Status Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_selectedFilter != 'All')
                      Chip(
                        label: Text(
                          _selectedFilter,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        deleteIcon: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        onDeleted:
                            () => setState(() => _selectedFilter = 'All'),
                        backgroundColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )
                    else
                      const SizedBox.shrink(),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _navigateToAddStaff,
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
                      label: const Text(
                        'Add Staff',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Staff List Cards
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredStaff.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = _filteredStaff[index];
                    return InkWell(
                      onTap: () => _openStaffDetails(member),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
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
                            // Circular Initials Avatar
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: const Color(0xFF2C2D2D),
                              child: Text(
                                _getInitials(member.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Employee Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        member.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF2D2E2E),
                                        ),
                                      ),
                                      // Attendance Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              member.isClockedIn
                                                  ? AppColors.success
                                                  : AppColors.accent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          member.isClockedIn
                                              ? 'Active'
                                              : 'Inactive',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.5,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        member.role,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.secondary[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        member.lastClockTime,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.secondary[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
