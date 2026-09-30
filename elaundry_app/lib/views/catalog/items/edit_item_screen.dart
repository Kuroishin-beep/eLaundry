import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/catalog_models.dart';
import '../../../shared/field_label.dart';
import '../../../shared/input_decoration.dart';
import '../widgets/catalog_section_card.dart';

class EditItemScreen extends StatefulWidget {
  final CatalogItem? itemToEdit;
  final List<String> categoryOptions;
  final List<String> machineOptions;

  const EditItemScreen({
    super.key,
    this.itemToEdit,
    this.categoryOptions = const ['Services', 'Add-on'],
    this.machineOptions = const [],
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _qtyController;
  late final TextEditingController _minWeightController;
  late final TextEditingController _maxWeightController;
  late final TextEditingController _noteController;

  late String _selectedCategory;
  late String _selectedMachine;

  // Duration State
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  String get _formattedTime =>
      '${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}';

  bool get _isEditing => widget.itemToEdit != null;

  List<String> get _availableCategoryOptions {
    final options =
        widget.categoryOptions
            .where((category) => category.trim().isNotEmpty)
            .toSet()
            .toList();
    final currentCategory = widget.itemToEdit?.category;
    if (currentCategory != null &&
        currentCategory.isNotEmpty &&
        !options.contains(currentCategory)) {
      options.insert(0, currentCategory);
    }
    return options.isEmpty ? ['Services', 'Add-on'] : options;
  }

  List<String> get _availableMachineOptions {
    final options =
        widget.machineOptions
            .where((machine) => machine.trim().isNotEmpty)
            .toSet()
            .toList();
    final currentMachine = widget.itemToEdit?.machineType;
    if (currentMachine != null &&
        currentMachine.isNotEmpty &&
        !options.contains(currentMachine)) {
      options.insert(0, currentMachine);
    }
    return options;
  }

  bool get _hasMachineOptions =>
      widget.machineOptions.any((machine) => machine.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    final categories = _availableCategoryOptions;
    final machines = _availableMachineOptions;
    _selectedCategory =
        categories.contains(item?.category) ? item!.category : categories.first;
    _selectedMachine =
        machines.contains(item?.machineType)
            ? item!.machineType
            : machines.isNotEmpty
            ? machines.first
            : '';
    _nameController = TextEditingController(text: item?.name ?? '');
    _priceController = TextEditingController(
      text: item?.price.toString() ?? '0',
    );
    _qtyController = TextEditingController(
      text: item?.quantity.toString() ?? '1',
    );
    _minWeightController = TextEditingController(
      text: item?.minWeightKg.toString() ?? '0',
    );
    _maxWeightController = TextEditingController(
      text: item?.maxWeightKg.toString() ?? '0',
    );
    _noteController = TextEditingController(text: item?.note ?? '');
    final durationSeconds = item?.durationSeconds ?? 0;
    _hours = durationSeconds ~/ 3600;
    _minutes = (durationSeconds % 3600) ~/ 60;
    _seconds = durationSeconds % 60;
  }

  String? _validateNonNegativeNumber(String? value, String label) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || !number.isFinite || number < 0) {
      return 'Enter a valid $label';
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _minWeightController.dispose();
    _maxWeightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showDurationPicker() {
    int tempHours = _hours;
    int tempMinutes = _minutes;
    int tempSeconds = _seconds;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.secondary[600]),
                      ),
                    ),
                    const Text(
                      'Set Duration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2D2D),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _hours = tempHours;
                          _minutes = tempMinutes;
                          _seconds = tempSeconds;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Wheels Row (Hours : Minutes : Seconds)
                SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      // Hours Picker (0 - 23)
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Hours',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary[600],
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: FixedExtentScrollController(
                                  initialItem: _hours,
                                ),
                                itemExtent: 36,
                                onSelectedItemChanged: (val) => tempHours = val,
                                children: List.generate(
                                  24,
                                  (i) => Center(
                                    child: Text(
                                      i.toString().padLeft(2, '0'),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        ':',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Minutes Picker (0 - 59)
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Minutes',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary[600],
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: FixedExtentScrollController(
                                  initialItem: _minutes,
                                ),
                                itemExtent: 36,
                                onSelectedItemChanged:
                                    (val) => tempMinutes = val,
                                children: List.generate(
                                  60,
                                  (i) => Center(
                                    child: Text(
                                      i.toString().padLeft(2, '0'),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        ':',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Seconds Picker (0 - 59)
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Seconds',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary[600],
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: FixedExtentScrollController(
                                  initialItem: _seconds,
                                ),
                                itemExtent: 36,
                                onSelectedItemChanged:
                                    (val) => tempSeconds = val,
                                children: List.generate(
                                  60,
                                  (i) => Center(
                                    child: Text(
                                      i.toString().padLeft(2, '0'),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final savedItem = CatalogItem(
        id:
            widget.itemToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        machineType: _selectedMachine,
        price: double.parse(_priceController.text.trim()),
        quantity: int.parse(_qtyController.text.trim()),
        minWeightKg: double.parse(_minWeightController.text.trim()),
        maxWeightKg: double.parse(_maxWeightController.text.trim()),
        durationSeconds: _hours * 3600 + _minutes * 60 + _seconds,
        note: _noteController.text.trim(),
      );

      Navigator.of(context).pop(savedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.primary[100]!;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Item' : 'New Item',
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
                        const FieldLabel(label: 'ITEM NAME', letterSpacing: 0),
                        TextFormField(
                          controller: _nameController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: appInputDecoration(
                            hintText: 'Regular Wash',
                            prefixIcon: Container(
                              width: 48,
                              alignment: Alignment.center,
                              child: const Text(
                                'Aa',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B7270),
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                          validator:
                              (val) =>
                                  val == null || val.trim().isEmpty
                                      ? 'Enter item name'
                                      : null,
                        ),
                        const SizedBox(height: 14),
                        const FieldLabel(label: 'CATEGORY', letterSpacing: 0),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items:
                              _availableCategoryOptions
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => _selectedCategory = val!),
                          decoration: appInputDecoration(
                            prefixIcon: const Icon(
                              Icons.category_rounded,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const FieldLabel(label: 'MACHINE', letterSpacing: 0),
                        DropdownButtonFormField<String>(
                          value:
                              _selectedMachine.isEmpty
                                  ? null
                                  : _selectedMachine,
                          hint: Text(
                            _hasMachineOptions
                                ? 'Select a machine'
                                : 'No machines available',
                          ),
                          items:
                              _availableMachineOptions
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              _hasMachineOptions
                                  ? (val) {
                                    if (val != null) {
                                      setState(() => _selectedMachine = val);
                                    }
                                  }
                                  : null,
                          decoration: appInputDecoration(
                            prefixIcon: const Icon(
                              Icons.local_laundry_service_rounded,
                              size: 20,
                            ),
                          ),
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

                    // --- 3. PRICING & SPECIFICATIONS ---
                    CatalogSectionCard(
                      stepNumber: '3',
                      title: 'PRICING & SPECIFICATIONS',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FieldLabel(
                                    label: 'PRICE',
                                    letterSpacing: 0,
                                  ),
                                  TextFormField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    decoration: appInputDecoration(
                                      hintText: '0',
                                      prefixIcon: const Icon(
                                        Icons.sell_outlined,
                                        size: 18,
                                      ),
                                    ),
                                    validator:
                                        (value) => _validateNonNegativeNumber(
                                          value,
                                          'price',
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FieldLabel(
                                    label: 'QTY',
                                    letterSpacing: 0,
                                  ),
                                  TextFormField(
                                    controller: _qtyController,
                                    keyboardType: TextInputType.number,
                                    decoration: appInputDecoration(
                                      hintText: '1',
                                      prefixIcon: const Icon(
                                        Icons.dialpad_rounded,
                                        size: 18,
                                      ),
                                    ),
                                    validator: (value) {
                                      final quantity = int.tryParse(
                                        value?.trim() ?? '',
                                      );
                                      return quantity == null || quantity < 1
                                          ? 'Enter a quantity of at least 1'
                                          : null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FieldLabel(
                                    label: 'MIN WEIGHT',
                                    letterSpacing: 0,
                                  ),
                                  TextFormField(
                                    controller: _minWeightController,
                                    keyboardType: TextInputType.number,
                                    decoration: appInputDecoration(
                                      hintText: '0',
                                      prefixIcon: const Icon(
                                        Icons.scale_rounded,
                                        size: 18,
                                      ),
                                      suffixText: 'kg',
                                    ),
                                    validator:
                                        (value) => _validateNonNegativeNumber(
                                          value,
                                          'minimum weight',
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FieldLabel(
                                    label: 'MAX WEIGHT',
                                    letterSpacing: 0,
                                  ),
                                  TextFormField(
                                    controller: _maxWeightController,
                                    keyboardType: TextInputType.number,
                                    decoration: appInputDecoration(
                                      hintText: '0',
                                      prefixIcon: const Icon(
                                        Icons.scale_rounded,
                                        size: 18,
                                      ),
                                      suffixText: 'kg',
                                    ),
                                    validator: (value) {
                                      final maximum = double.tryParse(
                                        value?.trim() ?? '',
                                      );
                                      final minimum = double.tryParse(
                                        _minWeightController.text.trim(),
                                      );
                                      if (maximum == null ||
                                          !maximum.isFinite ||
                                          maximum < 0) {
                                        return 'Enter a valid maximum weight';
                                      }
                                      if (minimum != null &&
                                          maximum < minimum) {
                                        return 'Must be at least the minimum weight';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // DURATION (Hours:Minutes:Seconds Duration Picker)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FieldLabel(
                              label: 'DURATION',
                              letterSpacing: 0,
                            ),
                            InkWell(
                              onTap: _showDurationPicker,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.neutral[500]!,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 18,
                                      color: AppColors.secondary[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _formattedTime,
                                        style: TextStyle(
                                          color:
                                              _formattedTime == '00:00:00'
                                                  ? AppColors.secondary[300]
                                                  : const Color(0xFF2C2D2D),
                                          fontSize: 13,
                                          fontWeight:
                                              _formattedTime == '00:00:00'
                                                  ? FontWeight.w400
                                                  : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: AppColors.secondary[400],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                          controller: _noteController,
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
