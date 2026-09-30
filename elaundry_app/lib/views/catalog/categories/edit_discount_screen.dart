import 'package:flutter/material.dart';

import '../../../core/themes/theme.dart';
import '../../../models/catalog_models.dart';
import '../../../shared/field_label.dart';
import '../../../shared/input_decoration.dart';
import '../widgets/catalog_section_card.dart';

class EditDiscountScreen extends StatefulWidget {
  final CatalogCategory? categoryToEdit;

  const EditDiscountScreen({super.key, this.categoryToEdit});

  @override
  State<EditDiscountScreen> createState() => _EditDiscountScreenState();
}

class _EditDiscountScreenState extends State<EditDiscountScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _minQtyController;
  late final TextEditingController _minWeightController;
  late final TextEditingController _minSpendController;
  late final TextEditingController _notesController;

  // 1. Discount Type ('Percentage' or 'Fixed')
  String _discountType = 'Percentage';
  final List<String> _discountTypes = ['Percentage', 'Fixed'];

  // 2. Applied Items selection
  final List<String> _availableItems = [
    'Regular Wash',
    'Dry Clean',
    'Heavy Comforter',
    'Iron & Fold',
    'Shoe Cleaning',
  ];
  final Set<String> _selectedItems = {};

  // 3. Validity Date
  DateTime? _validityDate;

  bool get _isEditing => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.categoryToEdit?.name ?? '',
    );
    _amountController = TextEditingController(text: '0');
    _minQtyController = TextEditingController(text: '0');
    _minWeightController = TextEditingController(text: '0');
    _minSpendController = TextEditingController(text: '0');
    _notesController = TextEditingController(
      text: widget.categoryToEdit?.note ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _minQtyController.dispose();
    _minWeightController.dispose();
    _minSpendController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- Date Picker Logic ---
  Future<void> _pickValidityDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _validityDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF2C2D2D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() => _validityDate = pickedDate);
    }
  }

  // --- Applied To Multi-Select Modal with "Select All" ---
  void _showAppliedToModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isAllSelected =
                _selectedItems.length == _availableItems.length;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Applied To Items',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C2D2D),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    // "Select All" Option
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.accent,
                      title: const Text(
                        'Select All',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C2D2D),
                        ),
                      ),
                      value: isAllSelected,
                      onChanged: (val) {
                        setModalState(() {
                          if (val == true) {
                            _selectedItems.addAll(_availableItems);
                          } else {
                            _selectedItems.clear();
                          }
                        });
                        setState(() {});
                      },
                    ),
                    const Divider(height: 1),
                    // Individual Items Checklist
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availableItems.length,
                        itemBuilder: (context, index) {
                          final item = _availableItems[index];
                          final isChecked = _selectedItems.contains(item);

                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.accent,
                            title: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF333534),
                              ),
                            ),
                            value: isChecked,
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  _selectedItems.add(item);
                                } else {
                                  _selectedItems.remove(item);
                                }
                              });
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final savedDiscount = CatalogCategory(
        id:
            widget.categoryToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        quantity: 1,
        minSpend: 'Min. Spend P${_minSpendController.text.trim()}',
        isDiscount: true,
        note: _notesController.text.trim(),
      );

      Navigator.of(context).pop(savedDiscount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = AppColors.primary[100]!;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Discount' : 'New Discount',
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
                          label: 'DISCOUNT NAME',
                          letterSpacing: 0,
                        ),
                        TextFormField(
                          controller: _nameController,
                          decoration: appInputDecoration(hintText: '10% off'),
                          validator:
                              (val) =>
                                  val == null || val.trim().isEmpty
                                      ? 'Enter discount name'
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

                    // --- 3. SCOPE & CONDITIONS ---
                    CatalogSectionCard(
                      stepNumber: '3',
                      title: 'SCOPE & CONDITIONS',
                      children: [
                        Row(
                          children: [
                            // TYPE: Percentage or Fixed
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FieldLabel(
                                    label: 'TYPE',
                                    letterSpacing: 0,
                                  ),
                                  DropdownButtonFormField<String>(
                                    value: _discountType,
                                    items:
                                        _discountTypes
                                            .map(
                                              (type) => DropdownMenuItem(
                                                value: type,
                                                child: Text(
                                                  type,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF2C2D2D),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _discountType = val);
                                      }
                                    },
                                    decoration: appInputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.settings_outlined,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // AMOUNT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FieldLabel(
                                    label: 'AMOUNT',
                                    letterSpacing: 0,
                                  ),
                                  TextFormField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: appInputDecoration(
                                      hintText: '0',
                                      prefixIcon: Icon(
                                        _discountType == 'Percentage'
                                            ? Icons.percent_rounded
                                            : Icons.sell_outlined,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // APPLIED TO: Multi-select Modal Trigger
                        const FieldLabel(label: 'APPLIED TO', letterSpacing: 0),
                        InkWell(
                          onTap: _showAppliedToModal,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                  Icons.category_outlined,
                                  size: 18,
                                  color: AppColors.secondary[600],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedItems.isEmpty
                                        ? 'Select items'
                                        : _selectedItems.length ==
                                            _availableItems.length
                                        ? 'All items selected'
                                        : '${_selectedItems.length} item(s) selected',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          _selectedItems.isEmpty
                                              ? AppColors.secondary[300]
                                              : const Color(0xFF2C2D2D),
                                      fontSize: 13,
                                      fontWeight:
                                          _selectedItems.isEmpty
                                              ? FontWeight.w400
                                              : FontWeight.w500,
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
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FieldLabel(
                                    label: 'MIN ITEM QTY',
                                    letterSpacing: 0,
                                  ),
                                  TextFormField(
                                    controller: _minQtyController,
                                    keyboardType: TextInputType.number,
                                    decoration: appInputDecoration(
                                      hintText: '0',
                                      prefixIcon: const Icon(
                                        Icons.dialpad_rounded,
                                        size: 18,
                                      ),
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
                                    label: 'MIN SPEND',
                                    letterSpacing: 0,
                                  ),
                                  TextFormField(
                                    controller: _minSpendController,
                                    keyboardType: TextInputType.number,
                                    decoration: appInputDecoration(
                                      hintText: '0',
                                      prefixIcon: const Icon(
                                        Icons.sell_outlined,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // VALIDITY DATE: Date Picker Trigger
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FieldLabel(
                                    label: 'VALIDITY DATE',
                                    letterSpacing: 0,
                                  ),
                                  InkWell(
                                    onTap: _pickValidityDate,
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
                                            Icons.calendar_today_rounded,
                                            size: 17,
                                            color: AppColors.secondary[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _validityDate != null
                                                  ? '${_validityDate!.month.toString().padLeft(2, '0')}/${_validityDate!.day.toString().padLeft(2, '0')}/${_validityDate!.year}'
                                                  : 'Select Date',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color:
                                                    _validityDate != null
                                                        ? const Color(
                                                          0xFF2C2D2D,
                                                        )
                                                        : AppColors
                                                            .secondary[300],
                                                fontSize: 13,
                                                fontWeight:
                                                    _validityDate != null
                                                        ? FontWeight.w500
                                                        : FontWeight.w400,
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
