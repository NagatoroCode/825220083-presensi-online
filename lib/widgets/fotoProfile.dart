import 'package:flutter/widgets.dart';

class fotoProfileController extends ChangeNotifier {
  String? _imageurl;
  String? get imageUrl => _imageurl;

  void setImage(String url) {
    _imageurl = url;
    notifyListeners();
  }
}

class Fotoprofile extends StatelessWidget {
  final double size;
  final fotoProfileController controller;
  final String placeholder;

  const Fotoprofile({
    super.key,
    required this.size,
    required this.controller,
    this.placeholder = 'assets/images/fotoOrang.png',
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: Transform.scale(
              scale: 1.5, // angka > 1 untuk zoom in
              child: controller.imageUrl != null
                  ? Image.network(controller.imageUrl!, fit: BoxFit.cover)
                  : Image.asset(placeholder, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }
}
