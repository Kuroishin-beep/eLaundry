import 'package:flutter/material.dart';

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
  int _selectedTabIndex = 0; // 0: Manage, 1: Report

  // Active shifts list
  final List<ShiftModel> _activeShifts = [
    const ShiftModel(
      id: '#123456',
      dateTime: 'August 21, 2026 – 10:00 AM',
      time: '10:00 AM',
      startingCash: 5000.00,
      isClosed: false,
    ),
  ];

  // Closed shifts repository (Reports)
  final List<ShiftModel> _todayReports = [
    const ShiftModel(
      id: '#123456',
      dateTime: 'August 21, 2026 – 10:00 AM',
      time: '10:00 AM',
      startingCash: 5000.00,
      isClosed: true,
      closedAt: '02:00 PM',
    ),
    const ShiftModel(
      id: '#123456',
      dateTime: 'August 21, 2026 – 10:00 AM',
      time: '10:00 AM',
      startingCash: 5000.00,
      isClosed: true,
      closedAt: '06:00 PM',
    ),
  ];

  final List<ShiftModel> _pastReports = [
    const ShiftModel(
      id: '#123456',
      dateTime: 'August 20, 2026 – 10:00 AM',
      time: '10:00 AM',
      startingCash: 5000.00,
      isClosed: true,
      closedAt: '06:00 PM',
    ),
    const ShiftModel(
      id: '#123456',
      dateTime: 'August 19, 2026 – 10:00 AM',
      time: '10:00 AM',
      startingCash: 5000.00,
      isClosed: true,
      closedAt: '06:00 PM',
    ),
  ];

  // 1. Flow: Open New Shift -> Cash Screen -> Shift Details -> Manage List
  void _handleOpenNewShift() async {
    final startingCash = await Navigator.of(context).push<double>(
      MaterialPageRoute(builder: (context) => const OpenShiftScreen()),
    );

    if (startingCash != null && mounted) {
      final newShift = ShiftModel(
        id: '#${(100000 + _activeShifts.length + _todayReports.length + 1)}',
        dateTime: 'August 21, 2026 – 10:00 AM',
        time: '10:00 AM',
        startingCash: startingCash,
        isClosed: false,
      );

      setState(() => _activeShifts.add(newShift));

      // Redirect directly to the shift details screen as requested
      _openShiftDetails(newShift);
    }
  }

  // 2. Open Shift Details (supports closing shift and archiving to report)
  void _openShiftDetails(ShiftModel shift) async {
    final closedShift = await Navigator.of(context).push<ShiftModel>(
      MaterialPageRoute(builder: (context) => ShiftDetailsScreen(shift: shift)),
    );

    if (closedShift != null && mounted) {
      setState(() {
        _activeShifts.removeWhere((s) => s.id == closedShift.id);
        _todayReports.insert(0, closedShift);
        // Switch tab to Report view to show the saved shift
        _selectedTabIndex = 1;
      });
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Segmented Switcher (Manage | Report)
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
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  _selectedTabIndex == 0
                                      ? AppColors.neutral[200]
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Manage',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color:
                                    _selectedTabIndex == 0
                                        ? AppColors.secondary[900]
                                        : AppColors.secondary[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.neutral[400],
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  _selectedTabIndex == 1
                                      ? AppColors.neutral[200]
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Report',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color:
                                    _selectedTabIndex == 1
                                        ? AppColors.secondary[900]
                                        : AppColors.secondary[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Active Subview
                _selectedTabIndex == 0
                    ? ManageShiftSubview(
                      activeShifts: _activeShifts,
                      onOpenNewShift: _handleOpenNewShift,
                      onShiftTap: _openShiftDetails,
                    )
                    : ReportShiftSubview(
                      todayReports: _todayReports,
                      pastReports: _pastReports,
                      onReportTap: _openShiftDetails,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
