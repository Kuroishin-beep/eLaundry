import 'package:flutter/material.dart';
import '../../../core/themes/theme.dart';
import '../../../models/role_model.dart';
import '../../../shared/search_filter_bar.dart';
import 'edit_role_screen.dart';
import 'role_details_screen.dart';

class RoleSubView extends StatefulWidget {
  const RoleSubView({super.key});

  @override
  State<RoleSubView> createState() => _RoleSubViewState();
}

class _RoleSubViewState extends State<RoleSubView> {
  final _searchController = TextEditingController();

  final List<RoleItem> _roles = [
    const RoleItem(
      id: '1',
      name: 'Cashier',
      assignedStaffCount: 3,
      description:
          'Processes customer transactions, handles payments, and ensures accurate cash management.',
      iconName: 'Point of Sale',
      permissions: RolePermissions(
        processPayments: true,
        transactionHistory: true,
      ),
    ),
    const RoleItem(
      id: '2',
      name: 'Store Staff',
      assignedStaffCount: 0,
      description:
          'Manages washer and dryer loading, attends to customer clothing prep, and maintains store order.',
      iconName: 'Point of Sale',
      permissions: RolePermissions(manageMachines: true, manageItems: true),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RoleItem> get _filteredRoles {
    final query = _searchController.text.trim().toLowerCase();
    return _roles.where((r) => r.name.toLowerCase().contains(query)).toList();
  }

  void _navigateToAddRole() async {
    final newRole = await Navigator.of(context).push<RoleItem>(
      MaterialPageRoute(builder: (context) => const EditRoleScreen()),
    );
    if (newRole != null) {
      setState(() => _roles.add(newRole));
    }
  }

  void _openRoleDetails(RoleItem role) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (context) => RoleDetailsScreen(role: role)),
    );

    if (result == 'deleted') {
      setState(() => _roles.removeWhere((r) => r.id == role.id));
    } else if (result is RoleItem) {
      final index = _roles.indexWhere((r) => r.id == result.id);
      if (index != -1) {
        setState(() => _roles[index] = result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search & Filter
        CapsuleSearchFilterBar(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          onFilterTap: () {},
          hintText: 'Search',
        ),
        const SizedBox(height: 14),

        // Add Role Button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _navigateToAddRole,
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
            label: const Text('Add Role', style: TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(height: 14),

        // Roles Cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredRoles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final role = _filteredRoles[index];
            return InkWell(
              onTap: () => _openRoleDetails(role),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cash Register / Point of Sale Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.neutral[500]!),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.point_of_sale_rounded,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${role.name} (${role.assignedStaffCount})',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2E2E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            role.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7270),
                              height: 1.35,
                            ),
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
