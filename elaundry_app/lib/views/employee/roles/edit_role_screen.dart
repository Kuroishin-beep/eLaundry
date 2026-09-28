import 'package:flutter/material.dart';
import '../../../core/themes/theme.dart';
import '../../../models/role_model.dart';
import '../../../shared/input_decoration.dart';

class EditRoleScreen extends StatefulWidget {
  final RoleItem? roleToEdit;

  const EditRoleScreen({super.key, this.roleToEdit});

  @override
  State<EditRoleScreen> createState() => _EditRoleScreenState();
}

class _EditRoleScreenState extends State<EditRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late RolePermissions _permissions;

  bool get _isEditing => widget.roleToEdit != null;

  @override
  void initState() {
    super.initState();
    final role = widget.roleToEdit;
    _nameController = TextEditingController(text: role?.name ?? '');
    _descController = TextEditingController(text: role?.description ?? '');
    _permissions = role?.permissions ?? const RolePermissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final role = RoleItem(
        id:
            widget.roleToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        assignedStaffCount: widget.roleToEdit?.assignedStaffCount ?? 0,
        description: _descController.text.trim(),
        iconName: widget.roleToEdit?.iconName ?? 'Point of Sale',
        permissions: _permissions,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary[700],
          behavior: SnackBarBehavior.floating,
          content: Text(
            _isEditing ? 'Role updated!' : 'Role created successfully!',
          ),
        ),
      );
      Navigator.of(context).pop(role);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.primary[100]!;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Role' : 'New Role',
          style: const TextStyle(
            fontSize: 20,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SafeArea(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _isEditing ? 'Save Changes' : 'Save',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ================= CARD 1: ROLE DETAILS =================
                  _FormCard(
                    stepNumber: '1',
                    title: 'ROLE DETAILS',
                    children: [
                      const _FieldLabel(label: 'ROLE NAME'),
                      TextFormField(
                        controller: _nameController,
                        decoration: appInputDecoration(
                          hintText: 'Cashier',
                          prefixIcon: Icon(
                            Icons.track_changes_rounded,
                            size: 18,
                            color: AppColors.secondary[600],
                          ),
                        ),
                        validator:
                            (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Please enter role name'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel(label: 'PICK AN ICON'),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFC7CFCE)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sentiment_satisfied_alt_rounded,
                                size: 20,
                                color: AppColors.secondary[600],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Choose',
                                style: TextStyle(
                                  color: AppColors.secondary[400],
                                  fontSize: 13.5,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: AppColors.secondary[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel(label: 'ROLE DESCRIPTION'),
                      TextFormField(
                        controller: _descController,
                        maxLines: 4,
                        decoration: appInputDecoration(
                          hintText: 'Write your text here...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ================= CARD 2: ACCESS & PERMISSIONS =================
                  _FormCard(
                    stepNumber: '2',
                    title: 'ACCESS & PERMISSIONS',
                    children: [
                      _InteractivePermissionGroup(
                        title: 'ORDERS',
                        icon: Icons.shopping_bag_outlined,
                        items: [
                          _PermissionItemConfig(
                            label: 'Process Payments',
                            isChecked: _permissions.processPayments,
                            onToggle:
                                (val) => setState(() {
                                  _permissions = _permissions.copyWith(
                                    processPayments: val,
                                  );
                                }),
                          ),
                          _PermissionItemConfig(
                            label: 'Transaction History',
                            isChecked: _permissions.transactionHistory,
                            onToggle:
                                (val) => setState(() {
                                  _permissions = _permissions.copyWith(
                                    transactionHistory: val,
                                  );
                                }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InteractivePermissionGroup(
                        title: 'CATALOG',
                        icon: Icons.inventory_2_outlined,
                        items: [
                          _PermissionItemConfig(
                            label: 'Manage Items',
                            isChecked: _permissions.manageItems,
                            onToggle:
                                (val) => setState(() {
                                  _permissions = _permissions.copyWith(
                                    manageItems: val,
                                  );
                                }),
                          ),
                          _PermissionItemConfig(
                            label: 'Manage Category',
                            isChecked: _permissions.manageCategory,
                            onToggle:
                                (val) => setState(() {
                                  _permissions = _permissions.copyWith(
                                    manageCategory: val,
                                  );
                                }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InteractivePermissionGroup(
                        title: 'LAUNDRY',
                        icon: Icons.local_laundry_service_outlined,
                        items: [
                          _PermissionItemConfig(
                            label: 'Manage Machines',
                            isChecked: _permissions.manageMachines,
                            onToggle:
                                (val) => setState(() {
                                  _permissions = _permissions.copyWith(
                                    manageMachines: val,
                                  );
                                }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InteractivePermissionGroup(
                        title: 'SHIFT',
                        icon: Icons.alarm_rounded,
                        items: [
                          _PermissionItemConfig(
                            label: 'Shift Management',
                            isChecked: _permissions.shiftManagement,
                            onToggle:
                                (val) => setState(() {
                                  _permissions = _permissions.copyWith(
                                    shiftManagement: val,
                                  );
                                }),
                          ),
                          _PermissionItemConfig(
                            label: 'Shift Report',
                            isChecked: _permissions.shiftReport,
                            onToggle:
                                (val) => setState(() {
                                  _permissions = _permissions.copyWith(
                                    shiftReport: val,
                                  );
                                }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InteractivePermissionGroup(
                        title: 'ANALYTICS & REPORTS',
                        icon: Icons.analytics_outlined,
                        items: [
                          _PermissionItemConfig(
                            label: 'Access Report',
                            isChecked: _permissions.accessReport,
                            onToggle:
                                (val) => setState(() {
                                  _permissions = _permissions.copyWith(
                                    accessReport: val,
                                  );
                                }),
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
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final String stepNumber;
  final String title;
  final List<Widget> children;

  const _FormCard({
    required this.stepNumber,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(18),
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
                child: Text(
                  stepNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2D2D),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4A4E4D),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _PermissionItemConfig {
  final String label;
  final bool isChecked;
  final ValueChanged<bool> onToggle;

  const _PermissionItemConfig({
    required this.label,
    required this.isChecked,
    required this.onToggle,
  });
}

class _InteractivePermissionGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_PermissionItemConfig> items;

  const _InteractivePermissionGroup({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              Icon(icon, size: 16, color: const Color(0xFF4B4F4E)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D403F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE5ECEB)),
          const SizedBox(height: 6),
          ...items.map((item) {
            return InkWell(
              onTap: () => item.onToggle(!item.isChecked),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      item.isChecked
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 20,
                      color:
                          item.isChecked
                              ? (AppColors.primary[500] ?? AppColors.accent)
                              : const Color(0xFF9EA7A6),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF333534),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
