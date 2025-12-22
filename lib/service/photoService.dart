import 'package:flutter/material.dart';

class PhotoService {
  static Widget buildPhotoBox(BuildContext context, String? photoUrl) {
    return GestureDetector(
      onTap: () {
        if (photoUrl != null && photoUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullscreenImageView(imageUrl: photoUrl),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: (photoUrl != null && photoUrl.isNotEmpty)
            ? Image.network(photoUrl, fit: BoxFit.cover)
            : Center(
                child: Text(
                  "Foto tidak tersedia",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
      ),
    );
  }
}

class FullscreenImageView extends StatelessWidget {
  final String imageUrl;
  const FullscreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.8,
          maxScale: 4,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
