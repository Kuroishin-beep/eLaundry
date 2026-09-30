import 'package:flutter/material.dart';
import '../../../core/themes/theme.dart';
import '../../../models/employee_models.dart';
import '../../../shared/input_decoration.dart';
import '../../../shared/field_label.dart';
import '../../../shared/section_card.dart';
import 'widgets/role_permission_group.dart';
import '../../../shared/media_picker.dart';

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
  late String _iconName;
  String? _imageUrl;

  bool get _isEditing => widget.roleToEdit != null;

  @override
  void initState() {
    super.initState();
    final role = widget.roleToEdit;
    _nameController = TextEditingController(text: role?.name ?? '');
    _descController = TextEditingController(text: role?.description ?? '');
    _permissions = role?.permissions ?? const RolePermissions();
    _iconName = role?.iconName ?? 'Point of Sale';
    _imageUrl = role?.imageUrl;
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
        iconName: _iconName,
        imageUrl: _imageUrl,
        permissions: _permissions,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary[700],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 15),
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
                  SectionCard(
                    stepNumber: '1',
                    title: 'ROLE DETAILS',
                    children: [
                      const FieldLabel(label: 'ROLE NAME'),
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
                      const FieldLabel(label: 'PICK AN ICON'),
                      IconPickerField(
                        value: _iconName,
                        onChanged: (value) => setState(() => _iconName = value),
                      ),
                      const SizedBox(height: 16),
                      const FieldLabel(label: 'ROLE IMAGE'),
                      ImageUploadField(
                        folder: 'roles',
                        initialUrl: _imageUrl,
                        onChanged: (value) => _imageUrl = value,
                      ),
                      const SizedBox(height: 16),
                      const FieldLabel(label: 'ROLE DESCRIPTION'),
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
                  SectionCard(
                    stepNumber: '2',
                    title: 'ACCESS & PERMISSIONS',
                    children: [
                      RolePermissionGroup(
                        title: 'ORDERS',
                        icon: Icons.shopping_bag_outlined,
                        items: [
                          RolePermissionItem(
                            label: 'Process Payments',
                            isChecked: _permissions.processPayments,
                            onToggle:
                                (val) => setState(() {
                                  _permissions = _permissions.copyWith(
                                    processPayments: val,
                                  );
                                }),
                          ),
                          RolePermissionItem(
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
                      RolePermissionGroup(
                        title: 'CATALOG',
                        icon: Icons.inventory_2_outlined,
                        items: [
                          RolePermissionItem(
                            label: 'Manage Items',
                            isChecked: _permissions.manageItems,
                            onToggle:
                                (val) => setState(() {
                                  _permissions = _permissions.copyWith(
                                    manageItems: val,
                                  );
                                }),
                          ),
                          RolePermissionItem(
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
                      RolePermissionGroup(
                        title: 'LAUNDRY',
                        icon: Icons.local_laundry_service_outlined,
                        items: [
                          RolePermissionItem(
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
                      RolePermissionGroup(
                        title: 'SHIFT',
                        icon: Icons.alarm_rounded,
                        items: [
                          RolePermissionItem(
                            label: 'Shift Management',
                            isChecked: _permissions.shiftManagement,
                            onToggle:
                                (val) => setState(() {
                                  _permissions = _permissions.copyWith(
                                    shiftManagement: val,
                                  );
                                }),
                          ),
                          RolePermissionItem(
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
                      RolePermissionGroup(
                        title: 'ANALYTICS & REPORTS',
                        icon: Icons.analytics_outlined,
                        items: [
                          RolePermissionItem(
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
