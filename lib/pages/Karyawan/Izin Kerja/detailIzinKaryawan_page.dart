import 'package:aplikasiabsensi/widgets/fotoProfile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasiabsensi/widgets/statusPengajuan.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_error.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_succses.dart';
import 'package:aplikasiabsensi/widgets/popupKonfirmasi.dart';
import 'package:aplikasiabsensi/model/pengajuanIzin.dart';
import 'package:aplikasiabsensi/database/pengajuanIzin_database.dart';
import 'package:aplikasiabsensi/widgets/customButton.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';

final izinDB = pengajuanIzinDatabase();

class DetailIzinKaryawan extends StatefulWidget {
  final PengajuanIzin izin;
  const DetailIzinKaryawan({super.key, required this.izin});

  @override
  State<DetailIzinKaryawan> createState() => _DetailIzinKaryawanState();
}

class _DetailIzinKaryawanState extends State<DetailIzinKaryawan> {
  bool _isLoading = false;

  final fotoProfileController _fotoCtrl = fotoProfileController();
  dataKaryawan? _karyawan;

  Future<void> _loadKaryawan() async {
    final db = DatakaryawanDatabase();
    final data = await db.getKaryawanByUserId(widget.izin.userID!);

    if (data != null &&
        data.fotoProfil != null &&
        data.fotoProfil!.isNotEmpty) {
      _fotoCtrl.setImage(data.fotoProfil!);
    }

    setState(() {
      _karyawan = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadKaryawan();
  }

  Future<void> _batalkanIzin() async {
    _tampilkanKonfirmasi(
      judul: "Konfirmasi Pembatalan",
      pesan: "Apakah Anda yakin ingin membatalkan pengajuan izin ini?",
      onYes: () async {
        widget.izin.statusPengajuan = "Pengajuan Dibatalkan";
        widget.izin.tanggalVerifikasi = DateTime.now().toString();
        await izinDB.updateIzin(widget.izin);
        setState(() {});
      },
    );
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
            if (!mounted) return;

            showSuccsesLoginPopup(
              context,
              "Berhasil",
              "Pengajuan Izin Kerja dibatalkan",
              onClose: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            );
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

  Widget _buildActionButton(String? status) {
    if (status == "Menunggu Approval") {
      return CustomButton(
        text: "Batalkan",
        backgroundColor: Colors.redAccent,
        isLoading: _isLoading,
        onPressed: _batalkanIzin,
      );
    } else {
      return CustomButton(
        text: "OK",
        backgroundColor: const Color(0xFF1976D2),
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final izin = widget.izin;

    final List<statusPengajuan> statusList = [
      statusPengajuan(
        namaStatus: "Pengajuan Diajukan",
        tanggalStatus: formatTanggalJam(izin.tanggalPengajuan),
        warna: Colors.blueAccent,
      ),
      statusPengajuan(
        namaStatus: izin.statusPengajuan,
        tanggalStatus: formatTanggalJam(izin.tanggalVerifikasi),
        warna: izin.statusPengajuan == "Pengajuan Disetujui"
            ? Colors.green
            : izin.statusPengajuan == "Pengajuan Ditolak" ||
                  izin.statusPengajuan == "Pengajuan Dibatalkan"
            ? Colors.red
            : Colors.grey,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(title: const Text("Detail Izin Kerja")),
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
                "Informasi Surat Izin",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildStyledCard([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Jenis Izin",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Tanggal Izin",
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
                      izin.status?.namaStatus ?? "-",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    formatTanggal(izin.tanggalIzin),
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Text(
                "Alasan Izin",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                izin.alasanIzin,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ]),

            if (izin.status?.namaStatus == "Lembur") ...[
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Waktu Izin",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildStyledCard([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Waktu Mulai",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Waktu Selesai",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      izin.waktuMulai ?? "-",
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text(
                      izin.waktuSelesai ?? "-",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ]),
            ],

            const SizedBox(height: 28),
            _buildActionButton(izin.statusPengajuan),
          ],
        ),
      ),
    );
  }
}
