import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../models/machine_model.dart';
import '../../shared/field_label.dart';
import '../../shared/input_decoration.dart';
import '../../shared/section_card.dart';

class NewMachineScreen extends StatefulWidget {
  const NewMachineScreen({super.key});

  @override
  State<NewMachineScreen> createState() => _NewMachineScreenState();
}

class _NewMachineScreenState extends State<NewMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tierController = TextEditingController(text: 'STANDARD');
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  String _selectedCategory = 'Washers';
  final List<String> _categories = ['Washers', 'Dryers'];

  @override
  void dispose() {
    _nameController.dispose();
    _tierController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveMachine() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      // Build the MachineItem model instance
      final newMachine = MachineItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        count: int.parse(_quantityController.text.trim()),
        tier: _tierController.text.trim(),
        type:
            _selectedCategory == 'Dryers'
                ? MachineType.dryer
                : MachineType.washer,
        note: _notesController.text.trim(),
      );

      Navigator.of(context).pop(newMachine);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary[100],
      appBar: AppBar(
        title: Text(
          'New Machine',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary[900],
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
                    SectionCard(
                      stepNumber: '1',
                      title: 'BASIC INFORMATION',
                      padding: const EdgeInsets.all(16),
                      borderRadius: 14,
                      shadowOpacity: 0.02,
                      shadowOffset: const Offset(0, 3),
                      titleFontSize: 11.5,
                      titleColor: const Color(0xFF454746),
                      titleLetterSpacing: 0,
                      contentSpacing: 14,
                      children: [
                        const FieldLabel(label: 'NAME', letterSpacing: 0),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          style: theme.textTheme.bodyMedium,
                          decoration: appInputDecoration(
                            hintText: 'e.g. LG Titan Washer',
                            prefixIcon: const SizedBox(
                              width: 48,
                              child: Center(
                                child: Text(
                                  'Aa',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6B7270),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          validator:
                              (val) =>
                                  val == null || val.trim().isEmpty
                                      ? 'Please enter machine name'
                                      : null,
                        ),
                        const SizedBox(height: 8),
                        const FieldLabel(
                          label: 'MACHINE TYPE',
                          letterSpacing: 0,
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items:
                              _categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                          decoration: appInputDecoration(
                            prefixIcon: Icon(
                              Icons.category_rounded,
                              size: 20,
                              color: AppColors.secondary[500],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const FieldLabel(label: 'TIER', letterSpacing: 0),
                        TextFormField(
                          controller: _tierController,
                          textInputAction: TextInputAction.next,
                          decoration: appInputDecoration(
                            hintText: 'e.g. STANDARD or PLUS+',
                            prefixIcon: const Icon(
                              Icons.sell_outlined,
                              size: 20,
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Please enter machine tier'
                                      : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SectionCard(
                      stepNumber: '2',
                      title: 'QUANTITY',
                      padding: const EdgeInsets.all(16),
                      borderRadius: 14,
                      shadowOpacity: 0.02,
                      shadowOffset: const Offset(0, 3),
                      titleFontSize: 11.5,
                      titleColor: const Color(0xFF454746),
                      titleLetterSpacing: 0,
                      contentSpacing: 14,
                      children: [
                        const FieldLabel(
                          label: 'MACHINE COUNT',
                          letterSpacing: 0,
                        ),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: appInputDecoration(
                            hintText: '1',
                            prefixIcon: const Icon(
                              Icons.dialpad_rounded,
                              size: 20,
                            ),
                          ),
                          validator: (value) {
                            final quantity = int.tryParse(value?.trim() ?? '');
                            return quantity == null || quantity < 1
                                ? 'Enter a quantity of at least 1'
                                : null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 2. APPEARANCE ---
                    SectionCard(
                      stepNumber: '3',
                      title: 'APPEARANCE',
                      padding: const EdgeInsets.all(16),
                      borderRadius: 14,
                      shadowOpacity: 0.02,
                      shadowOffset: const Offset(0, 3),
                      titleFontSize: 11.5,
                      titleColor: const Color(0xFF454746),
                      titleLetterSpacing: 0,
                      contentSpacing: 14,
                      children: [
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.neutral[600]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.sentiment_satisfied_alt_rounded,
                                  size: 20,
                                  color: AppColors.secondary[600],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Pick an icon',
                                    style: TextStyle(
                                      color: AppColors.secondary[300],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: AppColors.secondary[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.neutral[500]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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

                    // --- 3. OPTIONAL ---
                    SectionCard(
                      stepNumber: '4',
                      title: 'OPTIONAL',
                      padding: const EdgeInsets.all(16),
                      borderRadius: 14,
                      shadowOpacity: 0.02,
                      shadowOffset: const Offset(0, 3),
                      titleFontSize: 11.5,
                      titleColor: const Color(0xFF454746),
                      titleLetterSpacing: 0,
                      contentSpacing: 14,
                      children: [
                        const FieldLabel(label: 'NOTES', letterSpacing: 0),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          style: theme.textTheme.bodyMedium,
                          decoration: appInputDecoration(
                            hintText: 'Write your text here...',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save Action Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveMachine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Save Machine'),
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
