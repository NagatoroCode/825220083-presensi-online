import 'package:aplikasiabsensi/auth/auth_service.dart';
import 'package:aplikasiabsensi/pages/login_page.dart';
import 'package:aplikasiabsensi/widgets/Profile/owner_profile.dart';
import 'package:aplikasiabsensi/widgets/fotoProfile.dart';
import 'package:flutter/material.dart';

class ProfileOwnerPage extends StatelessWidget {
  final AuthService authService = AuthService();
  final fotoProfileController fotoController = fotoProfileController();

  ProfileOwnerPage({super.key});

  void logout(BuildContext context) async {
    await authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Fotoprofile(size: 70, controller: fotoController),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "VINCENT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "PEMILIK TOKO",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      SizedBox(height: 2),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [OwnerMenuCard(onLogout: () => logout(context))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
