import 'package:aplikasiabsensi/pages/forgotPassword.dart';
import 'package:flutter/material.dart';

class OwnerMenuCard extends StatelessWidget {
  final VoidCallback onLogout;

  const OwnerMenuCard({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(Icons.lock_outline, color: Colors.black54),
            title: const Text(
              "Ganti Password",
              style: TextStyle(color: Colors.black87),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Forgotpassword()),
              );
            },
          ),
          const Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFE0E0E0),
          ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
