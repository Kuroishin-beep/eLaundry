import 'package:flutter/material.dart';
import 'package:elaundry_app/core/themes/theme.dart';

class LoadingScreen extends StatefulWidget {
  final String title;
  final String subtitle;

  const LoadingScreen({
    super.key,
    this.title = 'Signing in to eLaundry...',
    this.subtitle = 'Please hold on while we prepare your space',
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false, // Prevents Android back-button during auth/loading
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- Washing Machine Unit ---
                  Container(
                    width: 110,
                    height: 110,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.neutral[100],
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.neutral[600]!,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary[900]!.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top Console (Detergent drawer + LED lights)
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppColors.secondary[400],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Central Rotating Drum
                        RotationTransition(
                          turns: _spinController,
                          child: Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary[100],
                              border: Border.all(
                                color: AppColors.primary,
                                width: 3,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Drum perforation dots
                                ...List.generate(4, (index) {
                                  return Transform.translate(
                                    offset: Offset(
                                      20 *
                                          (index % 2 == 0
                                              ? (index == 0 ? 1 : -1)
                                              : 0),
                                      20 *
                                          (index % 2 != 0
                                              ? (index == 1 ? 1 : -1)
                                              : 0),
                                    ),
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary[400],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }),
                                // Drum spin ripple icon
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 34,
                                  color: AppColors.primary[700],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title Text
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primary[900],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle Text
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
