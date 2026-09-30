import 'package:flutter/material.dart';

import '../../../shared/section_card.dart';

class CatalogSectionCard extends StatelessWidget {
  final String stepNumber;
  final String title;
  final List<Widget> children;

  const CatalogSectionCard({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      stepNumber: stepNumber,
      title: title,
      padding: const EdgeInsets.all(16),
      borderRadius: 14,
      shadowOpacity: 0.02,
      shadowOffset: const Offset(0, 3),
      titleFontSize: 11.5,
      titleColor: const Color(0xFF454746),
      titleLetterSpacing: 0,
      contentSpacing: 14,
      children: children,
    );
  }
}
