import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/role_model.dart';
import '../../../shared/detail_value_box.dart';
import '../../../shared/field_label.dart';
import '../../../shared/section_card.dart';
import 'edit_role_screen.dart';
import 'widgets/role_permission_group.dart';

class RoleDetailsScreen extends StatefulWidget {
  final RoleItem role;

  const RoleDetailsScreen({super.key, required this.role});

  @override
  State<RoleDetailsScreen> createState() => _RoleDetailsScreenState();
}

class _RoleDetailsScreenState extends State<RoleDetailsScreen> {
  late RoleItem _currentRole;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.role;
  }

  void _showDeleteDialog() {
    if (_currentRole.assignedStaffCount > 0) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Cannot Remove Role',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'There are employees assigned to this role. Please reassign them to another role before deleting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: AppColors.neutral[400], height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC7C9C8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Color(0xFF333333)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Reassign',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Delete Role?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Are you sure you want to delete this role? This action cannot be undone and its assigned permissions will be permanently removed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: AppColors.neutral[400], height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC7C9C8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Color(0xFF333333)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(context).pop('deleted');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Delete Role',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      );
    }
  }

  void _navigateToEdit() async {
    final updated = await Navigator.of(context).push<RoleItem>(
      MaterialPageRoute(
        builder: (context) => EditRoleScreen(roleToEdit: _currentRole),
      ),
    );
    if (updated != null) {
      setState(() => _currentRole = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.primary[100]!;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Text(
          _currentRole.name,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222423),
          ),
        ),
        centerTitle: true,
        backgroundColor: pageBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2C2D2D),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(_currentRole),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF2C2D2D)),
            onSelected: (val) {
              if (val == 'edit') _navigateToEdit();
              if (val == 'delete') _showDeleteDialog();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Role')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete Role',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(_currentRole),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.neutral[100]!,
                      side: BorderSide(color: AppColors.secondary[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _navigateToEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ================= SECTION 1: ROLE DETAILS =================
                SectionCard(
                  stepIcon: Icons.badge_rounded,
                  title: 'ROLE DETAILS',
                  children: [
                    const FieldLabel(label: 'ROLE NAME'),

                    DetailValueBox(
                      icon: Icons.track_changes_rounded,
                      text: _currentRole.name,
                    ),

                    const SizedBox(height: 16),

                    const FieldLabel(label: 'PICK AN ICON'),

                    DetailValueBox(
                      iconWidget: const Icon(
                        Icons.point_of_sale_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      text: _currentRole.iconName,
                      hasChevron: true,
                    ),

                    const SizedBox(height: 16),

                    const FieldLabel(label: 'ROLE DESCRIPTION'),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFC7CFCE)),
                      ),
                      child: Text(
                        _currentRole.description.isEmpty
                            ? 'No description provided.'
                            : _currentRole.description,
                        style: TextStyle(
                          color:
                              _currentRole.description.isEmpty
                                  ? const Color(0xFF9EA7A6)
                                  : const Color(0xFF444645),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= SECTION 2: ACCESS & PERMISSIONS =================
                SectionCard(
                  stepIcon: Icons.key_rounded,
                  title: 'ACCESS & PERMISSIONS',
                  children: [
                    // Orders
                    RolePermissionGroup(
                      title: 'ORDERS',
                      icon: Icons.shopping_bag_outlined,
                      padding: const EdgeInsets.all(14),
                      compact: true,
                      items: [
                        RolePermissionItem(
                          label: 'Process Payments',
                          isChecked: _currentRole.permissions.processPayments,
                        ),
                        RolePermissionItem(
                          label: 'Transaction History',
                          isChecked:
                              _currentRole.permissions.transactionHistory,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Catalog
                    RolePermissionGroup(
                      title: 'CATALOG',
                      icon: Icons.inventory_2_outlined,
                      padding: const EdgeInsets.all(14),
                      compact: true,
                      items: [
                        RolePermissionItem(
                          label: 'Manage Items',
                          isChecked: _currentRole.permissions.manageItems,
                        ),
                        RolePermissionItem(
                          label: 'Manage Category',
                          isChecked: _currentRole.permissions.manageCategory,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Laundry
                    RolePermissionGroup(
                      title: 'LAUNDRY',
                      icon: Icons.local_laundry_service_outlined,
                      padding: const EdgeInsets.all(14),
                      compact: true,
                      items: [
                        RolePermissionItem(
                          label: 'Manage Machines',
                          isChecked: _currentRole.permissions.manageMachines,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Shift
                    RolePermissionGroup(
                      title: 'SHIFT',
                      icon: Icons.alarm_rounded,
                      padding: const EdgeInsets.all(14),
                      compact: true,
                      items: [
                        RolePermissionItem(
                          label: 'Shift Management',
                          isChecked: _currentRole.permissions.shiftManagement,
                        ),
                        RolePermissionItem(
                          label: 'Shift Report',
                          isChecked: _currentRole.permissions.shiftReport,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Analytics & Reports
                    RolePermissionGroup(
                      title: 'ANALYTICS & REPORTS',
                      icon: Icons.analytics_outlined,
                      padding: const EdgeInsets.all(14),
                      compact: true,
                      items: [
                        RolePermissionItem(
                          label: 'Access Report',
                          isChecked: _currentRole.permissions.accessReport,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
