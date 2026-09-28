import 'package:flutter/material.dart';

import '../../../../shared/detail_value_box.dart';
import '../../../../shared/field_label.dart';

class StaffInfoField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;

  const StaffInfoField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(
          label: label,
          color: const Color(0xFF555B5A),
          letterSpacing: 0.3,
          bottomSpacing: 0,
        ),
        const SizedBox(height: 5),
        DetailValueBox(
          text: value,
          icon: icon,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: 4,
          borderColor: null,
          iconSize: 16,
          iconColor: const Color(0xFF6B7270),
          iconSpacing: 10,
          textStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF333534)),
        ),
      ],
    );
  }
}
