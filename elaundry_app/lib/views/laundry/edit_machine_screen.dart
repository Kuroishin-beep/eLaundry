import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../models/machine_model.dart';
import '../../shared/field_label.dart';
import '../../shared/input_decoration.dart';
import '../../shared/section_card.dart';
import '../../shared/media_picker.dart';

class EditMachineScreen extends StatefulWidget {
  final MachineItem machine;

  const EditMachineScreen({super.key, required this.machine});

  @override
  State<EditMachineScreen> createState() => _EditMachineScreenState();
}

class _EditMachineScreenState extends State<EditMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _tierController;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  late MachineType _selectedType;
  late bool _isAvailable;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.machine.name);
    _imageUrl = widget.machine.imageUrl;
    _tierController = TextEditingController(text: widget.machine.tier);
    _quantityController = TextEditingController(
      text: widget.machine.count.toString(),
    );
    _notesController = TextEditingController(text: widget.machine.note);
    _selectedType = widget.machine.type;
    _isAvailable = widget.machine.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tierController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(
      MachineItem(
        id: widget.machine.id,
        name: _nameController.text.trim(),
        count: int.parse(_quantityController.text.trim()),
        tier: _tierController.text.trim(),
        type: _selectedType,
        isAvailable: _isAvailable,
        note: _notesController.text.trim(),
        imageUrl: _imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageBackground = AppColors.primary[100]!;

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        title: const Text(
          'Edit Machine',
          style: TextStyle(
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
          color: pageBackground,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save Changes'),
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
                    ImageUploadField(
                      folder: 'entities',
                      initialUrl: _imageUrl,
                      onChanged: (value) => _imageUrl = value,
                    ),
                    const SizedBox(height: 12),
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
                              (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Please enter machine name'
                                      : null,
                        ),

                        const SizedBox(height: 12),

                        const FieldLabel(
                          label: 'MACHINE TYPE',
                          letterSpacing: 0,
                        ),
                        DropdownButtonFormField<MachineType>(
                          value: _selectedType,
                          items:
                              MachineType.values
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(_typeLabel(type)),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedType = value);
                            }
                          },
                          decoration: appInputDecoration(
                            prefixIcon: const Icon(
                              Icons.local_laundry_service_rounded,
                              size: 20,
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
                      title: 'QUANTITY & STATUS',
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
                            final count = int.tryParse(value?.trim() ?? '');
                            return count == null || count < 1
                                ? 'Enter a quantity of at least 1'
                                : null;
                          },
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Available'),
                          value: _isAvailable,
                          activeTrackColor: AppColors.accent,
                          onChanged:
                              (value) => setState(() => _isAvailable = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      stepNumber: '3',
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

  String _typeLabel(MachineType type) =>
      type == MachineType.washer ? 'Washer' : 'Dryer';
}
