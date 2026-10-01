import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import '../services/media_service.dart';

IconData iconForName(String name) {
  try {
    final decoded = jsonDecode(name);
    if (decoded is Map<String, dynamic>) {
      return deserializeIcon(decoded)?.data ?? Icons.extension_rounded;
    }
  } catch (_) {
    // Older records contain only the icon name.
  }
  return Icons.extension_rounded;
}

String iconLabel(String value) {
  try {
    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) {
      return decoded['key'] as String? ?? value;
    }
  } catch (_) {
    // Older records contain plain icon names.
  }
  return value;
}

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
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFC7CFCE)),
    ),
    child: Column(
      children: [
        if (_url != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _url!,
              width: 110,
              height: 78,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: _busy ? null : _pick,
          icon: const Icon(Icons.file_upload_outlined, size: 18),
          label: Text(_busy ? 'Uploading...' : 'Upload image'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2B2D2C),
            side: const BorderSide(color: Color(0xFFC7CFCE)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _url == null ? 'Choose an image' : 'Replace image',
          style: const TextStyle(fontSize: 11, color: Color(0xFF637371)),
        ),
        const Text(
          'JPG, JPEG, PNG, WEBP.',
          style: TextStyle(fontSize: 10, color: Color(0xFF9EA7A6)),
        ),
      ],
    ),
  );
}

class IconPickerField extends StatefulWidget {
  const IconPickerField({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<IconPickerField> createState() => _IconPickerFieldState();
}

class _IconPickerFieldState extends State<IconPickerField> {
  Future<void> _openPicker() async {
    final selected = await showIconPicker(
      context,
      configuration: SinglePickerConfiguration(
        adaptiveDialog: true,
        showSearchBar: true,
        title: const Text('Choose an icon'),
        searchHintText: 'Search icons',
        iconPackModes: const [IconPack.allMaterial, IconPack.fontAwesomeIcons],
        iconPickerShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxWidth: double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
      ),
    );

    if (selected != null && mounted) {
      widget.onChanged(jsonEncode(serializeIcon(selected)));
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: _openPicker,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC7CFCE)),
      ),
      child: Row(
        children: [
          Icon(
            iconForName(widget.value),
            size: 20,
            color: const Color(0xFF637371),
          ),
          const SizedBox(width: 12),
          Text(
            widget.value.isEmpty ? 'Pick an icon' : iconLabel(widget.value),
            style: TextStyle(
              color:
                  widget.value.isEmpty
                      ? const Color(0xFF9EA7A6)
                      : const Color(0xFF444645),
              fontSize: 13.5,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Color(0xFF637371),
          ),
        ],
      ),
    ),
  );
}
