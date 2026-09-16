import 'package:flutter/material.dart';
import 'package:elaundry_app/shared/widgets/custom_icons.dart';
import 'package:elaundry_app/shared/widgets/custom_widgets.dart';
import '../../core/themes/theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                title: 'Creating Your Account...',
                subtitle:
                    'Setting up your account and getting your basket ready...',
              ),
          transitionsBuilder:
              (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );

      try {
        // 2. Perform authentication / registration request
        await Future.delayed(const Duration(seconds: 3));

        // 3. Dismiss loading and pop back to LoginScreen
        if (mounted) {
          // Pops LoadingScreen and RegisterScreen, landing on LoginScreen
          Navigator.of(context).popUntil((route) => route.isFirst);

          // Optional: Notify the user on the LoginScreen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              content: const Text(
                'Account created successfully! Please sign in.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      } catch (error) {
        // If registration fails, pop only the LoadingScreen so the user can fix the form
        if (mounted) {
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              content: Text(
                'Registration failed: $error',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
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
                                    'Register to eLaundry',
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
                                    'Your laundry, scheduled and managed',
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
                                      // FULL NAME FIELD
                                      Text(
                                        'Full Name',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: AppColors.secondary[900],
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _nameController,
                                        keyboardType: TextInputType.name,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.name,
                                        ],
                                        style: theme.textTheme.bodyMedium,
                                        decoration: InputDecoration(
                                          hintText: 'Juan Dela Cruz',
                                          hintStyle: TextStyle(
                                            color: AppColors.secondary[400],
                                          ),
                                          prefixIcon: Icon(
                                            Icons.account_circle_outlined,
                                            size: 20,
                                            color: AppColors.secondary[500],
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Please enter your full name';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 18),

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

                                      const SizedBox(height: 18),

                                      // CONFIRM PASSWORD FIELD
                                      Text(
                                        'Confirm Password',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: AppColors.secondary[900],
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
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
                                          child: const Text('Register Account'),
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
                                              'Already have an account?',
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

                                      // SIGN IN BUTTON
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const LoginScreen(),
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
                                        label: const Text(
                                          'Sign in to your account',
                                        ),
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
