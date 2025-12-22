import 'package:aplikasiabsensi/auth/auth_service.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/widgets/bottom_navigation.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_error.dart';
import 'package:aplikasiabsensi/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();
  final DatakaryawanDatabase dbKaryawan = DatakaryawanDatabase();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      // Proses login
      await authService.signInWithEmailAndPassword(email, password);
      await Supabase.instance.client.auth.refreshSession();

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        showErrorLoginPopup(context, "Login Gagal", "User tidak ditemukan.");
        return;
      }

      // Ambil role
      final userData = await Supabase.instance.client
          .from('User')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = userData?['role'] as String?;
      if (role == null) {
        if (!mounted) return;
        showErrorLoginPopup(
          context,
          "Login Gagal",
          "Role user tidak ditemukan.",
        );
        return;
      }

      // Jika owner
      if (role == 'owner') {
        if (!mounted) return;
        Get.offAll(() => MenuNavigationBar(role: role));
        return;
      }

      // Ambil data karyawan
      final response = await Supabase.instance.client
          .from('dataKaryawan')
          .select('*, jenisJabatan(*), jenisPTKP(*)')
          .eq('userID', user.id)
          .maybeSingle();

      if (response == null) {
        if (!mounted) return;
        showErrorLoginPopup(
          context,
          "Login Gagal",
          "Data karyawan tidak ditemukan di database.",
        );
        return;
      }

      final karyawanData = dataKaryawan.fromMap(response);

      if (!mounted) return;
      Get.offAll(() => MenuNavigationBar(role: role, karyawan: karyawanData));
    } on AuthException catch (_) {
      // ⛔ Khusus error email/password salah
      if (!mounted) return;
      showErrorLoginPopup(context, "Login Gagal", "Email atau password salah.");
    } catch (e) {
      // Error lain
      if (!mounted) return;
      showErrorLoginPopup(context, "Login Gagal", "Terjadi kesalahan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Halaman Login')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight * 0.9),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.07,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: screenHeight * 0.25,
                            child: Image.asset(
                              'assets/images/login.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          const Text(
                            'Login Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                            ),
                            obscureText: true,
                            maxLength: 30,
                          ),
                          const SizedBox(height: 8.0),

                          SizedBox(height: screenHeight * 0.03),

                          // Button
                          CustomButton(
                            text: "Login",
                            onPressed: () {
                              if (_emailController.text.isEmpty ||
                                  _passwordController.text.isEmpty) {
                                showErrorLoginPopup(
                                  context,
                                  "Login Gagal",
                                  "Mohon masukkan email dan password.",
                                );
                              } else {
                                login();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Container(
                    width: double.infinity,
                    color: Colors.grey[350],
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Copyright @2025, All Rights Reserved\nPowered by Viva Shops',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
