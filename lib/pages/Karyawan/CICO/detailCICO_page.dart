import 'dart:io';
import 'package:aplikasiabsensi/service/CheckinService.dart';
import 'package:aplikasiabsensi/service/CheckoutService.dart';
import 'package:aplikasiabsensi/service/gajiService.dart';
import 'package:aplikasiabsensi/service/getLocation.dart';
import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_error.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_succses.dart';
import 'package:aplikasiabsensi/widgets/customButton.dart';
import 'package:aplikasiabsensi/widgets/fieldInputFoto.dart';
import 'package:aplikasiabsensi/widgets/popupKonfirmasi.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class DetailCICOPage extends StatefulWidget {
  final String address;
  final String jamCico;
  final bool isCheckout;
  final String? existingPhotoUrl;

  const DetailCICOPage({
    super.key,
    required this.address,
    required this.jamCico,
    this.isCheckout = false,
    this.existingPhotoUrl,
  });

  @override
  State<DetailCICOPage> createState() => _DetailCICOPageState();
}

class _DetailCICOPageState extends State<DetailCICOPage> {
  final alamatController = TextEditingController();
  final waktuController = TextEditingController();
  final deskripsiController = TextEditingController();
  File? _imageFile;
  String? _uploadedPhotoUrl;

  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  late bool isCheckout;

  @override
  void initState() {
    super.initState();

    alamatController.text = widget.address;
    waktuController.text = widget.jamCico;
    _uploadedPhotoUrl = widget.existingPhotoUrl;

    final now = DateTime.now();
    final batasCheckout = DateTime(now.year, now.month, now.day, 24, 0);
    isCheckout = widget.isCheckout || now.isAfter(batasCheckout);
  }

  @override
  void dispose() {
    alamatController.dispose();
    waktuController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    final options = FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      performanceMode: FaceDetectorMode.accurate,
    );
    final faceDetector = FaceDetector(options: options);

    // 🔹 Convert file ke InputImage
    final inputImage = InputImage.fromFile(file);

    // 🔹 Deteksi wajah
    final faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      // Tidak ada wajah
      showErrorLoginPopup(
        context,
        "Wajah Tidak Terdeteksi",
        "Pastikan wajah terlihat jelas di kamera depan.",
      );
      return;
    }

    // Ada wajah, simpan foto
    setState(() {
      _imageFile = file;
      _uploadedPhotoUrl = null;
    });

    faceDetector.close();
  }

  Future<String> _uploadPhotoToSupabase(File file, String path) async {
    final supabase = Supabase.instance.client;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User belum login');

      await supabase.storage
          .from('Aplikasi_Absensi')
          .uploadBinary(
            path,
            file.readAsBytesSync(),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return supabase.storage.from('Aplikasi_Absensi').getPublicUrl(path);
    } catch (e) {
      throw Exception('Error upload file: $e');
    }
  }

  Future<void> _konfirmasiSubmit() async {
    showDialog(
      context: context,
      builder: (ctx) => Popupkonfirmasi(
        message: isCheckout
            ? "Apakah Anda yakin ingin melakukan Check Out sekarang?"
            : "Apakah Anda yakin ingin melakukan Check In sekarang?",
        onConfirm: () {
          Navigator.pop(ctx);
          _handleSubmit();
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (isLoading) return;

    if (_imageFile == null && _uploadedPhotoUrl == null) {
      showErrorLoginPopup(
        context,
        "Foto Diperlukan",
        "Ambil foto dulu sebelum absen!",
      );
      return;
    }

    if (deskripsiController.text.isEmpty) {
      showErrorLoginPopup(
        context,
        "Keterangan Kosong",
        "Isi keterangan terlebih dahulu!",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      double? latitude;
      double? longitude;
      String alamat = alamatController.text;
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User belum login");

      print("👤 User: ${user.email}");
      print("📍 Lokasi: $alamat");
      print("📅 Waktu: ${widget.jamCico}");
      print("🕒 Mode: ${isCheckout ? "CHECK OUT" : "CHECK IN"}");

      if (!isCheckout) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        latitude = position.latitude;
        longitude = position.longitude;
        alamat = await getCurrentAddress();
        alamatController.text = alamat;
      }

      if (_imageFile != null) {
        String folder = isCheckout ? 'Foto_Check_Out' : 'Foto_Check_In';
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String fileName = '${timestamp}_${_imageFile!.path.split('/').last}'
            .replaceAll(' ', '_');
        String photoPath = '$folder/$fileName';

        _uploadedPhotoUrl = await _uploadPhotoToSupabase(
          _imageFile!,
          photoPath,
        );
        print("🖼️ Foto berhasil diupload ke: $_uploadedPhotoUrl");
      }

      final message = isCheckout
          ? await CheckoutService().handleCheckOut(
              lokasiKeluar: alamatController.text,
              fotoKeluar: _uploadedPhotoUrl!,
              deskripsi: deskripsiController.text,
            )
          : await CheckinService().handleCheckIn(
              lokasiMasuk: alamat,
              fotoMasuk: _uploadedPhotoUrl!,
              deskripsi: deskripsiController.text,
              latitudeMasuk: latitude ?? 0,
              longitudeMasuk: longitude ?? 0,
            );

      print("✅ Respon dari service: $message");

      if (isCheckout) {
        final tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final checkinDB = CheckinDatabase();
        final checkin = await checkinDB.getCheckInByUserAndDate(
          user.id,
          tanggal,
        );
        print("🧾 Data checkin hari ini: $checkin");

        // Jalankan hitung gaji meski checkin null
        await GajiService().hitungGajiBulanan(
          user.id,
          DateTime.now().month,
          DateTime.now().year,
        );
        print("💰 Fungsi hitungGajiBulanan() dijalankan.");
      }

      showSuccsesLoginPopup(
        context,
        "Berhasil",
        message,
        onClose: () {
          Navigator.pop(context);
        },
      );
    } catch (e) {
      print("❌ Error di _handleSubmit: $e");
      showErrorLoginPopup(context, "Gagal", "Terjadi kesalahan: $e");
    } finally {
      setState(() {
        isLoading = false;
        _imageFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isCheckout ? "Halaman Presensi Keluar" : "Halaman Presensi Masuk",
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isCheckout ? 'Lokasi Check Out :' : 'Lokasi Check In :'),
              const SizedBox(height: 8),
              TextField(
                controller: alamatController,
                maxLines: 3,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                isCheckout ? 'Informasi Check Out :' : 'Informasi Check In :',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: waktuController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(isCheckout ? 'Foto Check Out :' : 'Foto Check In :'),
              const SizedBox(height: 8),
              PhotoPickerField(
                imageFile: _imageFile,
                existingPhotoUrl: _uploadedPhotoUrl,
                onPickPhoto: _takePhoto,
                onRemovePhoto: () {
                  setState(() {
                    _imageFile = null;
                    _uploadedPhotoUrl = null;
                  });
                },
              ),
              const SizedBox(height: 24),

              const Text('Keterangan :'),
              const SizedBox(height: 8),
              TextField(
                controller: deskripsiController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: isCheckout
                      ? 'Masukkan keterangan Check Out (Wajib)'
                      : 'Masukkan keterangan Check In (Wajib)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: isCheckout ? 'Submit Check Out' : 'Submit Check In',
                onPressed: _konfirmasiSubmit,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
