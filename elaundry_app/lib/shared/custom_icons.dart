import 'package:flutter/material.dart';
import 'package:elaundry_app/core/themes/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleIcon extends StatelessWidget {
  final double size;

  const GoogleIcon({super.key, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/google-icon-logo.svg',
      width: size,
      height: size,
    );
  }
}
