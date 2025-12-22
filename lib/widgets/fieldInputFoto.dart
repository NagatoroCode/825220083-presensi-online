import 'dart:io';
import 'package:flutter/material.dart';

class PhotoPickerField extends StatelessWidget {
  final File? imageFile;
  final String? existingPhotoUrl;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;

  const PhotoPickerField({
    super.key,
    required this.imageFile,
    this.existingPhotoUrl,
    required this.onPickPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (imageFile != null) {
      content = Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.file(imageFile!, fit: BoxFit.cover, height: 200),
            ),
          ),
          IconButton(
            onPressed: onRemovePhoto,
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      );
    } else if (existingPhotoUrl != null) {
      content = Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                existingPhotoUrl!,
                fit: BoxFit.cover,
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Text('Gagal memuat foto')),
              ),
            ),
          ),
          IconButton(
            onPressed: onRemovePhoto,
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      );
    } else {
      content = OutlinedButton.icon(
        onPressed: onPickPhoto,
        icon: const Icon(Icons.camera_alt),
        label: const Text("Ambil Foto"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return SizedBox(width: double.infinity, height: 200, child: content);
  }
}
