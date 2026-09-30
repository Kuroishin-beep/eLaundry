import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/employee_models.dart';
import '../../../shared/field_label.dart';
import 'edit_staff_screen.dart';
import 'widgets/staff_stat_card.dart';

class StaffDetailsScreen extends StatefulWidget {
  final StaffMember staff;

  const StaffDetailsScreen({super.key, required this.staff});

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  late StaffMember _currentStaff;

  @override
  void initState() {
    super.initState();
    _currentStaff = widget.staff;
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Deactivate Access?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Their PIN will be disabled immediately. All past sales records and reports will be retained.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.secondary[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: AppColors.neutral[400], height: 1),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC7C9C8),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogCtx).pop();
                              Navigator.of(context).pop('deleted');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Deactivate',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _navigateToEdit() async {
    final updated = await Navigator.of(context).push<StaffMember>(
      MaterialPageRoute(
        builder: (context) => EditStaffScreen(staffToEdit: _currentStaff),
      ),
    );

    if (updated != null) {
      setState(() => _currentStaff = updated);
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
    final pageBgColor = AppColors.primary[100]!;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Text(
          _currentStaff.name.isEmpty ? 'Staff Details' : _currentStaff.name,
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
          onPressed: () => Navigator.of(context).pop(_currentStaff),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.secondary[900],
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _navigateToEdit();
              } else if (value == 'deactivate') {
                _showDeactivateDialog();
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Edit Staff'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Deactivate Access',
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(_currentStaff),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppColors.neutral[600]!),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. BASIC INFORMATION ---
                  _SectionCard(
                    icon: Icons.badge_rounded,
                    title: 'BASIC INFORMATION',
                    children: [
                      // Profile Avatar
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFC7DFDC),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2F3130),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getInitials(_currentStaff.name),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sales & Attendance Cards below Profile Picture
                      Row(
                        children: [
                          Expanded(
                            child: StaffStatCard(
                              icon: Icons.payments_rounded,
                              value:
                                  _currentStaff.totalSales.isEmpty
                                      ? '₱0.00'
                                      : _currentStaff.totalSales,
                              label: 'Sales',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: StaffStatCard(
                              icon: Icons.work_rounded,
                              value: '${_currentStaff.attendanceDays} days',
                              label: 'Attendance',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const FieldLabel(
                        label: 'EMPLOYEE NAME',
                        letterSpacing: 0,
                      ),
                      _ReadOnlyBox(
                        icon: Icons.badge_outlined,
                        value:
                            _currentStaff.name.isEmpty
                                ? 'None'
                                : _currentStaff.name,
                      ),
                      const SizedBox(height: 14),

                      const FieldLabel(label: 'ROLE', letterSpacing: 0),
                      _ReadOnlyBox(
                        icon: Icons.work_outline_rounded,
                        value:
                            _currentStaff.role.isEmpty
                                ? 'None'
                                : _currentStaff.role,
                      ),
                      const SizedBox(height: 14),

                      const FieldLabel(label: 'START DATE', letterSpacing: 0),
                      _ReadOnlyBox(
                        icon: Icons.calendar_today_outlined,
                        value:
                            _currentStaff.startDate.isEmpty
                                ? 'None'
                                : _currentStaff.startDate,
                      ),
                      const SizedBox(height: 14),

                      const FieldLabel(label: 'NOTE', letterSpacing: 0),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 70),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.neutral[500]!),
                        ),
                        child: Text(
                          _currentStaff.note.trim().isEmpty
                              ? 'No additional notes provided.'
                              : _currentStaff.note,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                _currentStaff.note.trim().isEmpty
                                    ? AppColors.secondary[300]
                                    : const Color(0xFF2C2D2D),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- 2. CONTACT DETAILS ---
                  _SectionCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'CONTACT DETAILS',
                    children: [
                      const FieldLabel(
                        label: 'EMAIL ADDRESS',
                        letterSpacing: 0,
                      ),
                      _ReadOnlyBox(
                        icon: Icons.mail_outline_rounded,
                        value:
                            _currentStaff.email.isEmpty
                                ? 'None'
                                : _currentStaff.email,
                      ),
                      const SizedBox(height: 14),

                      const FieldLabel(
                        label: 'CONTACT NUMBER',
                        letterSpacing: 0,
                      ),
                      _ReadOnlyBox(
                        icon: Icons.phone_outlined,
                        value:
                            _currentStaff.contactNumber.isEmpty
                                ? 'None'
                                : _currentStaff.contactNumber,
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

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
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
                child: Icon(icon, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 8),
              Text(
                title,
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

class _ReadOnlyBox extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ReadOnlyBox({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral[500]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.secondary[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF2C2D2D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
