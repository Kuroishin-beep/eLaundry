import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/themes/theme.dart';
import '../views/catalog/catalog_screen.dart';
import '../views/employee/employee_screen.dart';
import '../views/laundry/machine_screen.dart';
import '../views/orders/orders_screen.dart';
import '../views/reports/report_screen.dart';
import '../views/settings/settings_screen.dart';
import '../views/shift/shift_screen.dart';
import '../views/transaction_history/transaction_history_screen.dart';
import '../services/store_context.dart';

class NavigationPermissions {
  final bool orders;
  final bool transactionHistory;
  final bool machines;
  final bool manageItems;
  final bool manageCategory;
  final bool shiftManagement;
  final bool shiftReport;
  final bool catalog;
  final bool shifts;
  final bool employees;
  final bool reports;
  final bool settings;

  const NavigationPermissions({
    required this.orders,
    required this.transactionHistory,
    required this.machines,
    required this.manageItems,
    required this.manageCategory,
    required this.shiftManagement,
    required this.shiftReport,
    required this.catalog,
    required this.shifts,
    required this.employees,
    required this.reports,
    required this.settings,
  });

  static const none = NavigationPermissions(
    orders: false,
    transactionHistory: false,
    machines: false,
    manageItems: false,
    manageCategory: false,
    shiftManagement: false,
    shiftReport: false,
    catalog: false,
    shifts: false,
    employees: false,
    reports: false,
    settings: false,
  );

  static const owner = NavigationPermissions(
    orders: true,
    transactionHistory: true,
    machines: true,
    manageItems: true,
    manageCategory: true,
    shiftManagement: true,
    shiftReport: true,
    catalog: true,
    shifts: true,
    employees: true,
    reports: true,
    settings: true,
  );

  static Future<NavigationPermissions> load() async {
    try {
      final context = await StoreContextResolver().resolve();
      if (context.isOwner) return owner;
      final permissions = context.permissions;
      return NavigationPermissions(
        orders: permissions.processPayments,
        transactionHistory: permissions.transactionHistory,
        machines: permissions.manageMachines,
        manageItems: permissions.manageItems,
        manageCategory: permissions.manageCategory,
        shiftManagement: permissions.shiftManagement,
        shiftReport: permissions.shiftReport,
        catalog: permissions.manageItems || permissions.manageCategory,
        shifts: permissions.shiftManagement || permissions.shiftReport,
        employees: false,
        reports: permissions.accessReport,
        settings: false,
      );
    } on StateError {
      return none;
    }
  }
}

class NavigationPermissionsBuilder extends StatelessWidget {
  final Future<NavigationPermissions> future;
  final Widget Function(BuildContext, NavigationPermissions) builder;

  const NavigationPermissionsBuilder({
    super.key,
    required this.future,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NavigationPermissions>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Unable to load permissions.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return builder(context, snapshot.data!);
      },
    );
  }
}

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
  late final Animation<double> _spinAnimation;
  bool _isOpen = false;
  late final Future<NavigationPermissions> _permissionsFuture;

  @override
  void initState() {
    super.initState();
    _permissionsFuture = NavigationPermissions.load();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 1 full spin + 45-degree rotation (1.125 turns) to settle as a 45° diamond
    _spinAnimation = Tween<double>(begin: 0.0, end: 1.125).animate(
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

  void _openFullScreenMenu() {
    if (_isOpen) return;

    setState(() => _isOpen = true);
    _animController.forward();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'FullScreenNavMenu',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
        );
        final topPadding = MediaQuery.of(dialogContext).padding.top;
        final bottomPadding = MediaQuery.of(dialogContext).padding.bottom;

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // 2x4 full-screen grid
            Positioned(
              top: topPadding + 14,
              bottom: bottomPadding + 86,
              left: 18,
              right: 18,
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                  child: Material(
                    color: Colors.transparent,
                    child: FutureBuilder<NavigationPermissions>(
                      future: _permissionsFuture,
                      builder: (context, snapshot) {
                        return _FullScreenGridMenu(
                          onClose: () => Navigator.of(dialogContext).pop(),
                          onSettingsTap: widget.onSettingsTap,
                          onMachinesTap: widget.onMachinesTap,
                          permissions:
                              snapshot.hasError
                                  ? NavigationPermissions.none
                                  : snapshot.data ?? NavigationPermissions.none,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Pinned Diamond Close Button
            Positioned(
              bottom: bottomPadding + 16,
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: RotationTransition(
                  turns: _spinAnimation,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    // Rotating a + icon by 45° with the container creates an upright X
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
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
        _animController.reverse().then((_) {
          if (mounted) setState(() => _isOpen = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isOpen ? 0.0 : 1.0,
      child: GestureDetector(
        onTap: _isOpen ? null : _openFullScreenMenu,
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
            child: SvgPicture.asset(
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
    );
  }
}

class _FullScreenGridMenu extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onMachinesTap;
  final NavigationPermissions permissions;

  const _FullScreenGridMenu({
    required this.onClose,
    required this.permissions,
    this.onSettingsTap,
    this.onMachinesTap,
  });

  void _navigateTo(BuildContext context, Widget screen) {
    onClose();
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
    final navItems = [
      _NavItemData(
        icon: Icons.receipt_long_rounded,
        label: 'Orders',
        enabled: permissions.orders,
        onTap: () {
          if (context.findAncestorWidgetOfExactType<OrdersScreen>() == null) {
            _navigateTo(context, const OrdersScreen());
          } else {
            onClose();
          }
        },
      ),
      _NavItemData(
        icon: Icons.receipt_rounded,
        label: 'Transaction History',
        enabled: permissions.transactionHistory,
        onTap: () {
          if (context
                  .findAncestorWidgetOfExactType<TransactionHistoryScreen>() ==
              null) {
            _navigateTo(context, const TransactionHistoryScreen());
          } else {
            onClose();
          }
        },
      ),
      _NavItemData(
        icon: Icons.local_laundry_service_rounded,
        label: 'Laundry Machine',
        enabled: permissions.machines,
        onTap: () {
          if (onMachinesTap != null) {
            onClose();
            onMachinesTap!();
          } else {
            if (context.findAncestorWidgetOfExactType<MachinesScreen>() ==
                null) {
              _navigateTo(context, const MachinesScreen());
            } else {
              onClose();
            }
          }
        },
      ),
      _NavItemData(
        icon: Icons.sell_rounded,
        label: 'Item',
        enabled: permissions.catalog,
        onTap: () {
          if (context.findAncestorWidgetOfExactType<CatalogScreen>() == null) {
            _navigateTo(context, const CatalogScreen());
          } else {
            onClose();
          }
        },
      ),
      _NavItemData(
        icon: Icons.schedule_rounded,
        label: 'Shift',
        enabled: permissions.shifts,
        onTap: () {
          if (context.findAncestorWidgetOfExactType<ShiftScreen>() == null) {
            _navigateTo(context, const ShiftScreen());
          } else {
            onClose();
          }
        },
      ),
      _NavItemData(
        icon: Icons.badge_rounded,
        label: 'Employee',
        enabled: permissions.employees,
        onTap: () {
          if (context.findAncestorWidgetOfExactType<EmployeeScreen>() == null) {
            _navigateTo(context, const EmployeeScreen());
          } else {
            onClose();
          }
        },
      ),
      _NavItemData(
        icon: Icons.insert_chart_rounded,
        label: 'Reports',
        enabled: permissions.reports,
        onTap: () {
          if (context.findAncestorWidgetOfExactType<ReportScreen>() == null) {
            _navigateTo(context, const ReportScreen());
          } else {
            onClose();
          }
        },
      ),
      _NavItemData(
        icon: Icons.settings_rounded,
        label: 'Settings',
        enabled: permissions.settings,
        onTap: () {
          if (onSettingsTap != null) {
            onClose();
            onSettingsTap!();
          } else {
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const crossAxisCount = 2;
            const rowCount = 4;
            const spacing = 12.0;
            final itemWidth = (constraints.maxWidth - spacing) / crossAxisCount;
            final itemHeight =
                (constraints.maxHeight - (spacing * (rowCount - 1))) / rowCount;
            final aspectRatio = itemWidth / itemHeight;

            return GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: navItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                final item = navItems[index];
                return _SquareNavCard(item: item, onCloseParent: onClose);
              },
            );
          },
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const _NavItemData({
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
  });
}

class _SquareNavCard extends StatelessWidget {
  final _NavItemData item;
  final VoidCallback onCloseParent;

  const _SquareNavCard({required this.item, required this.onCloseParent});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.enabled ? Colors.white : AppColors.neutral[300],
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        onTap: () {
          if (!item.enabled) {
            return;
          }
          if (item.onTap != null) {
            item.onTap!();
          } else {
            onCloseParent();
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color:
                      item.enabled
                          ? AppColors.primary[600]
                          : AppColors.neutral[500],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(item.icon, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 10),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.normal,
                  color:
                      item.enabled
                          ? const Color(0xFF2C2D2D)
                          : AppColors.secondary[500],
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
