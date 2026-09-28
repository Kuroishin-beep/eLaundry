import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/role_model.dart';
import 'edit_role_screen.dart';

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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ROLE DETAILS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF555B5A),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const _SubLabel(label: 'ROLE NAME'),

                      _DetailBox(
                        icon: Icons.track_changes_rounded,
                        text: _currentRole.name,
                      ),
                      const SizedBox(height: 16),
                      const _SubLabel(label: 'PICK AN ICON'),
                      _DetailBox(
                        iconWidget: const Icon(
                          Icons.point_of_sale_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        text: _currentRole.iconName,
                        hasChevron: true,
                      ),
                      const SizedBox(height: 16),
                      const _SubLabel(label: 'ROLE DESCRIPTION'),
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
                            fontSize: 12.5,
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
                ),

                const SizedBox(height: 16),

                // ================= SECTION 2: ACCESS & PERMISSIONS =================
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ACCESS & PERMISSIONS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF555B5A),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Orders
                      _PermissionCard(
                        categoryTitle: 'ORDERS',
                        categoryIcon: Icons.shopping_bag_outlined,
                        items: [
                          _PermissionViewItem(
                            label: 'Process Payments',
                            isChecked: _currentRole.permissions.processPayments,
                          ),
                          _PermissionViewItem(
                            label: 'Transaction History',
                            isChecked:
                                _currentRole.permissions.transactionHistory,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Catalog
                      _PermissionCard(
                        categoryTitle: 'CATALOG',
                        categoryIcon: Icons.inventory_2_outlined,
                        items: [
                          _PermissionViewItem(
                            label: 'Manage Items',
                            isChecked: _currentRole.permissions.manageItems,
                          ),
                          _PermissionViewItem(
                            label: 'Manage Category',
                            isChecked: _currentRole.permissions.manageCategory,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Laundry
                      _PermissionCard(
                        categoryTitle: 'LAUNDRY',
                        categoryIcon: Icons.local_laundry_service_outlined,
                        items: [
                          _PermissionViewItem(
                            label: 'Manage Machines',
                            isChecked: _currentRole.permissions.manageMachines,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Shift
                      _PermissionCard(
                        categoryTitle: 'SHIFT',
                        categoryIcon: Icons.alarm_rounded,
                        items: [
                          _PermissionViewItem(
                            label: 'Shift Management',
                            isChecked: _currentRole.permissions.shiftManagement,
                          ),
                          _PermissionViewItem(
                            label: 'Shift Report',
                            isChecked: _currentRole.permissions.shiftReport,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Analytics & Reports
                      _PermissionCard(
                        categoryTitle: 'ANALYTICS & REPORTS',
                        categoryIcon: Icons.analytics_outlined,
                        items: [
                          _PermissionViewItem(
                            label: 'Access Report',
                            isChecked: _currentRole.permissions.accessReport,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionViewItem {
  final String label;
  final bool isChecked;

  const _PermissionViewItem({required this.label, required this.isChecked});
}

class _SubLabel extends StatelessWidget {
  final String label;

  const _SubLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4A4E4D),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String text;
  final bool hasChevron;

  const _DetailBox({
    this.icon,
    this.iconWidget,
    required this.text,
    this.hasChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC7CFCE)),
      ),
      child: Row(
        children: [
          iconWidget ?? Icon(icon, size: 18, color: AppColors.secondary[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF333534)),
            ),
          ),
          if (hasChevron)
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF6B7270),
            ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final String categoryTitle;
  final IconData categoryIcon;
  final List<_PermissionViewItem> items;

  const _PermissionCard({
    required this.categoryTitle,
    required this.categoryIcon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E7E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(categoryIcon, size: 16, color: const Color(0xFF4B4F4E)),
              const SizedBox(width: 8),
              Text(
                categoryTitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D403F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE8ECEC)),
          const SizedBox(height: 8),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    item.isChecked
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 18,
                    color:
                        item.isChecked
                            ? AppColors.primary[500]!
                            : const Color(0xFF9EA7A6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          item.isChecked ? FontWeight.w600 : FontWeight.w400,
                      color: const Color(0xFF333534),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
