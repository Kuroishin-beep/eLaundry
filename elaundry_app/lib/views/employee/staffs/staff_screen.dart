import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/staff_model.dart';
import '../../../shared/search_filter_bar.dart';
import '../../../shared/laundry_navigation_fab.dart';
import 'edit_staff_screen.dart';
import 'staff_details_screen.dart';

class StaffSubView extends StatefulWidget {
  const StaffSubView({super.key});

  @override
  State<StaffSubView> createState() => _StaffSubViewState();
}

class _StaffSubViewState extends State<StaffSubView> {
  final _searchController = TextEditingController();
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
      if (_selectedFilter == 'Clocked In')
        return matchesQuery && staff.isClockedIn;
      if (_selectedFilter == 'Clocked Out')
        return matchesQuery && !staff.isClockedIn;
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
                ...['All', 'Clocked In', 'Clocked Out'].map((filter) {
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

  void _navigateToAddStaff() async {
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
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : 'EM';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CapsuleSearchFilterBar(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          onFilterTap: _showFilterSheet,
          hintText: 'Search staff or role...',
        ),
        const SizedBox(height: 14),
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
                onDeleted: () => setState(() => _selectedFilter = 'All'),
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
              label: const Text('Add Staff', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 14),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D2E2E),
                                ),
                              ),
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  member.isClockedIn
                                      ? 'CLOCKED IN'
                                      : 'CLOCKED OUT',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }
}
