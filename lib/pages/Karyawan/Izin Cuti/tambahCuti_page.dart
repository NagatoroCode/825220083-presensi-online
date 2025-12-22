import 'package:aplikasiabsensi/database/jenisCuti_database..dart';
import 'package:aplikasiabsensi/database/pengajuanCuti_database.dart';
import 'package:aplikasiabsensi/model/jenisCuti.dart';
import 'package:aplikasiabsensi/model/pengajuanCuti.dart';
import 'package:aplikasiabsensi/widgets/Izin/DoubleCalenderPicker.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_error.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_succses.dart';
import 'package:aplikasiabsensi/widgets/customButton.dart';
import 'package:aplikasiabsensi/widgets/dropdown.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:aplikasiabsensi/widgets/popupkonfirmasi.dart';
import 'package:flutter/material.dart';

class TambahCutiPage extends StatefulWidget {
  final String userID;
  const TambahCutiPage({super.key, required this.userID});

  @override
  State<TambahCutiPage> createState() => _TambahCutiPageState();
}

class _TambahCutiPageState extends State<TambahCutiPage> {
  final pengajuanCutiDB = PengajuancutiDatabase();
  final jenisCutiDB = jenisCutiDatabase();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String? selectedJenisCuti;
  final alasanCutiController = TextEditingController();

  List<jenisCuti> dataCuti = [];

  @override
  void initState() {
    super.initState();
    loadDataDropdown();
  }

  Future<void> loadDataDropdown() async {
    final resultCuti = await jenisCutiDB.getAllCuti();
    setState(() {
      dataCuti = resultCuti;
    });
  }

  Future<void> submitCuti() async {
    try {
      if (selectedStartDate == null ||
          selectedEndDate == null ||
          selectedJenisCuti == null ||
          alasanCutiController.text.isEmpty) {
        showErrorLoginPopup(
          context,
          "Data Belum Lengkap",
          "Lengkapi semua data pengajuan terlebih dahulu.",
        );
        return;
      }

      if (selectedEndDate!.isBefore(selectedStartDate!)) {
        showErrorLoginPopup(
          context,
          "Tanggal Salah",
          "Tanggal selesai tidak boleh sebelum tanggal mulai.",
        );
        return;
      }

      final newCuti = Pengajuancuti(
        userID: widget.userID,
        jenisCutiID: selectedJenisCuti!,
        tanggalMulai: selectedStartDate!.toIso8601String(),
        tanggalSelesai: selectedEndDate!.toIso8601String(),
        alasanCuti: alasanCutiController.text,
        statusPengajuan: "Menunggu Approval",
        tanggalVerifikasi: null,
      );

      await pengajuanCutiDB.createNewCuti(newCuti);

      if (mounted) {
        showSuccsesLoginPopup(
          context,
          "Berhasil",
          "Pengajuan Cuti Berhasil disimpan",
          onClose: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      }
    } catch (e) {
      showErrorLoginPopup(
        context,
        "Gagal",
        "Terjadi kesalahan saat menyimpan pengajuan cuti: $e",
      );
    }
  }

  void _showKonfirmasiDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Popupkonfirmasi(
          message: "Apakah Anda yakin ingin mengajukan cuti ini?",
          onConfirm: () {
            Navigator.pop(context);
            submitCuti();
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget buildSectionCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Pengajuan Cuti")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tanggal
            buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pilih Tanggal",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  tanggalCalenderPicker(
                    onDateChanged: (start, end) {
                      setState(() {
                        selectedStartDate = start;
                        selectedEndDate = end;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Jenis Cuti
            buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Jenis Cuti",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  CustomDropdown<String>(
                    hint: "Pilih Jenis Cuti",
                    value: selectedJenisCuti,
                    items: dataCuti.map((cuti) {
                      return DropdownMenuItem<String>(
                        value: cuti.jenisCutiID.toString(),
                        child: Text(cuti.namaCuti),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedJenisCuti = value);
                    },
                  ),
                ],
              ),
            ),

            // Alasan
            buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Alasan Cuti",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: alasanCutiController,
                    label: "Alasan Cuti",
                    hint: "Masukkan alasan cuti",
                    inputType: TextInputType.multiline,
                    maxLines: 5,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            CustomButton(text: "Ajukan Cuti", onPressed: _showKonfirmasiDialog),
          ],
        ),
      ),
    );
  }
}
