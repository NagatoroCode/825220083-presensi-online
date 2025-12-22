import 'dart:io';
import 'package:aplikasiabsensi/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/roleUser_database.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/widgets/fieldInputFoto.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:aplikasiabsensi/widgets/popupkonfirmasi.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_error.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_succses.dart';

class KaryawanpribadiPage extends StatefulWidget {
  final dataKaryawan? karyawan;

  const KaryawanpribadiPage({super.key, this.karyawan});

  @override
  State<KaryawanpribadiPage> createState() => _KaryawanpribadiPageState();
}

class _KaryawanpribadiPageState extends State<KaryawanpribadiPage> {
  final karyawanDB = DatakaryawanDatabase();
  final roleDB = RoleDatabase();
  final picker = ImagePicker();

  late TextEditingController namaController;
  late TextEditingController alamatController;
  late TextEditingController teleponController;

  File? _imageFile;
  bool removePhoto = false;

  @override
  void initState() {
    super.initState();

    namaController = TextEditingController(
      text: widget.karyawan?.namaLengkap ?? '',
    );
    alamatController = TextEditingController(
      text: widget.karyawan?.alamat ?? '',
    );
    teleponController = TextEditingController(
      text: widget.karyawan?.nomorTelepon ?? '',
    );
  }

  Future<void> _pickPhoto() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        removePhoto = false;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _imageFile = null;
      removePhoto = true;
    });
  }

  Future<String?> _uploadPhoto(File file) async {
    try {
      final supabase = Supabase.instance.client;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Foto_Profile/$timestamp-${file.path.split('/').last}';

      await supabase.storage
          .from('Aplikasi_Absensi')
          .uploadBinary(
            fileName,
            await file.readAsBytes(),
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage
          .from('Aplikasi_Absensi')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print("Gagal upload foto: $e");
      return null;
    }
  }

  Future<void> updateDataPribadi() async {
    try {
      if (widget.karyawan == null) return;

      final roleKaryawan = await roleDB.getRoleByName("Karyawan");
      if (roleKaryawan == null) {
        throw Exception("Role 'Karyawan' tidak ditemukan di database");
      }

      String? fotoUrl = widget.karyawan!.fotoProfil;

      if (_imageFile != null) {
        final uploadedUrl = await _uploadPhoto(_imageFile!);
        if (uploadedUrl != null) fotoUrl = uploadedUrl;
      } else if (removePhoto) {
        fotoUrl = '';
      }

      final updated = dataKaryawan(
        karyawanID: widget.karyawan!.karyawanID,
        userID: widget.karyawan!.userID,
        namaLengkap: namaController.text,
        nomorTelepon: teleponController.text,
        alamat: alamatController.text,
        jabatanID: widget.karyawan!.jabatanID,
        ptkpID: widget.karyawan!.ptkpID,
        status: widget.karyawan!.status,
        gajiPokok: widget.karyawan!.gajiPokok,
        uangMakan: widget.karyawan!.uangMakan,
        fotoProfil: fotoUrl,
      );

      await karyawanDB.updateKaryawan(updated);

      // ✅ Popup sukses, halaman ditutup setelah tekan OK
      showSuccsesLoginPopup(
        context,
        "Berhasil",
        "Data pribadi berhasil diperbarui",
        onClose: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context, updated);
          }
        },
      );
    } catch (e) {
      showErrorLoginPopup(context, "Gagal", "Terjadi kesalahan: $e");
    }
  }

  void _confirmUpdate() {
    showDialog(
      context: context,
      builder: (context) => Popupkonfirmasi(
        title: "Konfirmasi Perubahan",
        message: "Apakah Anda yakin ingin menyimpan perubahan data pribadi?",
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);
          updateDataPribadi();
        },
      ),
    );
  }

  ImageProvider<Object> profileImage() {
    if (_imageFile != null) return FileImage(_imageFile!);
    if (!removePhoto &&
        widget.karyawan?.fotoProfil != null &&
        widget.karyawan!.fotoProfil!.isNotEmpty) {
      final path = widget.karyawan!.fotoProfil!;
      if (path.startsWith('http')) return NetworkImage(path);
      final bucket = 'Aplikasi_Absensi';
      final fullPath = 'Foto_Profile/$path';
      final publicUrl = Supabase.instance.client.storage
          .from(bucket)
          .getPublicUrl(fullPath);
      return NetworkImage(publicUrl);
    }
    return const AssetImage('assets/images/avatar.png');
  }

  @override
  Widget build(BuildContext context) {
    final isDataAda = widget.karyawan != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Profile Data Pribadi')),
      body: isDataAda
          ? GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        "Nama Lengkap",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      CustomTextField(
                        controller: namaController,
                        label: "Nama Lengkap",
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Foto Profil",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      PhotoPickerField(
                        imageFile: _imageFile,
                        existingPhotoUrl: removePhoto
                            ? null
                            : widget.karyawan!.fotoProfil,
                        onPickPhoto: _pickPhoto,
                        onRemovePhoto: _removePhoto,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Alamat",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      CustomTextField(
                        controller: alamatController,
                        label: "Alamat",
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Nomor Telepon",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      CustomTextField(
                        controller: teleponController,
                        label: "Nomor Telepon",
                        inputType: TextInputType.phone,
                      ),
                      const SizedBox(height: 36),
                      CustomButton(
                        text: "Simpan Data Pribadi",
                        onPressed: _confirmUpdate,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const Center(
              child: Text(
                "Tidak ada data karyawan untuk ditampilkan",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
    );
  }
}
