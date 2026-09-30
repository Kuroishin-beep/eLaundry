import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/catalog_models.dart';
import '../../../shared/field_label.dart';
import '../../../shared/input_decoration.dart';
import '../widgets/catalog_section_card.dart';

class EditCategoryScreen extends StatefulWidget {
  final CatalogCategory? categoryToEdit;

  const EditCategoryScreen({super.key, this.categoryToEdit});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;

  bool get _isEditing => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.categoryToEdit?.name ?? '',
    );
    _notesController = TextEditingController(
      text: widget.categoryToEdit?.note ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final savedCat = CatalogCategory(
        id:
            widget.categoryToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        quantity: widget.categoryToEdit?.quantity ?? 0,
        note: _notesController.text.trim(),
      );

      Navigator.of(context).pop(savedCat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.primary[100]!;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Category' : 'New Category',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222423),
          ),
        ),
        centerTitle: true,
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 1. BASIC INFORMATION ---
                    CatalogSectionCard(
                      stepNumber: '1',
                      title: 'BASIC INFORMATION',
                      children: [
                        const FieldLabel(
                          label: 'CATEGORY NAME',
                          letterSpacing: 0,
                        ),
                        TextFormField(
                          controller: _nameController,
                          decoration: appInputDecoration(hintText: 'Soap'),
                          validator:
                              (val) =>
                                  val == null || val.trim().isEmpty
                                      ? 'Enter category name'
                                      : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 2. APPEARANCE ---
                    CatalogSectionCard(
                      stepNumber: '2',
                      title: 'APPEARANCE',
                      children: [
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.neutral[500]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sentiment_satisfied_alt_rounded,
                                size: 20,
                                color: AppColors.secondary[600],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Pick an icon',
                                style: TextStyle(
                                  color: AppColors.secondary[400],
                                  fontSize: 13.5,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: AppColors.secondary[400],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.neutral[500]!),
                          ),
                          child: Column(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: AppColors.neutral[600]!,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.file_upload_outlined,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Upload image',
                                  style: TextStyle(color: Color(0xFF2B2D2C)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Choose an image',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondary[600],
                                ),
                              ),
                              Text(
                                'JPG, JPEG, PNG, WEBP.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.secondary[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 4. OPTIONAL ---
                    CatalogSectionCard(
                      stepNumber: '4',
                      title: 'OPTIONAL',
                      children: [
                        const FieldLabel(label: 'NOTES', letterSpacing: 0),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: appInputDecoration(
                            hintText: 'Write your text here...',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(_isEditing ? 'Save Changes' : 'Save'),
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
