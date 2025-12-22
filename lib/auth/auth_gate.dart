import 'package:aplikasiabsensi/auth/auth_service.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/pages/login_page.dart';
import 'package:aplikasiabsensi/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Session?>(
      stream: Supabase.instance.client.auth.onAuthStateChange.map(
        (event) => event.session,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data;

        if (session != null) {
          final userId = session.user.id;
          final karyawanDB = DatakaryawanDatabase();
          final authService = AuthService();

          return FutureBuilder<String?>(
            future: authService.getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasError || roleSnapshot.data == null) {
                return const Scaffold(
                  body: Center(child: Text('Gagal mengambil role user')),
                );
              }

              final role = roleSnapshot.data!;

              // 🔹 Jika role-nya Owner, langsung arahkan ke MenuNavigationBar
              if (role.toLowerCase() == 'owner') {
                return MenuNavigationBar(role: role);
              }

              // 🔹 Kalau bukan Owner, baru ambil dataKaryawan
              return FutureBuilder<dataKaryawan?>(
                future: karyawanDB.getKaryawanByUserId(userId),
                builder: (context, karyawanSnapshot) {
                  if (karyawanSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (karyawanSnapshot.hasError) {
                    return const Scaffold(
                      body: Center(
                        child: Text(
                          'Terjadi kesalahan mengambil data karyawan',
                        ),
                      ),
                    );
                  }

                  final karyawan = karyawanSnapshot.data;

                  if (karyawan == null) {
                    return const Scaffold(
                      body: Center(
                        child: Text('Data karyawan tidak ditemukan'),
                      ),
                    );
                  }

                  return MenuNavigationBar(role: role, karyawan: karyawan);
                },
              );
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
