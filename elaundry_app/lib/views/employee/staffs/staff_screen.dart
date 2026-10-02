import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../controllers/employee_controller.dart';
import '../../../models/employee_models.dart';
import '../../../shared/empty_states.dart';
import '../../../shared/search_filter_bar.dart';
import '../../../shared/staff_filter_dialog.dart';
import 'edit_staff_screen.dart';
import 'staff_details_screen.dart';

class StaffSubView extends StatefulWidget {
  final VoidCallback? onAddRole;

  const StaffSubView({super.key, this.onAddRole});

  @override
  State<StaffSubView> createState() => _StaffSubViewState();
}

class _StaffSubViewState extends State<StaffSubView> {
  final _searchController = TextEditingController();
  final _employeeController = EmployeeController();
  Set<String> _selectedRoles = {};
  bool _sortAlphabetically = false;
  List<StaffMember> _staffList = [];
  List<RoleItem> _roles = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _employeeController.watchEmployees().listen((staff) {
      if (mounted) setState(() => _staffList = staff);
    });
    _employeeController.watchRoles().listen((roles) {
      if (mounted) setState(() => _roles = roles);
    });
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
      return matchesQuery &&
          (_selectedRoles.isEmpty || _selectedRoles.contains(staff.role));
    }).toList();
  }

  Future<void> _showFilterSheet() async {
    final roles =
        _roles.map((role) => role.name).where((name) => name.isNotEmpty).toSet()
            .toList();
    final selection = await showStaffFilterDialog(
      context,
      roles: roles,
      selectedRoles: _selectedRoles,
      alphabetical: _sortAlphabetically,
    );
    if (selection == null || !mounted) return;
    setState(() {
      _selectedRoles = selection.roles;
      _sortAlphabetically = selection.alphabetical;
    });
  }

  void _navigateToAddStaff() async {
    final newStaff = await Navigator.of(context).push<StaffMember>(
      MaterialPageRoute(
        builder: (context) => EditStaffScreen(availableRoles: _roles),
      ),
    );
    if (newStaff != null) {
      try {
        await _employeeController.createEmployee(newStaff);
      } catch (error) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            'We could not create the staff member. Please try again.',
          );
        }
      }
    }
  }

  void _openStaffDetails(StaffMember staff) async {
    final updatedStaff = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (context) => StaffDetailsScreen(staff: staff)),
    );

    if (updatedStaff == 'deleted') {
      await _employeeController.deleteEmployee(staff.id);
    } else if (updatedStaff is StaffMember) {
      await _employeeController.updateEmployee(
        updatedStaff,
        previousPin: staff.pin,
        previousEmail: staff.email,
      );
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : 'EM';
  }

  List<StaffMember> get _displayedStaff {
    final staff = _filteredStaff;
    if (_sortAlphabetically) {
      staff.sort(
        (left, right) =>
            left.name.toLowerCase().compareTo(right.name.toLowerCase()),
      );
    }
    return staff;
  }

  @override
  Widget build(BuildContext context) {
    final hasNoRoles = _roles.isEmpty;
    final filteredStaff = _displayedStaff;
    if (!hasNoRoles && _staffList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CapsuleSearchFilterBar(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            onFilterTap: _showFilterSheet,
            hintText: 'Search staff or role...',
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height - 300,
            child: Center(
              child: EmptyState(
                icon: Icons.people_outline_rounded,
                title: 'No Staff Yet',
                description: 'Add staff to start managing your employees.',
                actionLabel: 'Add Staff',
                onAction: _navigateToAddStaff,
              ),
            ),
          ),
        ],
      );
    }
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
        if (!hasNoRoles) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
        ],
        if (hasNoRoles)
          SizedBox(
            height: MediaQuery.sizeOf(context).height - 300,
            child: Center(
              child: EmptyState(
                icon: Icons.badge_outlined,
                title: 'No Roles Yet',
                description: 'Create a role first before adding staff.',
                actionLabel: 'Add Role',
                onAction: widget.onAddRole,
              ),
            ),
          )
        else if (filteredStaff.isEmpty)
          SizedBox(
            height: MediaQuery.sizeOf(context).height - 300,
            child: Center(
              child: EmptyState(
                icon: Icons.people_outline_rounded,
                title: _staffList.isEmpty ? 'No Staff Yet' : 'No Staff Found',
                description:
                    _staffList.isEmpty
                        ? 'Add staff to start managing your employees.'
                        : 'Try a different search or filter.',
                actionLabel: _staffList.isEmpty ? 'Add Staff' : null,
                onAction: _staffList.isEmpty ? _navigateToAddStaff : null,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredStaff.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final member = filteredStaff[index];
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
