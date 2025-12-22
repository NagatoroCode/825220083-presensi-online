import 'package:aplikasiabsensi/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_succses.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_error.dart';
import 'package:aplikasiabsensi/widgets/popupKonfirmasi.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> changePassword() async {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirm = confirmController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      showErrorLoginPopup(context, "Gagal", "Semua field harus diisi.");
      return;
    }

    if (newPassword != confirm) {
      showErrorLoginPopup(
        context,
        "Gagal",
        "Password baru dan konfirmasi tidak cocok.",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null)
        throw Exception("Tidak ada sesi pengguna aktif.");

      // Re-login untuk verifikasi password lama
      final loginRes = await supabase.auth.signInWithPassword(
        email: currentUser.email!,
        password: oldPassword,
      );

      if (loginRes.session == null) {
        showErrorLoginPopup(context, "Gagal", "Password lama salah.");
        return;
      }

      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      await Supabase.instance.client
          .from('User')
          .update({'password': newPassword})
          .eq('userID', currentUser.id);

      if (!mounted) return;

      showSuccsesLoginPopup(
        context,
        "Berhasil",
        "Password berhasil diperbarui",
        onClose: () {
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showErrorLoginPopup(
        context,
        "Kesalahan",
        "Terjadi kesalahan saat mengubah password.\n$e",
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 🔔 Popup konfirmasi
  void showConfirmPopup() {
    showDialog(
      context: context,
      builder: (context) => Popupkonfirmasi(
        title: "Konfirmasi",
        message: "Apakah Anda yakin ingin mengubah password?",
        onCancel: () {
          Navigator.pop(context);
        },
        onConfirm: () {
          Navigator.pop(context);
          changePassword();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ganti Password")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ubah Password",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Masukkan password lama dan buat password baru.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // 🔒 Password lama
              CustomTextField(
                controller: oldPasswordController,
                label: "Password Lama",
                hint: "Masukkan password lama",
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // 🔑 Password baru
              CustomTextField(
                controller: newPasswordController,
                label: "Password Baru",
                hint: "Masukkan password baru",
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // 🔁 Konfirmasi password
              CustomTextField(
                controller: confirmController,
                label: "Konfirmasi Password",
                hint: "Ulangi password baru",
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // 🔘 Tombol ubah password pakai CustomButton
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Ubah Password",
                  isLoading: isLoading,
                  onPressed: showConfirmPopup,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
