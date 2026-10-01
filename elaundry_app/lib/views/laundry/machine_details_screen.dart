import 'package:flutter/material.dart';

import '../../core/themes/theme.dart';
import '../../models/machine_model.dart';
import '../../shared/field_label.dart';
import '../../shared/section_card.dart';
import 'edit_machine_screen.dart';

class MachineDetailsScreen extends StatefulWidget {
  final MachineItem machine;

  const MachineDetailsScreen({super.key, required this.machine});

  @override
  State<MachineDetailsScreen> createState() => _MachineDetailsScreenState();
}

class _MachineDetailsScreenState extends State<MachineDetailsScreen> {
  late MachineItem _machine;

  @override
  void initState() {
    super.initState();
    _machine = widget.machine;
  }

  Future<void> _editMachine() async {
    final updated = await Navigator.of(context).push<MachineItem>(
      MaterialPageRoute(
        builder: (context) => EditMachineScreen(machine: _machine),
      ),
    );
    if (updated != null) setState(() => _machine = updated);
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Delete machine?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Remove "${_machine.name}" from this store?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondary[600],
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: AppColors.neutral[400], height: 1),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC7C9C8),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );

    if (shouldDelete == true && mounted) {
      Navigator.of(context).pop('deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageBackground = AppColors.primary[100]!;

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        title: Text(
          _machine.name,
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
          onPressed: () => Navigator.of(context).pop(_machine),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _editMachine();
              if (value == 'delete') _confirmDelete();
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit Machine'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete Machine'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: pageBackground,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(_machine),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppColors.neutral[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _editMachine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionCard(
                    stepNumber: '1',
                    title: 'MACHINE DETAILS',
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
                      _DetailValue(value: _machine.name),
                      const SizedBox(height: 12),
                      const FieldLabel(label: 'MACHINE TYPE', letterSpacing: 0),
                      _DetailValue(value: _typeLabel(_machine.type)),
                      const SizedBox(height: 12),
                      const FieldLabel(label: 'TIER', letterSpacing: 0),
                      _DetailValue(value: _machine.tier),
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
                      _DetailValue(value: _machine.count.toString()),
                      const SizedBox(height: 12),
                      const FieldLabel(label: 'STATUS', letterSpacing: 0),
                      _DetailValue(
                        value:
                            _machine.isAvailable ? 'Available' : 'Unavailable',
                      ),
                    ],
                  ),
                  if (_machine.note.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SectionCard(
                      stepNumber: '3',
                      title: 'NOTES',
                      padding: const EdgeInsets.all(16),
                      borderRadius: 14,
                      shadowOpacity: 0.02,
                      shadowOffset: const Offset(0, 3),
                      titleFontSize: 11.5,
                      titleColor: const Color(0xFF454746),
                      titleLetterSpacing: 0,
                      contentSpacing: 14,
                      children: [_DetailValue(value: _machine.note)],
                    ),
                  ],
                ],
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

class _DetailValue extends StatelessWidget {
  final String value;

  const _DetailValue({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral[500]!),
      ),
      child: Text(value, style: const TextStyle(color: Color(0xFF2C2D2D))),
    );
  }
}
