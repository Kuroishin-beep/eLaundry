import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/themes/theme.dart';
import '../../views/laundry/machine_screen.dart';
import '../../views/settings/settings_screen.dart';

class LaundryNavigationFab extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onMachinesTap;

  const LaundryNavigationFab({
    super.key,
    this.onSettingsTap,
    this.onMachinesTap,
  });

  @override
  State<LaundryNavigationFab> createState() => _LaundryNavigationFabState();
}

class _LaundryNavigationFabState extends State<LaundryNavigationFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _containerSpinAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // 1 full spin + 45-degree turn (1.125 turns total) to settle into the diamond
    _containerSpinAnimation = Tween<double>(begin: 0.0, end: 1.125).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutCubicEmphasized,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpen) return;

    setState(() => _isOpen = true);
    _animController.forward();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'NavigationMenu',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, anim1, anim2, child) {
        final curvedAnim = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
        );

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 96,
              left: 16,
              right: 16,
              child: FadeTransition(
                opacity: curvedAnim,
                child: ScaleTransition(
                  alignment: Alignment.bottomCenter,
                  scale: Tween<double>(
                    begin: 0.85,
                    end: 1.0,
                  ).animate(curvedAnim),
                  child: Material(
                    color: Colors.transparent,
                    child: _NavigationGridCard(
                      onClose: () => Navigator.of(dialogContext).pop(),
                      onSettingsTap: widget.onSettingsTap,
                      onMachinesTap: widget.onMachinesTap,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() => _isOpen = false);
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleMenu,
      child: RotationTransition(
        turns: _containerSpinAnimation,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  _isOpen
                      ? const Icon(
                        Icons.close_rounded,
                        key: ValueKey('close_icon'),
                        color: Colors.white,
                        size: 28,
                      )
                      : SvgPicture.asset(
                        'assets/icons/washing-machine-icon.svg',
                        key: const ValueKey('washing_machine_svg'),
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationGridCard extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onMachinesTap;

  const _NavigationGridCard({
    required this.onClose,
    this.onSettingsTap,
    this.onMachinesTap,
  });

  void _navigateTo(BuildContext context, Widget screen) {
    onClose();
    // Replaces current primary screen so history doesn't cycle infinitely
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder:
            (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRouteName = ModalRoute.of(context)?.settings.name;

    final navItems = [
      _NavItemData(icon: Icons.local_mall_rounded, label: 'Orders'),
      _NavItemData(icon: Icons.receipt, label: 'Transaction\nHistory'),
      _NavItemData(
        icon: Icons.local_laundry_service_rounded,
        label: 'Laundry Machine',
        onTap: () {
          if (onMachinesTap != null) {
            onClose();
            onMachinesTap!();
          } else {
            // Avoid pushing if already on the Machines screen
            if (context.findAncestorWidgetOfExactType<MachinesScreen>() ==
                null) {
              _navigateTo(context, const MachinesScreen());
            } else {
              onClose();
            }
          }
        },
      ),
      _NavItemData(icon: Icons.sell_rounded, label: 'Item'),
      _NavItemData(icon: Icons.alarm_rounded, label: 'Shift'),
      _NavItemData(icon: Icons.badge_rounded, label: 'Employee'),
      _NavItemData(icon: Icons.insert_chart_rounded, label: 'Reports'),
      _NavItemData(
        icon: Icons.settings_rounded,
        label: 'Settings',
        onTap: () {
          if (onSettingsTap != null) {
            onClose();
            onSettingsTap!();
          } else {
            // Avoid pushing if already on the Settings screen
            if (context.findAncestorWidgetOfExactType<SettingsScreen>() ==
                null) {
              _navigateTo(context, const SettingsScreen());
            } else {
              onClose();
            }
          }
        },
      ),
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: navItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 18,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final item = navItems[index];
          return _NavGridTile(item: item, onCloseParent: onClose);
        },
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _NavItemData({required this.icon, required this.label, this.onTap});
}

class _NavGridTile extends StatelessWidget {
  final _NavItemData item;
  final VoidCallback onCloseParent;

  const _NavGridTile({required this.item, required this.onCloseParent});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (item.onTap != null) {
          item.onTap!();
        } else {
          onCloseParent();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
