import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/catalog_models.dart';
import '../../../shared/field_label.dart';
import '../../../shared/input_decoration.dart';
import '../widgets/catalog_section_card.dart';
import '../../../shared/media_picker.dart';

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
  String? _imageUrl;
  late String _iconName;

  bool get _isEditing => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.categoryToEdit?.name ?? '',
    );
    _imageUrl = widget.categoryToEdit?.imageUrl;
    _iconName = widget.categoryToEdit?.iconName ?? 'Inventory';
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
        imageUrl: _imageUrl,
        iconName: _iconName,
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: pageBgColor,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 50,
            width: double.infinity,
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
                        IconPickerField(
                          value: _iconName,
                          onChanged:
                              (value) => setState(() => _iconName = value),
                        ),
                        const SizedBox(height: 14),
                        ImageUploadField(
                          folder: 'entities',
                          initialUrl: _imageUrl,
                          onChanged: (value) => _imageUrl = value,
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
