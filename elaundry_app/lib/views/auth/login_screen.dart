import 'package:flutter/material.dart';
import 'package:elaundry_app/shared/widgets/custom_icons.dart';
import 'package:elaundry_app/shared/widgets/custom_widgets.dart';
import '../../core/themes/theme.dart';
import 'register_screen.dart';
import '../settings/settings_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // LOADING SCREEN
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      // 1. Navigate to the full loading screen
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder:
              (_, __, ___) => const LoadingScreen(
                title: 'Signing in to eLaundry...',
                subtitle: 'Getting your laundry basket ready...',
              ),
          transitionsBuilder:
              (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );

      try {
        // 2. Perform authentication request
        await Future.delayed(const Duration(seconds: 3));

        // 3. Clear auth stack and navigate directly to SettingsScreen
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
            (route) => false,
          );
        }
      } catch (error) {
        // If an error occurs, pop only the LoadingScreen back to LoginScreen
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final bannerHeight = screenHeight * 0.38;
    const overlapAmount = 32.0;
    const GoogleIcon();

    return Scaffold(
      backgroundColor: AppColors.neutral[500],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // TOP HERO BANNER
                    SizedBox(
                      height: bannerHeight,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // GRADIENT BACKGROUND
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary[600]!,
                                  AppColors.primary[800]!,
                                  AppColors.primary[900]!,
                                ],
                              ),
                            ),
                          ),
                          // PATTERN OVERLAY CIRCLES
                          Positioned(
                            top: -40,
                            right: -40,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.04),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: -30,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.03),
                              ),
                            ),
                          ),
                          // HEADER CONTENT
                          SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                12,
                                24,
                                overlapAmount + 12,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Brand Badge
                                  Image.asset(
                                    'assets/images/elaundry-logo.png',
                                    width: 100,
                                    height: 100,
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    "Let's get you Login",
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.displayLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
                                          fontSize: 30,
                                        ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Good to see you! Let’s get your laundry sorted',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // OVERLAPPING FORM SHEET EXTENDING TO BOTTOM
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(0, -overlapAmount),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 18,
                                offset: Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  24,
                                  32,
                                  24,
                                  mediaQuery.padding.bottom + 28,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // EMAIL FIELD
                                      Text(
                                        'Email Address',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: AppColors.secondary[900],
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        style: theme.textTheme.bodyMedium,
                                        decoration: InputDecoration(
                                          hintText: 'you@example.com',
                                          hintStyle: TextStyle(
                                            color: AppColors.secondary[400],
                                          ),
                                          prefixIcon: Icon(
                                            Icons.alternate_email_rounded,
                                            size: 20,
                                            color: AppColors.secondary[500],
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(value.trim())) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 18),

                                      // PASSWORD FIELD
                                      Text(
                                        'Password',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: AppColors.secondary[900],
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        onFieldSubmitted: (_) => _submit(),
                                        style: theme.textTheme.bodyMedium,
                                        decoration: InputDecoration(
                                          hintText: '••••••••',
                                          hintStyle: TextStyle(
                                            color: AppColors.secondary[400],
                                          ),
                                          prefixIcon: Icon(
                                            Icons.lock_outline_rounded,
                                            size: 20,
                                            color: AppColors.secondary[500],
                                          ),
                                          suffixIcon: IconButton(
                                            splashRadius: 20,
                                            onPressed:
                                                () => setState(
                                                  () =>
                                                      _obscurePassword =
                                                          !_obscurePassword,
                                                ),
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              size: 20,
                                              color: AppColors.secondary[500],
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          if (value.length < 6) {
                                            return 'Must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 12),

                                      GestureDetector(
                                        onTap: () {},
                                        child: Text(
                                          'Forgot password?',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color: AppColors.accent,
                                              ),
                                        ),
                                      ),

                                      const SizedBox(height: 26),

                                      // Main Sign-In Button
                                      SizedBox(
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: _submit,
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text('Sign In'),
                                        ),
                                      ),
                                      const SizedBox(height: 22),

                                      // Divider
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: AppColors.neutral[500],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                            ),
                                            child: Text(
                                              'Don’t have an account yet?',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors
                                                            .secondary[500],
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: AppColors.neutral[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 22),

                                      // SIGN UP BUTTON
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const RegisterScreen(),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 50),
                                          side: BorderSide(
                                            color: AppColors.neutral[600]!,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          foregroundColor:
                                              AppColors.secondary[900],
                                          textStyle: theme.textTheme.labelLarge
                                              ?.copyWith(fontSize: 14),
                                        ),
                                        label: const Text('Create an account'),
                                      ),

                                      const SizedBox(height: 16),

                                      // GOOGLE SIGN-IN BUTTON
                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 50),
                                          side: BorderSide(
                                            color: AppColors.neutral[600]!,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          foregroundColor:
                                              AppColors.secondary[900],
                                          textStyle: theme.textTheme.labelLarge
                                              ?.copyWith(fontSize: 14),
                                        ),
                                        icon: const GoogleIcon(),
                                        label: const Text(
                                          'Sign in with Google',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
