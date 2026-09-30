import 'package:flutter/material.dart';

import '../../../controllers/shift_controller.dart';
import '../../../core/themes/theme.dart';
import '../../../models/shift_model.dart';
import '../../../shared/empty_states.dart';

class ManageShiftSubview extends StatelessWidget {
  final List<ShiftModel> activeShifts;
  final VoidCallback onOpenNewShift;
  final ValueChanged<ShiftModel> onShiftTap;
  final ShiftController shiftController;

  const ManageShiftSubview({
    super.key,
    required this.activeShifts,
    required this.onOpenNewShift,
    required this.onShiftTap,
    required this.shiftController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (activeShifts.isEmpty)
          SizedBox(
            height: 460,
            child: Center(
              child: EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No Active Shift',
                description:
                    'Open a shift to start recording orders and tracking cash flow.',
                actionLabel: 'Open Shift',
                onAction: onOpenNewShift,
              ),
            ),
          )
        else ...[
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onOpenNewShift,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Open New Shift',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Active (${activeShifts.length})',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555B5A),
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeShifts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final shift = activeShifts[index];
              return StreamBuilder<ShiftModel>(
                stream: shiftController.watchShiftSales(shift),
                initialData: shift,
                builder: (context, snapshot) {
                  final displayedShift = snapshot.data ?? shift;
                  return InkWell(
                    onTap: () => onShiftTap(displayedShift),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
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
                      // Washer machine pink icon block
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
                              displayedShift.id,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2C2D2D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayedShift.time,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.secondary[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'P${displayedShift.cashPayments.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222423),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Color(0xFF454746),
                      ),
                    ],
                  ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }
}
