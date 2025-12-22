import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/pengajuanCuti_database.dart';
import 'package:aplikasiabsensi/database/user_database.dart';
import 'package:aplikasiabsensi/model/user.dart';
import 'package:aplikasiabsensi/service/downloadPdf.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_error.dart';
import 'package:aplikasiabsensi/widgets/Popup/popup_succses.dart';
import 'package:aplikasiabsensi/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasiabsensi/database/historygaji_database.dart';
import 'package:aplikasiabsensi/widgets/popupkonfirmasi.dart';
import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/database/pengajuanizin_database.dart';

class DetailLaporanGajiOwnerPage extends StatefulWidget {
  final String karyawanID;
  final String bulan;
  final String tahun;

  const DetailLaporanGajiOwnerPage({
    super.key,
    required this.karyawanID,
    required this.bulan,
    required this.tahun,
  });

  @override
  State<DetailLaporanGajiOwnerPage> createState() =>
      _DetailLaporanGajiOwnerPageState();
}

class _DetailLaporanGajiOwnerPageState
    extends State<DetailLaporanGajiOwnerPage> {
  final gajiDB = HistorygajiDatabase();
  final checkinDB = CheckinDatabase();
  final izinDB = pengajuanIzinDatabase();
  final cutiDB = PengajuancutiDatabase();
  final userDB = UserDatabase();
  final _downloadService = Downloadpdf();

  Map<String, dynamic>? gajiData;
  bool isLoading = true;
  bool showPajak = false;

  // ⬅️ Variabel tambahan
  int totalJumlahHadir = 0;
  int totalTidakHadirDisetujui = 0;
  int totalIzinDisetujui = 0;
  int totalLemburDisetujui = 0;
  int totalCutiDisetujui = 0;
  int hitungSuspended = 0;

  @override
  void initState() {
    super.initState();
    _loadGajiDetail(widget.bulan);
  }

  Future<void> _loadGajiDetail(String bulan) async {
    setState(() => isLoading = true);

    try {
      final data = await gajiDB.supabase
          .from('historyGaji')
          .select('*')
          .eq('karyawanID', widget.karyawanID)
          .eq('periodeBulan', bulan)
          .eq('periodeTahun', widget.tahun)
          .maybeSingle();

      gajiData = data;
      // Ambil data karyawan berdasarkan karyawanID
      final karyawanData = await DatakaryawanDatabase().getKaryawanByID(
        widget.karyawanID,
      );
      if (karyawanData == null) {
        throw Exception("Data karyawan tidak ditemukan");
      }
      final String userID = karyawanData.userID!;

      totalJumlahHadir = await checkinDB.hitungJumlahHadir(
        userId: userID,
        tahun: int.parse(widget.tahun),
        bulan: int.parse(widget.bulan),
      );

      totalTidakHadirDisetujui = await izinDB.hitungTidakHadirDisetujui(
        userId: userID,
        tahun: int.parse(widget.tahun),
        bulan: int.parse(widget.bulan),
      );

      totalIzinDisetujui = await izinDB.hitungSuratIzinDisetujui(
        userId: userID,
        tahun: int.parse(widget.tahun),
        bulan: int.parse(widget.bulan),
      );

      hitungSuspended = await izinDB.hitungSuspended(
        userId: userID,
        tahun: int.parse(widget.tahun),
        bulan: int.parse(widget.bulan),
      );

      totalLemburDisetujui = await izinDB.hitungLembur(
        userId: userID,
        tahun: int.parse(widget.tahun),
        bulan: int.parse(widget.bulan),
      );

      totalCutiDisetujui = await cutiDB.hitungJumlahCuti(
        userId: userID,
        tahun: int.parse(widget.tahun),
        bulan: int.parse(widget.bulan),
      );

      setState(() {
        isLoading = false;
        showPajak = true;
      });
    } catch (e) {
      debugPrint("Error load detail gaji: $e");
      setState(() => isLoading = false);
    }
  }

  String formatRupiah(num? value) {
    if (value == null) return "-";
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(value);
  }

  Widget buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 18, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 5, child: Text(label)),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPDF(BuildContext context) async {
    if (gajiData == null) return;

    showDialog(
      context: context,
      builder: (context) => Popupkonfirmasi(
        message: "Apakah Anda ingin mendownload slip gaji bulan ini?",
        onConfirm: () async {
          Navigator.pop(context);

          try {
            await _downloadService.downloadSlipGaji(
              karyawanID: widget.karyawanID,
              bulan: widget.bulan,
              tahun: widget.tahun,
              gajiData: gajiData!,
              totalJumlahHadir: totalJumlahHadir,
              totalTidakHadirDisetujui: totalTidakHadirDisetujui,
              totalIzinDisetujui: totalIzinDisetujui,
              hitungSuspended: hitungSuspended,
              totalLemburDisetujui: totalLemburDisetujui,
              totalCutiDisetujui: totalCutiDisetujui,
            );

            showSuccsesLoginPopup(
              context,
              "Berhasil",
              "Slip gaji berhasil diunduh.",
            );
          } catch (e) {
            showErrorLoginPopup(
              context,
              "Gagal",
              "Terjadi kesalahan saat mengunduh slip gaji.",
            );
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (gajiData == null) {
      return const Scaffold(
        body: Center(child: Text("Data gaji tidak ditemukan")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text("Detail Laporan Gaji"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: () => _downloadPDF(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSection("Detail Waktu", [
              detailRow("Periode:", "${widget.bulan}-${widget.tahun}"),
              detailRow("Jumlah Hadir:", "$totalJumlahHadir Hari"),
              detailRow(
                "Total Jam Kerja:",
                "${gajiData!['totalJamKerja'] ?? '-'} jam",
              ),
              detailRow(
                "Total Jam Lembur:",
                "${gajiData!['totalJamLembur'] ?? '-'} jam",
              ),
            ]),

            buildSection("Informasi Izin Kerja / Cuti", [
              detailRow(
                "Jumlah Tidak Hadir:",
                "$totalTidakHadirDisetujui Hari",
              ),
              detailRow("Jumlah Izin Cuti:", "$totalCutiDisetujui Hari"),
              detailRow("Jumlah Suspended:", "$hitungSuspended Kali"),
              detailRow("Jumlah Izin Kerja:", "$totalIzinDisetujui Kali"),
              detailRow("Jumlah Izin Lembur:", "$totalLemburDisetujui Kali"),
            ]),

            buildSection("Informasi Penghasilan", [
              detailRow(
                "Ekspektasi gaji:",
                formatRupiah(gajiData!['ekspektasiGaji']),
              ),
              detailRow("Gaji Pokok:", formatRupiah(gajiData!['gajiPokok'])),
              detailRow("Uang Makan:", formatRupiah(gajiData!['uangMakan'])),
              detailRow("Uang Lembur:", formatRupiah(gajiData!['uangLembur'])),
            ]),

            buildSection("Detail Pajak", [
              detailRow(
                "Jenis Tarif:",
                (widget.bulan != "12")
                    ? "Tarif Efektif Rata-Rata (TER)"
                    : "Tarif Progresif",
              ),
              detailRow(
                "Rentang Penghasilan:",
                gajiData!['rentangPenghasilan'] ?? "-",
              ),
              detailRow(
                "Tarif Pajak:",
                showPajak ? "${gajiData!['tarifPajak']} %" : "Tidak tersedia",
              ),
              detailRow(
                "Potongan Pajak:",
                showPajak
                    ? formatRupiah(gajiData!['potonganPajak'])
                    : "Tidak tersedia",
              ),
            ]),

            buildSection("Total Penghasilan", [
              detailRow(
                "Penghasilan Kotor:",
                formatRupiah(gajiData!['totalGajiBruto']),
              ),
              detailRow(
                "Potongan Pajak:",
                formatRupiah(gajiData!['potonganPajak']),
              ),
              detailRow(
                "Penghasilan Bersih:",
                formatRupiah(gajiData!['totalGajiNetto']),
              ),
            ]),

            const SizedBox(height: 12),
            CustomButton(text: "OK", onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
