import 'package:aplikasiabsensi/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasiabsensi/widgets/statusPengajuan.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_error.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_succses.dart';
import 'package:aplikasiabsensi/widgets/popupKonfirmasi.dart';
import 'package:aplikasiabsensi/model/pengajuanCuti.dart';
import 'package:aplikasiabsensi/database/pengajuanCuti_database.dart';
import 'package:aplikasiabsensi/widgets/fotoProfile.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/service/cutiService.dart';

final cutiDB = PengajuancutiDatabase();
final cutiService = CutiService();

class DetailCutiOwner extends StatefulWidget {
  final Pengajuancuti cuti;
  const DetailCutiOwner({super.key, required this.cuti});

  @override
  State<DetailCutiOwner> createState() => _DetailCutiOwnerState();
}

class _DetailCutiOwnerState extends State<DetailCutiOwner> {
  bool _isLoading = false;
  fotoProfileController _fotoCtrl = fotoProfileController();
  dataKaryawan? _karyawan;

  @override
  void initState() {
    super.initState();
    _loadKaryawan();
  }

  Future<void> _loadKaryawan() async {
    final db = DatakaryawanDatabase();
    final data = await db.getKaryawanByUserId(widget.cuti.userID!);
    if (data != null &&
        data.fotoProfil != null &&
        data.fotoProfil!.isNotEmpty) {
      _fotoCtrl.setImage(data.fotoProfil!);
    }
    setState(() {
      _karyawan = data;
    });
  }

  // 🔥 Format tanggal + jam (dd MMM yyyy - HH:mm)
  String formatTanggalJam(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy - HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String formatTanggal(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  int _hitungLamaCuti(String mulai, String selesai) {
    try {
      final start = DateTime.parse(mulai);
      final end = DateTime.parse(selesai);
      return end.difference(start).inDays + 1;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _tampilkanKonfirmasi({
    required String judul,
    required String pesan,
    required Future<void> Function() onYes,
  }) async {
    showDialog(
      context: context,
      builder: (context) => Popupkonfirmasi(
        title: judul,
        message: pesan,
        onConfirm: () async {
          Navigator.pop(context);
          setState(() => _isLoading = true);
          try {
            await onYes();
          } catch (e) {
            showErrorLoginPopup(context, "Gagal", "Terjadi kesalahan: $e");
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> approveCuti() async {
    _tampilkanKonfirmasi(
      judul: "Konfirmasi Persetujuan",
      pesan: "Apakah Anda yakin ingin menyetujui cuti ini?",
      onYes: () async {
        widget.cuti.statusPengajuan = "Pengajuan Disetujui";
        widget.cuti.tanggalVerifikasi = DateTime.now().toString();
        await cutiDB.updateCuti(widget.cuti);
        await cutiService.prosesCutiByStatus(widget.cuti);
        showSuccsesLoginPopup(context, "Berhasil", "Pengajuan cuti disetujui");
        setState(() {});
      },
    );
  }

  Future<void> rejectCuti() async {
    _tampilkanKonfirmasi(
      judul: "Konfirmasi Penolakan",
      pesan: "Apakah Anda yakin ingin menolak cuti ini?",
      onYes: () async {
        widget.cuti.statusPengajuan = "Pengajuan Ditolak";
        widget.cuti.tanggalVerifikasi = DateTime.now().toString();
        await cutiDB.updateCuti(widget.cuti);
        showSuccsesLoginPopup(context, "Berhasil", "Pengajuan cuti ditolak");
        setState(() {});
      },
    );
  }

  Widget _buildStyledCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    if (status == "Menunggu Approval") {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "Setujui",
              backgroundColor: Colors.green,
              isLoading: _isLoading,
              onPressed: approveCuti,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: "Tolak",
              backgroundColor: Colors.redAccent,
              isLoading: _isLoading,
              onPressed: rejectCuti,
            ),
          ),
        ],
      );
    } else {
      return CustomButton(
        text: "OK",
        backgroundColor: const Color(0xFF1976D2),
        onPressed: () => Navigator.pop(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuti = widget.cuti;

    // 🔥 STATUS LIST SUDAH MEMAKAI formatTanggalJam()
    final List<statusPengajuan> statusList = [
      statusPengajuan(
        namaStatus: "Pengajuan Diajukan",
        tanggalStatus: formatTanggalJam(cuti.tanggalPengajuan),
        warna: Colors.blueAccent,
      ),
      statusPengajuan(
        namaStatus: cuti.statusPengajuan,
        tanggalStatus: formatTanggalJam(cuti.tanggalVerifikasi),
        warna: cuti.statusPengajuan == "Pengajuan Disetujui"
            ? Colors.green
            : cuti.statusPengajuan == "Pengajuan Ditolak" ||
                  cuti.statusPengajuan == "Pengajuan Dibatalkan"
            ? Colors.red
            : Colors.grey,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(title: const Text("Detail Cuti Owner")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Fotoprofile(
                size: 95,
                controller: _fotoCtrl,
                placeholder: 'assets/images/fotoOrang.png',
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _karyawan?.namaLengkap ?? "Nama Karyawan",
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            Text(
              _karyawan?.jabatan?.namaJabatan ?? "Jabatan",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 20),

            StatusPengajuanWidget(statuses: statusList),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Informasi Cuti",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildStyledCard([
              // ===== Jenis Cuti + Tanggal Mulai =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Jenis Cuti",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Tanggal Mulai",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cuti.cuti?.namaCuti ?? "-",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    formatTanggal(cuti.tanggalMulai),
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ===== Alasan Cuti + Tanggal Selesai =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Alasan Cuti",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Tanggal Selesai",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alasan cuti kiri
                  Expanded(
                    child: Text(
                      cuti.alasanCuti,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Tanggal selesai kanan
                  Text(
                    formatTanggal(cuti.tanggalSelesai),
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 28),
            _buildActionButtons(cuti.statusPengajuan),
          ],
        ),
      ),
    );
  }
}
