import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Profile/dataKaryawan_page.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Profile/karyawanPribadi_page.dart';
import 'package:aplikasiabsensi/pages/forgotPassword.dart';
import 'package:flutter/material.dart';

class KaryawanMenuCard extends StatefulWidget {
  final VoidCallback onLogout;
  final dataKaryawan? karyawan;

  const KaryawanMenuCard({super.key, required this.onLogout, this.karyawan});

  @override
  State<KaryawanMenuCard> createState() => _KaryawanMenuCardState();
}

class _KaryawanMenuCardState extends State<KaryawanMenuCard> {
  late dataKaryawan? _karyawan;

  @override
  void initState() {
    super.initState();
    _karyawan = widget.karyawan;
  }

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
            leading: const Icon(Icons.badge_outlined, color: Colors.black54),
            title: const Text(
              "Profil Karyawan",
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
                MaterialPageRoute(
                  builder: (context) => DatakaryawanPage(karyawan: _karyawan),
                ),
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
            leading: const Icon(Icons.person_outline, color: Colors.black54),
            title: const Text(
              "Data Pribadi",
              style: TextStyle(color: Colors.black87),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
            onTap: () async {
              final updatedData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      KaryawanpribadiPage(karyawan: _karyawan),
                ),
              );

              if (updatedData != null && mounted) {
                setState(() {
                  _karyawan = updatedData;
                });
              }
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
            onTap: widget.onLogout,
          ),
        ],
      ),
    );
  }
}
