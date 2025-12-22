import 'package:flutter/material.dart';
import 'package:aplikasiabsensi/auth/auth_service.dart';
import 'package:aplikasiabsensi/pages/login_page.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/widgets/fotoProfile.dart'; // widget foto profil
import 'package:aplikasiabsensi/widgets/Profile/karyawan_profile.dart'; // menu karyawan

class ProfileKaryawanPage extends StatefulWidget {
  final dataKaryawan? karyawan;

  const ProfileKaryawanPage({super.key, this.karyawan});

  @override
  State<ProfileKaryawanPage> createState() => _ProfileKaryawanPageState();
}

class _ProfileKaryawanPageState extends State<ProfileKaryawanPage> {
  final AuthService authService = AuthService();
  final fotoProfileController fotoController = fotoProfileController();

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
    // Set foto profil jika tersedia
    if (widget.karyawan?.fotoProfil != null &&
        widget.karyawan!.fotoProfil!.isNotEmpty) {
      fotoController.setImage(widget.karyawan!.fotoProfil!);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header profil
            Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Fotoprofile(size: 70, controller: fotoController),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.karyawan?.namaLengkap ?? "-",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20, // 🔹 ukuran besar
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.karyawan?.jabatan?.namaJabatan ?? "-",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Menu Karyawan
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  KaryawanMenuCard(
                    onLogout: () => logout(context),
                    karyawan: widget.karyawan,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
