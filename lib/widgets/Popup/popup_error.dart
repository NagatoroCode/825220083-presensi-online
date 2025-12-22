import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void showErrorLoginPopup(BuildContext context, String judul, String message) {
  Alert(
    context: context,
    type: AlertType.error,
    title: judul,
    desc: message,
    buttons: [
      DialogButton(
        child: Text("OK", style: TextStyle(color: Colors.white, fontSize: 18)),
        onPressed: () => Navigator.pop(context),
        width: 100,
      ),
    ],
  ).show();
}
