import 'package:flutter/material.dart';

import 'core/themes/theme.dart';
import 'views/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eLaundry',
      theme: AppTheme.light,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
