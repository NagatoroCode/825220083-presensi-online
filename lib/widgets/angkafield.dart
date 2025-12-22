import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Angkafield extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? inputType;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters; // 🔹 Tambahkan ini

  const Angkafield({
    super.key,
    required this.controller,
    required this.label,
    this.inputType,
    this.maxLines = 1,
    this.inputFormatters, // 🔹 Tambahkan ini juga di constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      inputFormatters: inputFormatters, // 🔹 Jangan lupa pakai di sini
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
      ),
    );
  }
}
