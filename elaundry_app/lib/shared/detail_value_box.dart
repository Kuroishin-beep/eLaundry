import 'package:flutter/material.dart';

class DetailValueBox extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Widget? iconWidget;
  final bool hasChevron;
  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final double iconSize;
  final Color iconColor;
  final double iconSpacing;
  final TextStyle textStyle;

  const DetailValueBox({
    super.key,
    required this.text,
    this.icon,
    this.iconWidget,
    this.hasChevron = false,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
    this.borderRadius = 10,
    this.borderColor = const Color(0xFFC7CFCE),
    this.iconSize = 18,
    this.iconColor = const Color(0xFF5A5D5C),
    this.iconSpacing = 12,
    this.textStyle = const TextStyle(fontSize: 16, color: Color(0xFF333534)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Row(
        children: [
          iconWidget ?? Icon(icon, size: iconSize, color: iconColor),
          SizedBox(width: iconSpacing),
          Expanded(child: Text(text, style: textStyle)),
          if (hasChevron)
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF6B7270),
            ),
        ],
      ),
    );
  }
}
