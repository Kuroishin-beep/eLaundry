import 'package:flutter/material.dart';

import '../core/themes/theme.dart';

class SectionCard extends StatelessWidget {
  final String? stepNumber;
  final IconData? stepIcon;
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double shadowOpacity;
  final Offset shadowOffset;
  final double titleFontSize;
  final Color? titleColor;
  final FontWeight titleFontWeight;
  final double titleLetterSpacing;
  final double contentSpacing;

  const SectionCard({
    super.key,
    this.stepNumber,
    this.stepIcon,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 16,
    this.shadowOpacity = 0.03,
    this.shadowOffset = const Offset(0, 4),
    this.titleFontSize = 12,
    this.titleColor,
    this.titleFontWeight = FontWeight.w700,
    this.titleLetterSpacing = 0.3,
    this.contentSpacing = 16,
  }) : assert((stepNumber == null) != (stepIcon == null));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowOpacity),
            blurRadius: 10,
            offset: shadowOffset,
          ),
        ],
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (stepNumber != null)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    stepNumber!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Icon(stepIcon!, color: Colors.white, size: 14),
                ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: titleFontWeight,
                  color: titleColor ?? AppColors.secondary[700],
                  letterSpacing: titleLetterSpacing,
                ),
              ),
            ],
          ),
          SizedBox(height: contentSpacing),
          ...children,
        ],
      ),
    );
  }
}
