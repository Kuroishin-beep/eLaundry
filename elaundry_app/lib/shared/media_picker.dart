import 'package:flutter/material.dart';
import '../services/media_service.dart';

const roleIconNames = <String>[
  'Point of Sale',
  'People',
  'Admin Panel Settings',
  'Local Laundry Service',
  'Inventory',
  'Assessment',
  'Security',
  'Support Agent',
];

IconData iconForName(String name) => switch (name) {
  'People' => Icons.people_alt_rounded,
  'Admin Panel Settings' => Icons.admin_panel_settings_rounded,
  'Local Laundry Service' => Icons.local_laundry_service_rounded,
  'Inventory' => Icons.inventory_2_rounded,
  'Assessment' => Icons.assessment_rounded,
  'Security' => Icons.security_rounded,
  'Support Agent' => Icons.support_agent_rounded,
  _ => Icons.point_of_sale_rounded,
};

class ImageUploadField extends StatefulWidget {
  const ImageUploadField({
    super.key,
    required this.folder,
    this.initialUrl,
    required this.onChanged,
    this.label = 'IMAGE',
  });
  final String folder;
  final String? initialUrl;
  final ValueChanged<String?> onChanged;
  final String label;

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  late String? _url = widget.initialUrl;
  bool _busy = false;

  Future<void> _pick() async {
    setState(() => _busy = true);
    try {
      final url = await MediaService().pickAndUpload(folder: widget.folder);
      if (url != null && mounted) {
        setState(() => _url = url);
        widget.onChanged(url);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: _busy ? null : _pick,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 72,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC7CFCE)),
      ),
      child: Row(
        children: [
          if (_url != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.network(
                _url!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            )
          else
            const Icon(Icons.add_photo_alternate_outlined, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_busy ? 'Uploading…' : 'Tap to upload ${widget.label}'),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}

class IconPickerField extends StatelessWidget {
  const IconPickerField({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final selected = await showDialog<String>(
        context: context,
        builder:
            (context) => SimpleDialog(
              title: const Text('Choose an icon'),
              children: [
                for (final name in roleIconNames)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, name),
                    child: Row(
                      children: [
                        Icon(iconForName(name)),
                        const SizedBox(width: 12),
                        Text(name),
                      ],
                    ),
                  ),
              ],
            ),
      );
      if (selected != null) onChanged(selected);
    },
    child: InputDecorator(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      child: Row(
        children: [
          Icon(iconForName(value)),
          const SizedBox(width: 12),
          Text(value),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}
