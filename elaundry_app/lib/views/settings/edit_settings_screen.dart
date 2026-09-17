import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/themes/theme.dart';

enum SettingFieldType { text, email, password, number, multiline }

class EditSettingsScreen extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final SettingFieldType fieldType;
  final int? maxLength;
  final String? helperText;

  const EditSettingsScreen({
    super.key,
    required this.title,
    required this.label,
    this.initialValue = '',
    this.fieldType = SettingFieldType.text,
    this.maxLength,
    this.helperText,
  });

  @override
  State<EditSettingsScreen> createState() => _EditSettingsScreenState();
}

class _EditSettingsScreenState extends State<EditSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _obscureText = widget.fieldType == SettingFieldType.password;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Text('${widget.title} updated successfully!'),
        ),
      );
      Navigator.of(context).pop(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dynamic keyboard and input rules
    TextInputType keyboardType;
    List<TextInputFormatter> formatters = [];

    switch (widget.fieldType) {
      case SettingFieldType.number:
        keyboardType = TextInputType.number;
        formatters = [
          FilteringTextInputFormatter.digitsOnly,
          if (widget.maxLength != null)
            LengthLimitingTextInputFormatter(widget.maxLength),
        ];
        break;
      case SettingFieldType.email:
        keyboardType = TextInputType.emailAddress;
        break;
      case SettingFieldType.multiline:
        keyboardType = TextInputType.multiline;
        break;
      default:
        keyboardType = TextInputType.text;
    }

    return Scaffold(
      backgroundColor: AppColors.neutral[400],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.secondary[900],
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title above the card
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.primary[900],
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                    ),

                    // Main Edit Card
                    Container(
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
                      padding: const EdgeInsets.all(20),
                      child: TextFormField(
                        controller: _controller,
                        keyboardType: keyboardType,
                        inputFormatters: formatters,
                        obscureText: _obscureText,
                        maxLines:
                            widget.fieldType == SettingFieldType.multiline
                                ? 3
                                : 1,
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Enter ${widget.label.toLowerCase()}',
                          hintStyle: TextStyle(color: AppColors.secondary[300]),
                          helperText: widget.helperText,
                          suffixIcon:
                              widget.fieldType == SettingFieldType.password
                                  ? IconButton(
                                    splashRadius: 20,
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                      color: AppColors.secondary[500],
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => _obscureText = !_obscureText,
                                      );
                                    },
                                  )
                                  : null,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field cannot be empty';
                          }
                          if (widget.fieldType == SettingFieldType.email &&
                              !value.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          if (widget.fieldType == SettingFieldType.number &&
                              widget.maxLength != null &&
                              value.length != widget.maxLength) {
                            return 'Must be exactly ${widget.maxLength} digits';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
