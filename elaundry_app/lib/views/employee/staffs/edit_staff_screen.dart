import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/themes/theme.dart';
import '../../../models/staff_model.dart';
import '../../../shared/input_decoration.dart';

class EditStaffScreen extends StatefulWidget {
  final StaffMember? staffToEdit;

  const EditStaffScreen({super.key, this.staffToEdit});

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  late final TextEditingController _pinController;
  late final TextEditingController _emailController;
  late final TextEditingController _contactController;

  String _selectedRole = 'Cashier';
  final List<String> _roles = ['Cashier', 'Store Staff', 'Supervisor', 'Admin'];

  bool get _isEditing => widget.staffToEdit != null;

  @override
  void initState() {
    super.initState();
    final staff = widget.staffToEdit;
    _nameController = TextEditingController(text: staff?.name ?? '');
    _noteController = TextEditingController(text: staff?.note ?? '');
    _pinController = TextEditingController(text: staff?.pin ?? '');
    _emailController = TextEditingController(text: staff?.email ?? '');
    _contactController = TextEditingController(
      text: staff?.contactNumber ?? '',
    );
    if (staff != null && _roles.contains(staff.role)) {
      _selectedRole = staff.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _pinController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final updatedOrNew = StaffMember(
        id:
            widget.staffToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        role: _selectedRole,
        isClockedIn: widget.staffToEdit?.isClockedIn ?? false,
        lastClockTime:
            widget.staffToEdit?.lastClockTime ?? '08/21/2026 – 08:00 AM',
        pin: _pinController.text.trim(),
        email: _emailController.text.trim(),
        contactNumber: _contactController.text.trim(),
        startDate: widget.staffToEdit?.startDate ?? 'August 21, 2026',
        totalSales: widget.staffToEdit?.totalSales ?? '₱0.00',
        attendanceDays: widget.staffToEdit?.attendanceDays ?? 0,
        note: _noteController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary[700],
          behavior: SnackBarBehavior.floating,
          content: Text(
            _isEditing
                ? 'Staff details updated!'
                : 'Staff created successfully!',
          ),
        ),
      );

      Navigator.of(context).pop(updatedOrNew);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.primary[100]!;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Staff' : 'New Staff',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222423),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.secondary[900],
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 1. BASIC INFORMATION ---
                    _SectionCard(
                      stepNumber: '1',
                      stepTitle: 'BASIC INFORMATION',
                      children: [
                        // Image Upload Area
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.neutral[500]!),
                          ),
                          child: Column(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: AppColors.neutral[600]!,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.file_upload_outlined,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Upload Image',
                                  style: TextStyle(color: Color(0xFF2B2D2C)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Choose an image',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondary[600],
                                ),
                              ),
                              Text(
                                'JPG, JPEG, PNG, WEBP',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.secondary[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Name
                        const _Label(label: 'EMPLOYEE NAME'),
                        TextFormField(
                          controller: _nameController,
                          decoration: appInputDecoration(
                            hintText: 'Juan Dela Cruz',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              size: 20,
                            ),
                          ),
                          validator:
                              (val) =>
                                  val == null || val.trim().isEmpty
                                      ? 'Please enter name'
                                      : null,
                        ),
                        const SizedBox(height: 14),

                        // Role
                        const _Label(label: 'ROLE'),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          items:
                              _roles
                                  .map(
                                    (r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => _selectedRole = val!),
                          decoration: appInputDecoration(
                            prefixIcon: Icon(
                              Icons.work_outline_rounded,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Note
                        const _Label(label: 'NOTE'),
                        TextFormField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: appInputDecoration(
                            hintText: 'Write your text here...',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 2. SECURITY & SIGN-IN ---
                    _SectionCard(
                      stepNumber: '2',
                      stepTitle: 'SECURITY & SIGN-IN',
                      children: [
                        const _Label(label: 'SECURITY PIN (NUMPAD ONLY)'),
                        TextFormField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          obscureText: true,
                          decoration: appInputDecoration(
                            hintText: '••••',
                            prefixIcon: const Icon(
                              Icons.dialpad_rounded,
                              size: 20,
                            ),
                          ).copyWith(counterText: ''),
                          validator:
                              (val) =>
                                  val != null && val.length == 4
                                      ? null
                                      : 'Requires a 4-digit PIN',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 3. CONTACT DETAILS ---
                    _SectionCard(
                      stepNumber: '3',
                      stepTitle: 'CONTACT DETAILS',
                      children: [
                        const _Label(label: 'EMAIL ADDRESS'),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: appInputDecoration(
                            hintText: 'employee@elaundry.ph',
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              size: 20,
                            ),
                          ),
                          validator:
                              (val) =>
                                  val != null && val.contains('@')
                                      ? null
                                      : 'Valid email required',
                        ),
                        const SizedBox(height: 14),
                        const _Label(label: 'CONTACT NUMBER'),
                        TextFormField(
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          decoration: appInputDecoration(
                            hintText: '+63 987 123 4560',
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(_isEditing ? 'Save Changes' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String stepNumber;
  final String stepTitle;
  final List<Widget> children;

  const _SectionCard({
    required this.stepNumber,
    required this.stepTitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
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
                stepTitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF454746),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;

  const _Label({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.secondary[700],
        ),
      ),
    );
  }
}
