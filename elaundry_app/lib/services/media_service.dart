import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Picks an image and stores it in the current store's media folder.
class MediaService {
  MediaService({FirebaseStorage? storage, ImagePicker? picker})
    : _storage = storage ?? FirebaseStorage.instance,
      _picker = picker ?? ImagePicker();

  final FirebaseStorage _storage;
  final ImagePicker _picker;

  Future<String?> pickAndUpload({
    required String folder,
    ImageSource source = ImageSource.gallery,
  }) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final name = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final reference = _storage.ref('$folder/$name');
    await reference
        .putData(
          Uint8List.fromList(bytes),
          SettableMetadata(contentType: _contentType(file.name)),
        )
        .timeout(const Duration(seconds: 30));
    return reference.getDownloadURL().timeout(const Duration(seconds: 15));
  }

  String _contentType(String name) {
    final extension = name.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}
