import 'package:flutter/material.dart';

import '../core/themes/theme.dart';

InputDecoration appInputDecoration({
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? helperText,
  String? counterText,
  bool alignLabelWithHint = false,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: AppColors.secondary[300] ?? const Color(0xFFBAC0BF),
      fontSize: 16,
    ),
    filled: true,
    fillColor: Colors.white,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    helperText: helperText,
    counterText: counterText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFC7CFCE)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFC7CFCE)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
    ),
  ).copyWith(alignLabelWithHint: alignLabelWithHint);
}
