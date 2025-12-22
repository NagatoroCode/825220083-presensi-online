import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void showSuccsesLoginPopup(
  BuildContext context,
  String judul,
  String message, {
  VoidCallback? onClose,
}) {
  Alert(
    context: context,
    type: AlertType.success,
    title: judul,
    desc: message,
    buttons: [
      DialogButton(
        child: const Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        onPressed: () {
          Navigator.pop(context);
          if (onClose != null) onClose();
        },
        width: 100,
      ),
    ],
  ).show();
}
