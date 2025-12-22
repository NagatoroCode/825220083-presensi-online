import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/service/izinService.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_error.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_succses.dart';
import 'package:aplikasiabsensi/widgets/popupKonfirmasi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasiabsensi/widgets/statusPengajuan.dart';
import 'package:aplikasiabsensi/model/pengajuanIzin.dart';
import 'package:aplikasiabsensi/database/pengajuanIzin_database.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/widgets/fotoProfile.dart';

final izinDB = pengajuanIzinDatabase();
final izinService = IzinService();
final karyawanDB = DatakaryawanDatabase();

Future<void> rejectIzin(PengajuanIzin izin) async {
  izin.statusPengajuan = "Pengajuan Ditolak";
  izin.tanggalVerifikasi = DateTime.now().toIso8601String();
  await izinDB.updateIzin(izin);
}

class DetailIzinOwner extends StatefulWidget {
  final PengajuanIzin izin;

  const DetailIzinOwner({super.key, required this.izin});

  @override
  State<DetailIzinOwner> createState() => _DetailIzinOwnerState();
}

class _DetailIzinOwnerState extends State<DetailIzinOwner> {
  bool _isLoading = false;

  String? namaKaryawan;
  dataKaryawan? _karyawan;
  final fotoProfileController _fotoCtrl = fotoProfileController();

  @override
  void initState() {
    super.initState();
    _loadDataTambahan();
  }

  Future<void> _loadDataTambahan() async {
    try {
      final izin = widget.izin;
      final karyawan = await karyawanDB.getKaryawanByUserId(izin.userID!);

      if (karyawan != null &&
          karyawan.fotoProfil != null &&
          karyawan.fotoProfil!.isNotEmpty) {
        _fotoCtrl.setImage(karyawan.fotoProfil!);
      }

      setState(() {
        namaKaryawan = karyawan?.namaLengkap ?? "Tidak Diketahui";
        _karyawan = karyawan;
      });
    } catch (e) {
      print("❌ Gagal memuat data karyawan: $e");
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
          setState(() => _isLoading = true);

          try {
            await onYes();
          } finally {
            setState(() => _isLoading = false);
          }

          if (context.mounted) Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  // ⬇️ FORMAT TANGGAL + JAM MENGGUNAKAN STRIP
  String formatTanggalJam(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy - HH:mm').format(date);
    } catch (_) {
      return dateStr;
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

  Widget _buildActionButtons(String status) {
    if (status == "Menunggu Approval") {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _tampilkanKonfirmasi(
                judul: "Konfirmasi Persetujuan",
                pesan: "Apakah Anda yakin ingin menyetujui izin ini?",
                onYes: () async {
                  setState(() => _isLoading = true);

                  // 🔥 UBAH STATUS DISINI
                  widget.izin.statusPengajuan = "Pengajuan Disetujui";
                  widget.izin.tanggalVerifikasi = DateTime.now()
                      .toIso8601String();

                  // Jika ada proses backend lain
                  final result = await izinService.prosesIzinByStatus(
                    widget.izin,
                  );

                  // Simpan perubahan ke database
                  await izinDB.updateIzin(widget.izin);

                  if (result.contains("❌")) {
                    showErrorLoginPopup(context, "Gagal Memproses", result);
                  } else {
                    showSuccsesLoginPopup(context, "Berhasil", result);
                  }

                  if (mounted) setState(() => _isLoading = false);
                  Navigator.pop(context, true);
                },
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Setujui",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton(
              onPressed: () => _tampilkanKonfirmasi(
                judul: "Konfirmasi Penolakan",
                pesan: "Apakah Anda yakin ingin menolak izin ini?",
                onYes: () async => await rejectIzin(widget.izin),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Tolak",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size.fromHeight(48),
        ),
        child: const Text(
          "OK",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }
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
            : izin.statusPengajuan == "Pengajuan Ditolak"
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
              namaKaryawan ?? "Nama Karyawan",
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),

            Text(
              _karyawan?.jabatan?.namaJabatan ?? "",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),

            const SizedBox(height: 20),

            StatusPengajuanWidget(statuses: statusList),

            const SizedBox(height: 20),

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
                    formatTanggalJam(izin.tanggalIzin),
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

            if ((izin.status?.namaStatus ?? '') == "Lembur") ...[
              const SizedBox(height: 18),
              _buildStyledCard([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Waktu Mulai",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "Waktu Selesai",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(izin.waktuMulai ?? "-"),
                    Text(izin.waktuSelesai ?? "-"),
                  ],
                ),
              ]),
            ],

            const SizedBox(height: 28),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildActionButtons(izin.statusPengajuan),
          ],
        ),
      ),
    );
  }
}
