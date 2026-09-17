import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../models/machine_model.dart';

class NewMachineScreen extends StatefulWidget {
  const NewMachineScreen({super.key});

  @override
  State<NewMachineScreen> createState() => _NewMachineScreenState();
}

class _NewMachineScreenState extends State<NewMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Washers';
  final List<String> _categories = ['Washers', 'Dryers', 'Services'];

  @override
  void dispose() {
    _nameController.dispose();
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
        count: 1,
        tier: 'STANDARD',
        type:
            _selectedCategory == 'Dryers'
                ? MachineType.dryer
                : MachineType.washer,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: const Text(
            'Machine successfully created!',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      // Return the created model back to MachinesScreen
      Navigator.of(context).pop(newMachine);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral[400],
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
                    _SectionCard(
                      stepNumber: '1',
                      stepTitle: 'BASIC INFORMATION',
                      children: [
                        Text(
                          'NAME',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.secondary[700],
                            fontSize: 11.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'e.g. LG Titan Washer',
                            hintStyle: TextStyle(
                              color: AppColors.secondary[300],
                            ),
                            prefixIcon: Container(
                              alignment: Alignment.center,
                              width: 32,
                              child: Text(
                                'Aa',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary[500],
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
                        const SizedBox(height: 16),
                        Text(
                          'CATEGORY',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.secondary[700],
                            fontSize: 11.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.category_rounded,
                              size: 20,
                              color: AppColors.secondary[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 2. APPEARANCE ---
                    _SectionCard(
                      stepNumber: '2',
                      stepTitle: 'APPEARANCE',
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
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: AppColors.primary[100]?.withValues(
                              alpha: 0.35,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary[400]!,
                              width: 1.2,
                              style: BorderStyle.solid,
                            ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.file_upload_outlined,
                                  size: 18,
                                  color: AppColors.secondary[800],
                                ),
                                label: Text(
                                  'Upload image',
                                  style: TextStyle(
                                    color: AppColors.secondary[900],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Choose an image',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondary[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'JPG, JPEG, PNG, WEBP',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondary[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- 3. OPTIONAL ---
                    _SectionCard(
                      stepNumber: '3',
                      stepTitle: 'OPTIONAL',
                      children: [
                        Text(
                          'NOTES',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.secondary[700],
                            fontSize: 11.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Write your text here...',
                            hintStyle: TextStyle(
                              color: AppColors.secondary[300],
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

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

class _SectionCard extends StatelessWidget {
  final String stepNumber;
  final String stepTitle;
  final List<Widget> children;

  const _SectionCard({
    required this.stepNumber,
    required this.stepTitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                stepTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF444645),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
