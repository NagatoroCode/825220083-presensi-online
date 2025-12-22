import 'package:aplikasiabsensi/widgets/Popup/popup_error.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_succses.dart';
import 'package:aplikasiabsensi/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:aplikasiabsensi/database/jenisStatus_database.dart';
import 'package:aplikasiabsensi/database/pengajuanIzin_database.dart';
import 'package:aplikasiabsensi/model/jenisStatus.dart';
import 'package:aplikasiabsensi/model/pengajuanIzin.dart';
import 'package:aplikasiabsensi/widgets/dropdown.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:aplikasiabsensi/widgets/timePicker.dart';
import 'package:aplikasiabsensi/widgets/Izin/SingleCalenderPicker.dart';
import 'package:aplikasiabsensi/widgets/popupKonfirmasi.dart';
import 'package:intl/intl.dart';

class TambahizinPage extends StatefulWidget {
  final String userID;

  const TambahizinPage({super.key, required this.userID});

  @override
  State<TambahizinPage> createState() => _TambahizinPageState();
}

class _TambahizinPageState extends State<TambahizinPage> {
  final pengajuanIzinDB = pengajuanIzinDatabase();
  final jenisStatusDB = JenisstatusDatabase();

  DateTime? selectedDate;
  String? selectedJenisStatusID;
  String? selectedJenisStatusNama;

  final alasanIzinController = TextEditingController();

  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  List<jenisStatus> dataStatus = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    loadDataDropdown();
  }

  Future<void> loadDataDropdown() async {
    final resultStatus = await jenisStatusDB.getAllStatus();
    setState(() {
      dataStatus = resultStatus
          .where(
            (s) =>
                s.namaStatus == "Hadir Terlambat" ||
                s.namaStatus == "Pulang Cepat" ||
                s.namaStatus == "Lupa Check In" ||
                s.namaStatus == "Lupa Check Out" ||
                s.namaStatus == "Tidak Hadir" ||
                s.namaStatus == "Lembur",
          )
          .toList();
    });
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00";
  }

  Future<void> _konfirmasiSubmit() async {
    showDialog(
      context: context,
      builder: (context) => Popupkonfirmasi(
        message: "Apakah Anda yakin ingin mengajukan izin ini?",
        onConfirm: () {
          Navigator.pop(context);
          submitIzin();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> submitIzin() async {
    if (isLoading) return;

    // 🔹 Validasi data wajib
    if (selectedDate == null ||
        selectedJenisStatusID == null ||
        alasanIzinController.text.isEmpty) {
      showErrorLoginPopup(
        context,
        "Data Belum Lengkap",
        "Lengkapi semua data pengajuan terlebih dahulu.",
      );
      return;
    }

    final tanggalFormatted = DateFormat('yyyy-MM-dd').format(selectedDate!);

    // 🔹 Cek apakah user boleh submit jenis status ini pada tanggal ini
    final bolehSubmit = await pengajuanIzinDB.canSubmitJenisStatusOnDate(
      widget.userID,
      selectedJenisStatusID!,
      tanggalFormatted,
    );

    if (!bolehSubmit) {
      showErrorLoginPopup(
        context,
        "Izin Sudah Ada",
        "Anda sudah mengajukan jenis status ini pada tanggal ini yang belum dibatalkan.",
      );
      return; // hentikan proses submit
    }

    // 🔹 Validasi waktu untuk Lembur
    if (selectedJenisStatusNama == "Lembur") {
      if (selectedStartTime == null || selectedEndTime == null) {
        showErrorLoginPopup(
          context,
          "Waktu Belum Dipilih",
          "Silakan pilih waktu mulai dan selesai lembur.",
        );
        return;
      }

      final startMinutes =
          selectedStartTime!.hour * 60 + selectedStartTime!.minute;
      final endMinutes = selectedEndTime!.hour * 60 + selectedEndTime!.minute;

      if (startMinutes >= endMinutes) {
        showErrorLoginPopup(
          context,
          "Waktu Tidak Valid",
          "Waktu mulai harus lebih kecil dari waktu selesai.",
        );
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      final newIzin = PengajuanIzin(
        userID: widget.userID,
        statusID: selectedJenisStatusID!,
        tanggalIzin: tanggalFormatted,
        waktuMulai: selectedStartTime != null
            ? formatTimeOfDay(selectedStartTime!)
            : null,
        waktuSelesai: selectedEndTime != null
            ? formatTimeOfDay(selectedEndTime!)
            : null,
        alasanIzin: alasanIzinController.text,
        statusPengajuan: "Menunggu Approval",
        tanggalPengajuan: DateTime.now().toIso8601String(),
        tanggalVerifikasi: null,
      );

      await pengajuanIzinDB.createNewIzin(newIzin);

      showSuccsesLoginPopup(
        context,
        "Berhasil",
        "Pengajuan Izin Kerja berhasil disimpan",
        onClose: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showErrorLoginPopup(
        context,
        "Gagal",
        "Terjadi kesalahan saat mengajukan izin: $e",
      );
    } finally {
      setState(() => isLoading = false);
    }
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
      appBar: AppBar(title: const Text("Pengajuan Izin Kerja")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Dropdown Jenis Status
              buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Jenis Status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown<String>(
                      hint: "Pilih Jenis Status",
                      value: selectedJenisStatusID,
                      items: dataStatus
                          .map(
                            (status) => DropdownMenuItem<String>(
                              value: status.statusID,
                              child: Text(status.namaStatus),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedJenisStatusID = value;
                          final selectedStatus = dataStatus.firstWhere(
                            (s) => s.statusID == value,
                          );
                          selectedJenisStatusNama = selectedStatus.namaStatus;

                          if (selectedJenisStatusNama == "Lembur") {
                            selectedStartTime = const TimeOfDay(
                              hour: 17,
                              minute: 0,
                            );
                            selectedEndTime = const TimeOfDay(
                              hour: 20,
                              minute: 0,
                            );
                          } else {
                            selectedStartTime = null;
                            selectedEndTime = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              // 🔹 Tanggal Izin
              buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tanggal Izin",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Singlecalenderpicker(
                      initialStartDate: selectedDate,
                      onDateChanged: (selected) =>
                          setState(() => selectedDate = selected),
                      singleDateMode: true,
                      selectableDayPredicate: (day) {
                        final today = DateTime.now();
                        final dateToday = DateTime(
                          today.year,
                          today.month,
                          today.day,
                        );

                        final twoWeeksAgo = dateToday.subtract(
                          const Duration(days: 14),
                        );

                        final currentDay = DateTime(
                          day.year,
                          day.month,
                          day.day,
                        );

                        // 🔹 Hanya bisa pilih hari ini
                        if (selectedJenisStatusNama == "Hadir Terlambat" ||
                            selectedJenisStatusNama == "Pulang Cepat" ||
                            selectedJenisStatusNama == "Tidak Hadir") {
                          return currentDay.isAtSameMomentAs(dateToday);
                        }

                        // 🔹 Lupa Check In, Lupa Check Out, dan Lembur bisa pilih 2 minggu terakhir
                        if (selectedJenisStatusNama == "Lupa Check In" ||
                            selectedJenisStatusNama == "Lupa Check Out" ||
                            selectedJenisStatusNama == "Lembur") {
                          return currentDay.isAfter(
                                twoWeeksAgo.subtract(const Duration(days: 1)),
                              ) &&
                              currentDay.isBefore(
                                dateToday.add(const Duration(days: 1)),
                              );
                        }

                        return false;
                      },
                    ),
                  ],
                ),
              ),

              // 🔹 Waktu (hanya untuk lembur)
              if (selectedJenisStatusNama == "Lembur")
                buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Waktu",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Timepicker(
                              label: "Mulai",
                              initialTime: selectedStartTime,
                              minHour: 17,
                              maxHour: 20,
                              onTimeSelected: (t) =>
                                  setState(() => selectedStartTime = t),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Timepicker(
                              label: "Selesai",
                              initialTime: selectedEndTime,
                              minHour: 17,
                              maxHour: 20,
                              onTimeSelected: (t) =>
                                  setState(() => selectedEndTime = t),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // 🔹 Alasan
              buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Alasan Izin",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: alasanIzinController,
                      label: "Alasan Izin",
                      hint: "Masukkan alasan izin",
                      inputType: TextInputType.multiline,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              CustomButton(
                text: isLoading ? "Mengirim..." : "Ajukan Izin",
                onPressed: isLoading ? () {} : _konfirmasiSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
