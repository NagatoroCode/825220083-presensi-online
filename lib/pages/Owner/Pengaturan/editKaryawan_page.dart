import 'dart:io';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/jabatan_database.dart';
import 'package:aplikasiabsensi/database/jenisPTKP_database.dart';
import 'package:aplikasiabsensi/database/roleUser_database.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/model/jabatan.dart';
import 'package:aplikasiabsensi/model/jenisPTKP.dart';
import 'package:aplikasiabsensi/widgets/angkafield.dart';
import 'package:aplikasiabsensi/widgets/dropdown.dart';
import 'package:aplikasiabsensi/widgets/fieldInputFoto.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditKaryawanPage extends StatefulWidget {
  final dataKaryawan karyawan;

  const EditKaryawanPage({super.key, required this.karyawan});

  @override
  State<EditKaryawanPage> createState() => _EditKaryawanPageState();
}

class _EditKaryawanPageState extends State<EditKaryawanPage> {
  final karyawanDB = DatakaryawanDatabase();
  final roleDB = RoleDatabase();
  final ptkpDB = JenisptkpDatabase();
  final jabatanDB = jabatanDatabase();
  final picker = ImagePicker();

  // Controllers
  late TextEditingController namaLengkapController;
  late TextEditingController nomorTeleponController;
  late TextEditingController alamatController;
  late TextEditingController gajiPokokController;
  late TextEditingController uangMakanController;

  // Dropdown selections
  String? selectedPTKP_ID;
  String? selectedJabatanID;
  String? selectedStatus;

  List<Jabatan> dataJabatan = [];
  List<JenisPTKP> dataPTKP = [];
  final List<String> pilihStatus = ["Active", "Inactive"];

  // Foto
  File? _imageFile;
  bool removePhoto = false;

  @override
  void initState() {
    super.initState();
    namaLengkapController = TextEditingController(
      text: widget.karyawan.namaLengkap,
    );
    nomorTeleponController = TextEditingController(
      text: widget.karyawan.nomorTelepon,
    );
    alamatController = TextEditingController(text: widget.karyawan.alamat);
    gajiPokokController = TextEditingController(
      text: NumberFormat.decimalPattern('id').format(widget.karyawan.gajiPokok),
    );
    uangMakanController = TextEditingController(
      text: NumberFormat.decimalPattern('id').format(widget.karyawan.uangMakan),
    );

    selectedJabatanID = widget.karyawan.jabatanID;
    selectedPTKP_ID = widget.karyawan.ptkpID;
    selectedStatus = widget.karyawan.status;

    loadDataDropdown();
  }

  Future<void> loadDataDropdown() async {
    final resultJabatan = await jabatanDB.getAllJabatan();
    final resultPTKP = await ptkpDB.getAllPTKP();
    setState(() {
      dataJabatan = resultJabatan;
      dataPTKP = resultPTKP;
    });
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

  Future<void> updateKaryawan() async {
    try {
      final roleKaryawan = await roleDB.getRoleByName("Karyawan");
      if (roleKaryawan == null) {
        throw Exception("Role 'Karyawan' tidak ditemukan di database");
      }

      String? fotoUrl = widget.karyawan.fotoProfil;

      if (_imageFile != null) {
        final uploadedUrl = await _uploadPhoto(_imageFile!);
        if (uploadedUrl != null) fotoUrl = uploadedUrl;
      } else if (removePhoto) {
        fotoUrl = '';
      }

      final updated = dataKaryawan(
        karyawanID: widget.karyawan.karyawanID,
        userID: widget.karyawan.userID,
        namaLengkap: namaLengkapController.text,
        nomorTelepon: nomorTeleponController.text,
        alamat: alamatController.text,
        jabatanID: selectedJabatanID!,
        ptkpID: selectedPTKP_ID!,
        status: selectedStatus!,
        gajiPokok: int.parse(gajiPokokController.text.replaceAll('.', '')),
        uangMakan: int.parse(uangMakanController.text.replaceAll('.', '')),
        fotoProfil: fotoUrl,
      );

      await karyawanDB.updateKaryawan(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data karyawan berhasil diperbarui")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal update karyawan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Karyawan")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nama Lengkap",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: namaLengkapController,
                label: "Masukkan Nama Lengkap",
              ),
              const SizedBox(height: 10),
              const Text(
                "Nomor Telepon",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: nomorTeleponController,
                label: "Masukkan Nomor Telepon",
              ),
              const SizedBox(height: 10),
              const Text(
                "Alamat",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: alamatController,
                label: "Masukkan Alamat",
              ),
              const SizedBox(height: 10),
              const Text(
                "Jabatan Karyawan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomDropdown<String>(
                value: selectedJabatanID,
                hint: "Pilih Jabatan",
                items: dataJabatan
                    .map(
                      (jabatan) => DropdownMenuItem(
                        value: jabatan.jabatanID,
                        child: Text(jabatan.namaJabatan),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedJabatanID = v),
              ),
              const SizedBox(height: 10),
              const Text(
                "PTKP Karyawan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomDropdown<String>(
                value: selectedPTKP_ID,
                hint: "Pilih PTKP",
                items: dataPTKP
                    .map(
                      (ptkp) => DropdownMenuItem(
                        value: ptkp.ptkpID,
                        child: Text("${ptkp.namaGolongan} - ${ptkp.deskripsi}"),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedPTKP_ID = v),
              ),

              const SizedBox(height: 10),
              const Text(
                "Gaji Pokok",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Angkafield(
                controller: gajiPokokController,
                label: "Masukkan Gaji Pokok",
                inputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final angka = newValue.text.replaceAll('.', '');
                    final formatted = NumberFormat.decimalPattern(
                      'id',
                    ).format(int.tryParse(angka.isEmpty ? '0' : angka) ?? 0);
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Uang Makan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Angkafield(
                controller: uangMakanController,
                label: "Masukkan Uang Makan",
                inputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final angka = newValue.text.replaceAll('.', '');
                    final formatted = NumberFormat.decimalPattern(
                      'id',
                    ).format(int.tryParse(angka.isEmpty ? '0' : angka) ?? 0);
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Status Karyawan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomDropdown<String>(
                value: selectedStatus,
                hint: "Pilih Status",
                items: pilihStatus
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => selectedStatus = v),
              ),
              const SizedBox(height: 10),
              const Text(
                "Foto Profil",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              PhotoPickerField(
                imageFile: _imageFile,
                existingPhotoUrl: removePhoto
                    ? null
                    : widget.karyawan.fotoProfil,
                onPickPhoto: _pickPhoto,
                onRemovePhoto: _removePhoto,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: updateKaryawan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5), // Biru elegan
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.2),
                      ),
                      child: const Text(
                        "Update Karyawan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await karyawanDB.deleteKaryawan(
                            widget.karyawan.karyawanID!,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Data karyawan berhasil dihapus"),
                            ),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Gagal hapus karyawan: $e")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935), // Merah soft
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.2),
                      ),
                      child: const Text(
                        "Hapus Karyawan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
