import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/staff_model.dart';
import 'edit_staff_screen.dart';

class StaffDetailsScreen extends StatefulWidget {
  final StaffMember staff;

  const StaffDetailsScreen({super.key, required this.staff});

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  late StaffMember _currentStaff;

  static const double _avatarDiameter = 96.0;

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
    final mintBgColor = AppColors.primary[100]!;
    final topBarBgColor = AppColors.neutral[500]!;

    return Scaffold(
      backgroundColor: mintBgColor,
      appBar: AppBar(
        backgroundColor: topBarBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2C2D2D),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(_currentStaff),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF2C2D2D)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // Top half block that meets the avatar center
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // Grey background segment extending exactly down to the avatar midline
                    Container(
                      height: _avatarDiameter / 2,
                      width: double.infinity,
                      color: topBarBgColor,
                    ),
                    // Centered circular avatar
                    Positioned(
                      top: 0,
                      child: Container(
                        width: _avatarDiameter,
                        height: _avatarDiameter,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFC7DFDC), // Ring halo
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2F3130), // Dark charcoal circle
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _getInitials(_currentStaff.name),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Height offset for the bottom half of the avatar plus vertical spacing
                const SizedBox(height: (_avatarDiameter / 2) + 12),

                // Staff Name & Role
                Text(
                  _currentStaff.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2A2C2B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _currentStaff.role,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7A8785),
                  ),
                ),
                const SizedBox(height: 22),

                // Sales & Attendance Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.payments_rounded,
                          value: _currentStaff.totalSales,
                          label: 'Sales',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.work_rounded,
                          value: '${_currentStaff.attendanceDays} days',
                          label: 'Attendance',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Information Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _InfoField(
                        label: 'START DATE',
                        icon: Icons.calendar_today_outlined,
                        value: _currentStaff.startDate,
                      ),
                      const SizedBox(height: 14),
                      _InfoField(
                        label: 'EMAIL ADDRESS',
                        icon: Icons.mail_outline_rounded,
                        value: _currentStaff.email,
                      ),
                      const SizedBox(height: 14),
                      _InfoField(
                        label: 'CONTACT NUMER',
                        icon: Icons.phone_outlined,
                        value: _currentStaff.contactNumber,
                      ),
                      const SizedBox(height: 14),
                      _NotesField(label: 'NOTE', value: _currentStaff.note),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0D9488), size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF282A29),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF8F9998)),
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;

  const _InfoField({
    required this.label,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF555B5A),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF6B7270)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF333534),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesField extends StatelessWidget {
  final String label;
  final String value;

  const _NotesField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF555B5A),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: 108,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Expanded(
            child: Text(
              value.trim().isEmpty ? 'Write your text here...' : value,
              style: TextStyle(
                fontSize: 12.5,
                color:
                    value.trim().isEmpty
                        ? const Color(0xFFA5AEAD)
                        : const Color(0xFF333534),
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
