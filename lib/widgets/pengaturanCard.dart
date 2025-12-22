import 'package:flutter/material.dart';

class pengaturanItem {
  final String title;
  final VoidCallback? onTap;

  pengaturanItem({required this.title, this.onTap});
}

class Pengaturancard extends StatelessWidget {
  final String title;
  final List<pengaturanItem> items;

  const Pengaturancard({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1A1D29),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Column(
            children: items.map((item) {
              return ListTile(
                title: Text(item.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: item.onTap,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
