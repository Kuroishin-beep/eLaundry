import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/themes/theme.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../shared/laundry_navigation_fab.dart';
import '../auth/login_screen.dart';
import 'edit_settings_screen.dart';
import '../../services/media_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController _settingsController = SettingsController();
  final AuthController _authController = AuthController();

  bool _isLoading = true;

  // Stored state for editable values
  bool _notificationsEnabled = true;
  String? _profileImagePath;
  String _email = '';
  String _accountName = '';
  String _storeName = '';
  String _address = '';
  String _pin = '';
  bool _isStoreOwner = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsData();
  }

  Future<void> _loadSettingsData() async {
    try {
      final user = await _settingsController.getUserProfile();
      final storeContext = await _settingsController.getStoreContext();
      final store = await _settingsController.getStoreSettings();
      final employeePin =
          storeContext.isOwner
              ? null
              : await _settingsController.getEmployeePin();

      if (mounted) {
        setState(() {
          _email = user?.email ?? '';
          _accountName = user?.fullName ?? '';
          _profileImagePath = user?.profileImage;

          _storeName = store.storeName;
          _address = store.address;
          _pin = employeePin ?? (storeContext.isOwner ? store.pin : '');
          _notificationsEnabled = store.notificationsEnabled;
          _isStoreOwner = storeContext.isOwner;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to load settings: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    AppSnackBar.showError(context, message);
  }

  void _showSuccessSnackBar(String message) {
    AppSnackBar.showSuccess(context, message);
  }

  String _formatTruncated(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  void _showImagePickerOptions() {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: const Text('Profile Photo'),
            message: const Text('Select a source to update your profile photo'),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _uploadProfileImage();
                },
                child: const Text('Take Photo'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _uploadProfileImage();
                },
                child: const Text('Choose from Gallery'),
              ),
              if (_profileImagePath != null)
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _profileImagePath = null);
                  },
                  child: const Text('Remove Photo'),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
    );
  }

  Future<void> _uploadProfileImage() async {
    final url = await MediaService().pickAndUpload(folder: 'profiles');
    if (url == null || !mounted) return;
    try {
      await _settingsController.updateProfileImage(url);
      setState(() => _profileImagePath = url);
      _showSuccessSnackBar('Profile picture updated successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to update profile picture: $e');
    }
  }

  void _openEditor({
    required String title,
    required String label,
    required String currentValue,
    required SettingFieldType fieldType,
    int? maxLength,
    String? helperText,
    String? expectedVerificationValue,
    String verificationLabel = 'Current value',
    required Future<void> Function(String) onSave,
  }) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder:
            (context) => EditSettingsScreen(
              title: title,
              label: label,
              initialValue: currentValue,
              fieldType: fieldType,
              maxLength: maxLength,
              helperText: helperText,
              expectedVerificationValue: expectedVerificationValue,
              verificationLabel: verificationLabel,
            ),
      ),
    );

    if (result != null && result != currentValue) {
      try {
        await onSave(result);
        _showSuccessSnackBar('$title updated successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to update $title: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral[400],
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // General Section
                        const _SectionTitle(title: 'General'),
                        const SizedBox(height: 8),
                        _SettingsCard(
                          children: [
                            _SettingsTile(
                              icon: Icons.camera_alt_rounded,
                              title: 'Profile Picture',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primary[100],
                                    backgroundImage:
                                        _profileImagePath != null
                                            ? NetworkImage(_profileImagePath!)
                                            : null,
                                    child:
                                        _profileImagePath == null
                                            ? Icon(
                                              Icons.person_rounded,
                                              size: 20,
                                              color: AppColors.primary[700],
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: AppColors.secondary[300],
                                  ),
                                ],
                              ),
                              onTap:
                                  _isStoreOwner
                                      ? _showImagePickerOptions
                                      : null,
                            ),
                            const _CardDivider(),
                            _SettingsTile(
                              icon: Icons.mail,
                              title: 'Email Address',
                              trailing: Text(
                                _email.isEmpty
                                    ? ''
                                    : _formatTruncated(_email, 10),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondary[600],
                                ),
                              ),
                              onTap:
                                  _isStoreOwner
                                      ? () => _openEditor(
                                        title: 'Email Address',
                                        label: 'Email',
                                        currentValue: _email,
                                        fieldType: SettingFieldType.email,
                                        onSave: (val) async {
                                          await _settingsController.updateEmail(
                                            val,
                                          );
                                          setState(() => _email = val);
                                        },
                                      )
                                      : null,
                            ),
                            const _CardDivider(),
                            _SettingsTile(
                              icon: Icons.account_circle,
                              title: 'Account Name',
                              trailing: Text(
                                _accountName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondary[600],
                                ),
                              ),
                              onTap:
                                  _isStoreOwner
                                      ? () => _openEditor(
                                        title: 'Account Name',
                                        label: 'Full Name',
                                        currentValue: _accountName,
                                        fieldType: SettingFieldType.text,
                                        onSave: (val) async {
                                          await _settingsController
                                              .updateAccountName(val);
                                          setState(() => _accountName = val);
                                        },
                                      )
                                      : null,
                            ),
                            const _CardDivider(),
                            if (_isStoreOwner)
                              _SettingsTile(
                                icon: Icons.lock,
                                title: 'Password',
                                onTap:
                                    () => _openEditor(
                                      title: 'Change Password',
                                      label: 'New Password',
                                      currentValue: '',
                                      fieldType: SettingFieldType.password,
                                      helperText:
                                          'Must be at least 6 characters long',
                                      onSave: (val) async {
                                        await _settingsController
                                            .updatePassword(val);
                                      },
                                    ),
                              ),
                            const _CardDivider(),
                            _SettingsTile(
                              icon: Icons.notifications_rounded,
                              title: 'Notifications',
                              trailing: Transform.scale(
                                scale: 0.85,
                                child: CupertinoSwitch(
                                  value: _notificationsEnabled,
                                  activeTrackColor: AppColors.success,
                                  onChanged:
                                      _isStoreOwner
                                          ? (value) async {
                                            setState(
                                              () =>
                                                  _notificationsEnabled = value,
                                            );
                                            await _settingsController
                                                .updateStoreSettings(
                                                  notificationsEnabled: value,
                                                );
                                          }
                                          : null,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Store Section
                        const _SectionTitle(title: 'Store'),
                        const SizedBox(height: 8),
                        _SettingsCard(
                          children: [
                            _SettingsTile(
                              icon: Icons.store_rounded,
                              title: 'Store Name',
                              trailing: Text(
                                _storeName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondary[600],
                                ),
                              ),
                              onTap:
                                  _isStoreOwner
                                      ? () => _openEditor(
                                        title: 'Store Name',
                                        label: 'Store / Branch Name',
                                        currentValue: _storeName,
                                        fieldType: SettingFieldType.text,
                                        onSave: (val) async {
                                          await _settingsController
                                              .updateStoreSettings(
                                                storeName: val,
                                              );
                                          setState(() => _storeName = val);
                                        },
                                      )
                                      : null,
                            ),
                            const _CardDivider(),
                            _SettingsTile(
                              icon: Icons.location_on,
                              title: 'Address',
                              trailing: SizedBox(
                                width: 140,
                                child: Text(
                                  _address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.secondary[600],
                                  ),
                                ),
                              ),
                              onTap:
                                  _isStoreOwner
                                      ? () => _openEditor(
                                        title: 'Store Address',
                                        label: 'Physical Address',
                                        currentValue: _address,
                                        fieldType: SettingFieldType.multiline,
                                        onSave: (val) async {
                                          await _settingsController
                                              .updateStoreSettings(
                                                address: val,
                                              );
                                          setState(() => _address = val);
                                        },
                                      )
                                      : null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Security & Session Section
                        const _SectionTitle(title: 'Security & Session'),
                        const SizedBox(height: 8),
                        _SettingsCard(
                          children: [
                            if (!_isStoreOwner)
                              _SettingsTile(
                                icon: Icons.dialpad_rounded,
                                title: 'Pin',
                                trailing: Text(
                                  _pin.isEmpty ? '' : '••••',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.secondary[600],
                                  ),
                                ),
                                onTap: null,
                              ),
                            const _CardDivider(),
                            _SettingsTile(
                              icon: Icons.logout_rounded,
                              title: 'Logout',
                              isDestructive: true,
                              onTap: () async {
                                try {
                                  await _authController.signOut();
                                  if (context.mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    _showErrorSnackBar('Failed to logout: $e');
                                  }
                                }
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: AppColors.neutral[400],
          highlightColor: AppColors.neutral[300],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
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
      indent: 64,
      endIndent: 14,
      color: AppColors.neutral[400],
    );
  }
}
