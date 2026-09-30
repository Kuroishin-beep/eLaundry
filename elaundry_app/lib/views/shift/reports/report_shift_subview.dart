import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/shift_model.dart';
import '../../../shared/search_filter_bar.dart';

class ReportShiftSubview extends StatefulWidget {
  final List<ShiftModel> todayReports;
  final List<ShiftModel> pastReports;
  final ValueChanged<ShiftModel> onReportTap;

  const ReportShiftSubview({
    super.key,
    required this.todayReports,
    required this.pastReports,
    required this.onReportTap,
  });

  @override
  State<ReportShiftSubview> createState() => _ReportShiftSubviewState();
}

class _ReportShiftSubviewState extends State<ReportShiftSubview> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ShiftModel> _filter(List<ShiftModel> list) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list
        .where(
          (s) =>
              s.id.toLowerCase().contains(q) ||
              s.time.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredToday = _filter(widget.todayReports);
    final filteredPast = _filter(widget.pastReports);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search & Filter Bar
        CapsuleSearchFilterBar(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          onFilterTap: () {},
          hintText: 'Search',
        ),
        const SizedBox(height: 16),

        // --- Today Section ---
        if (filteredToday.isNotEmpty) ...[
          const Text(
            'Today',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555B5A),
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredToday.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder:
                (context, index) => _buildReportCard(filteredToday[index]),
          ),
          const SizedBox(height: 18),
        ],

        // --- Past Reports Section ---
        if (filteredPast.isNotEmpty) ...[
          const Text(
            'Past Reports',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555B5A),
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredPast.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder:
                (context, index) => _buildReportCard(filteredPast[index]),
          ),
        ],
      ],
    );
  }

  Widget _buildReportCard(ShiftModel shift) {
    return InkWell(
      onTap: () => widget.onReportTap(shift),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neutral[500]!),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.local_laundry_service_rounded,
                color: AppColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift.id,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shift.time,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.secondary[400],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'P${shift.cashPayments.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222423),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
