import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/themes/theme.dart';
import '../../shared/widgets/laundry_navigation_fab.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          AppColors.neutral[400], // Soft neutral light grey background
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary[900],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const LaundryNavigationFab(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General Section
                _SectionTitle(title: 'General'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      title: 'Notifications',
                      trailing: Transform.scale(
                        scale: 0.85,
                        child: CupertinoSwitch(
                          value: _notificationsEnabled,
                          activeTrackColor: AppColors.success,
                          onChanged: (value) {
                            setState(() => _notificationsEnabled = value);
                          },
                        ),
                      ),
                    ),
                    const _CardDivider(),
                    _SettingsTile(
                      icon: Icons.mail,
                      title: 'Email Address',
                      onTap: () {},
                    ),
                    const _CardDivider(),
                    _SettingsTile(
                      icon: Icons.account_circle,
                      title: 'Account Name',
                      onTap: () {},
                    ),
                    const _CardDivider(),
                    _SettingsTile(
                      icon: Icons.lock,
                      title: 'Password',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Store Section
                _SectionTitle(title: 'Store'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.store_rounded,
                      title: 'Store Name',
                      onTap: () {},
                    ),
                    const _CardDivider(),
                    _SettingsTile(
                      icon: Icons.location_on,
                      title: 'Address',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Security & Session Section
                _SectionTitle(title: 'Security & Session'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.dialpad_rounded,
                      title: 'Pin',
                      onTap: () {},
                    ),
                    const _CardDivider(),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      isDestructive: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF3B3D3C),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor =
        isDestructive ? AppColors.accent : AppColors.secondary[900];
    final chevronColor =
        isDestructive ? AppColors.accent : AppColors.secondary[300];

    return Padding(
      // Outer padding creates an inset boundary for the ink splash
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10), // Tighter rounded rect
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: AppColors.neutral[400],
          highlightColor: AppColors.neutral[300],
          child: Padding(
            // Inner padding keeps content spacing balanced
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                // Soft rounded square around each icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.neutral[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color:
                        isDestructive
                            ? AppColors.accent
                            : AppColors.secondary[600],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: chevronColor,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 64, // Aligns after the icon box
      endIndent: 14,
      color: AppColors.neutral[400],
    );
  }
}
