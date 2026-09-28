import 'package:flutter/material.dart';
import '../core/themes/theme.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final double letterSpacing;
  final double bottomSpacing;

  const FieldLabel({
    super.key,
    required this.label,
    this.fontSize = 11,
    this.fontWeight = FontWeight.w600,
    this.color,
    this.letterSpacing = 0.2,
    this.bottomSpacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color ?? AppColors.neutral[800]!,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}
