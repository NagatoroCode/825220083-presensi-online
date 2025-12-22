import 'dart:io';
import 'package:aplikasiabsensi/auth/auth_service.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/jabatan_database.dart';
import 'package:aplikasiabsensi/database/jenisPTKP_database.dart';
import 'package:aplikasiabsensi/database/user_database.dart';
import 'package:aplikasiabsensi/database/roleUser_database.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/model/jabatan.dart';
import 'package:aplikasiabsensi/model/jenisPTKP.dart';
import 'package:aplikasiabsensi/model/roleUser.dart';
import 'package:aplikasiabsensi/model/user.dart';
import 'package:aplikasiabsensi/widgets/angkafield.dart';
import 'package:aplikasiabsensi/widgets/dropdown.dart';
import 'package:aplikasiabsensi/widgets/fieldInputFoto.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahkaryawanPage extends StatefulWidget {
  const TambahkaryawanPage({super.key});

  @override
  State<TambahkaryawanPage> createState() => _TambahkaryawanPageState();
}

class _TambahkaryawanPageState extends State<TambahkaryawanPage> {
  final karyawanDB = DatakaryawanDatabase();
  final userDB = UserDatabase();
  final roleDB = RoleDatabase();
  final ptkpDB = JenisptkpDatabase();
  final jabatanDB = jabatanDatabase();

  final namaLengkapController = TextEditingController();
  final emailController = TextEditingController();
  final nomorTeleponController = TextEditingController();
  final alamatController = TextEditingController();
  final gajiPokokController = TextEditingController();
  final uangMakanController = TextEditingController();

  String? selectedRoleID;
  String? selectedPTKP_ID;
  String? selectedJabatanID;
  String? selectedStatus;

  List<Jabatan> dataJabatan = [];
  List<JenisPTKP> dataPTKP = [];
  List<userRole> dataRole = [];
  final List<String> pilihStatus = ["Active", "Inactive"];

  File? _imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadDataDropdown();
  }

  Future<void> loadDataDropdown() async {
    final resultJabatan = await jabatanDB.getAllJabatan();
    final resultPTKP = await ptkpDB.getAllPTKP();
    final resultRole = await roleDB.getAllRole();

    setState(() {
      dataJabatan = resultJabatan;
      dataPTKP = resultPTKP;
      dataRole = resultRole;
    });
  }

  Future<void> _pickPhoto() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _imageFile = null;
    });
  }

  // 🔹 Format angka otomatis (1.000, 10.000, dst)
  String formatAngka(String value) {
    final angka = value.replaceAll('.', '');
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(int.tryParse(angka) ?? 0);
  }

  // 🔹 Upload foto ke Supabase Storage
  Future<String> _uploadPhotoToSupabase(File file) async {
    final supabase = Supabase.instance.client;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${timestamp}_${file.path.split('/').last}'.replaceAll(
        ' ',
        '_',
      );
      final path = 'Foto_Profile/$fileName';

      await supabase.storage
          .from('Aplikasi_Absensi')
          .uploadBinary(
            path,
            file.readAsBytesSync(),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = supabase.storage
          .from('Aplikasi_Absensi')
          .getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload foto ke Supabase: $e');
    }
  }

  Future<void> tambahKaryawan() async {
    if (namaLengkapController.text.isEmpty ||
        emailController.text.isEmpty ||
        nomorTeleponController.text.isEmpty ||
        alamatController.text.isEmpty ||
        selectedJabatanID == null ||
        selectedPTKP_ID == null ||
        selectedStatus == null ||
        gajiPokokController.text.isEmpty ||
        uangMakanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data")),
      );
      return;
    }

    try {
      final roleKaryawan = await roleDB.getRoleByName("Karyawan");
      if (roleKaryawan == null) {
        throw Exception("Role 'Karyawan' tidak ditemukan di database");
      }

      final authResponse = await AuthService().signUpWithEmailAndPassword(
        emailController.text,
        "123456",
      );
      final supabaseUser = authResponse.user;
      if (supabaseUser == null) {
        throw Exception("Gagal membuat user Auth");
      }

      final newUser = AppUser(
        userID: supabaseUser.id,
        email: emailController.text,
        roleID: roleKaryawan.roleID!,
        password: "123456",
      );
      await userDB.createUser(newUser);

      String fotoProfilUrl = "";
      if (_imageFile != null) {
        fotoProfilUrl = await _uploadPhotoToSupabase(_imageFile!);
      }

      final newKaryawan = dataKaryawan(
        userID: supabaseUser.id,
        namaLengkap: namaLengkapController.text,
        nomorTelepon: nomorTeleponController.text,
        alamat: alamatController.text,
        jabatanID: selectedJabatanID!,
        ptkpID: selectedPTKP_ID!,
        status: selectedStatus!,
        gajiPokok: int.parse(gajiPokokController.text.replaceAll('.', '')),
        uangMakan: int.parse(uangMakanController.text.replaceAll('.', '')),
        fotoProfil: fotoProfilUrl,
      );

      await karyawanDB.createNewKaryawan(newKaryawan);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Karyawan & User berhasil ditambahkan")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal tambah karyawan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Tambah User Baru")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nama Lengkap",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  CustomTextField(
                    controller: namaLengkapController,
                    label: "Masukkan Nama Lengkap",
                  ),
                  const SizedBox(height: 10.0),

                  const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  CustomTextField(
                    controller: emailController,
                    label: "Masukkan Email",
                  ),
                  const SizedBox(height: 10.0),

                  const Text(
                    "Nomor Telepon",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  CustomTextField(
                    controller: nomorTeleponController,
                    label: "Masukkan Nomor Telepon",
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 10.0),

                  const Text(
                    "Foto Karyawan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  PhotoPickerField(
                    imageFile: _imageFile,
                    onPickPhoto: _pickPhoto,
                    onRemovePhoto: _removePhoto,
                  ),
                  const SizedBox(height: 10.0),

                  const Text(
                    "Alamat",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  CustomTextField(
                    controller: alamatController,
                    label: "Masukkan Alamat",
                    maxLines: 5,
                  ),
                  const SizedBox(height: 10.0),

                  const Text(
                    "Jabatan Karyawan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  CustomDropdown<String>(
                    hint: "Pilih Jabatan Karyawan",
                    value: selectedJabatanID,
                    items: dataJabatan.map((jabatan) {
                      return DropdownMenuItem<String>(
                        value: jabatan.jabatanID,
                        child: Text(jabatan.namaJabatan),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedJabatanID = value),
                  ),
                  const SizedBox(height: 10.0),

                  const Text(
                    "PTKP Karyawan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  CustomDropdown<String>(
                    value: selectedPTKP_ID,
                    hint: "Pilih PTKP",
                    items: dataPTKP
                        .map(
                          (ptkp) => DropdownMenuItem(
                            value: ptkp.ptkpID,
                            child: Text(
                              "${ptkp.namaGolongan} - ${ptkp.deskripsi}",
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedPTKP_ID = v),
                  ),

                  const SizedBox(height: 10.0),

                  const Text(
                    "Gaji Pokok",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Angkafield(
                    controller: gajiPokokController,
                    label: "Masukkan Gaji Pokok",
                    inputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        String formatted = formatAngka(newValue.text);
                        return TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  const Text(
                    "Uang Makan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Angkafield(
                    controller: uangMakanController,
                    label: "Masukkan Uang Makan",
                    inputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        String formatted = formatAngka(newValue.text);
                        return TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 10.0),

                  const Text(
                    "Status Karyawan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  CustomDropdown<String>(
                    hint: "Pilih Status",
                    value: selectedStatus,
                    items: pilihStatus.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedStatus = value),
                  ),
                  const SizedBox(height: 16.0),

                  SizedBox(
                    width: double.infinity, // 🔹 Full width
                    child: ElevatedButton(
                      onPressed: tambahKaryawan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Tambah Karyawan"),
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
