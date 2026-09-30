import 'package:flutter/material.dart';

import '../../controllers/shift_controller.dart';
import '../../core/themes/theme.dart';
import '../../models/shift_model.dart';
import '../../shared/laundry_navigation_fab.dart';
import './manage/manage_shift_subview.dart';
import './manage/open_shift_screen.dart';
import './reports/report_shift_subview.dart';
import './manage/shift_details_screen.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final ShiftController _shiftController = ShiftController();
  int _selectedTabIndex = 0;
  late final Future<NavigationPermissions> _permissionsFuture;

  @override
  void initState() {
    super.initState();
    _permissionsFuture = NavigationPermissions.load();
  }

  Future<void> _handleOpenNewShift() async {
    final startingCash = await Navigator.of(context).push<double>(
      MaterialPageRoute(builder: (context) => const OpenShiftScreen()),
    );
    if (startingCash == null || !mounted) return;

    try {
      final newShift = await _shiftController.openShift(startingCash);
      if (mounted) _openShiftDetails(newShift);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 15),
          content: Text('Unable to open shift: $error'),
        ),
      );
    }
  }

  Future<void> _openShiftDetails(ShiftModel shift) async {
    final closedShift = await Navigator.of(context).push<ShiftModel>(
      MaterialPageRoute(
        builder:
            (context) =>
                ShiftDetailsScreen(shift: shift, controller: _shiftController),
      ),
    );
    if (closedShift != null && mounted) {
      setState(() => _selectedTabIndex = 1);
    }
  }

  bool _isToday(ShiftModel shift) {
    final openedAt = shift.openedAt;
    if (openedAt == null) return false;
    final now = DateTime.now();
    final local = openedAt.toLocal();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral[400],
      appBar: AppBar(
        title: Text(
          'Shift',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary[900],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const LaundryNavigationFab(),
      body: NavigationPermissionsBuilder(
        future: _permissionsFuture,
        builder: (context, permissions) => _buildBody(context, permissions),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NavigationPermissions permissions) {
    final canManage = permissions.shiftManagement;
    final canReport = permissions.shiftReport;

    if (!canManage && !canReport) {
      return const Center(child: Text('You do not have shift access.'));
    }
    final selectedTabIndex = !canManage && canReport ? 1 : _selectedTabIndex;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: StreamBuilder<List<ShiftModel>>(
            stream: _shiftController.watchShifts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Unable to load shifts: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final allShifts = snapshot.data!;
              final activeShifts =
                  allShifts.where((shift) => !shift.isClosed).toList();
              final closedShifts =
                  allShifts.where((shift) => shift.isClosed).toList();
              final todayReports = closedShifts.where(_isToday).toList();
              final pastReports =
                  closedShifts.where((shift) => !_isToday(shift)).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (canManage) _tab('Manage', 0, selectedTabIndex),
                        if (canManage && canReport)
                          Container(
                            width: 1,
                            height: 24,
                            color: AppColors.neutral[400],
                          ),
                        if (canReport) _tab('Report', 1, selectedTabIndex),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  selectedTabIndex == 0 && canManage
                      ? ManageShiftSubview(
                        activeShifts: activeShifts,
                        shiftController: _shiftController,
                        onOpenNewShift: _handleOpenNewShift,
                        onShiftTap: _openShiftDetails,
                      )
                      : canReport
                      ? ReportShiftSubview(
                        todayReports: todayReports,
                        pastReports: pastReports,
                        onReportTap: _openShiftDetails,
                      )
                      : const SizedBox.shrink(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, int index, int selectedTabIndex) {
    final isSelected = selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neutral[200] : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color:
                  isSelected
                      ? AppColors.secondary[900]
                      : AppColors.secondary[400],
            ),
          ),
        ),
      ),
    );
  }
}
