import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class Downloadpdf {
  Future<void> downloadSlipGaji({
    required String karyawanID,
    required String bulan,
    required String tahun,
    required Map<String, dynamic> gajiData,
    required int totalJumlahHadir,
    required int totalTidakHadirDisetujui,
    required int totalIzinDisetujui,
    required int hitungSuspended,
    required int totalLemburDisetujui,
    required int totalCutiDisetujui,
  }) async {
    final pdf = pw.Document();

    // Load font Roboto dari assets
    final ttfRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final ttfBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    // Helper untuk null-safe
    String safe(dynamic value) {
      if (value == null) return "0";
      if (value.toString().trim().isEmpty) return "0";
      return value.toString();
    }

    String formatRupiah(dynamic value) {
      if (value == null) value = 0;
      num parsed = 0;
      try {
        parsed = (value is num) ? value : num.parse(value.toString());
      } catch (_) {
        parsed = 0;
      }
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(parsed);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Center(
              child: pw.Text(
                'SLIP GAJI KARYAWAN',
                style: pw.TextStyle(font: ttfBold, fontSize: 22),
              ),
            ),
            pw.Center(
              child: pw.Text(
                "Periode: $bulan - $tahun",
                style: pw.TextStyle(font: ttfRegular, fontSize: 14),
              ),
            ),
            pw.SizedBox(height: 20),

            // Informasi Karyawan
            pw.Text(
              "Informasi Karyawan",
              style: pw.TextStyle(font: ttfBold, fontSize: 16),
            ),
            pw.Divider(),
            pw.Text(
              "Karyawan ID: $karyawanID",
              style: pw.TextStyle(font: ttfRegular),
            ),
            pw.SizedBox(height: 20),

            // Detail Waktu
            pw.Text(
              "Detail Waktu",
              style: pw.TextStyle(font: ttfBold, fontSize: 16),
            ),
            pw.Divider(),
            pw.Table.fromTextArray(
              cellAlignment: pw.Alignment.centerLeft,
              headerStyle: pw.TextStyle(font: ttfBold),
              headers: ["Deskripsi", "Nilai"],
              data: [
                ["Total Jam Kerja", "${safe(gajiData["totalJamKerja"])} jam"],
                ["Total Jam Lembur", "${safe(gajiData["totalJamLembur"])} jam"],
              ],
              cellStyle: pw.TextStyle(font: ttfRegular),
            ),

            // Informasi Hari Presensi
            pw.SizedBox(height: 18),
            pw.Text(
              "Informasi Hari Presensi",
              style: pw.TextStyle(font: ttfBold, fontSize: 16),
            ),
            pw.Divider(),
            pw.Table.fromTextArray(
              cellAlignment: pw.Alignment.centerLeft,
              headers: ["Jenis", "Jumlah"],
              headerStyle: pw.TextStyle(font: ttfBold),
              data: [
                ["Jumlah Hadir", "$totalJumlahHadir Hari"],
                ["Jumlah Tidak Hadir", "$totalTidakHadirDisetujui Hari"],
                ["Jumlah Suspended", "$hitungSuspended Hari"],
                ["Jumlah Izin Kerja", "$totalIzinDisetujui Kali"],
                ["Jumlah Izin Cuti", "$totalCutiDisetujui Hari"],
                ["Jumlah Izin Lembur", "$totalLemburDisetujui Kali"],
              ],
              cellStyle: pw.TextStyle(font: ttfRegular),
            ),

            // Informasi Penghasilan
            pw.SizedBox(height: 18),
            pw.Text(
              "Informasi Penghasilan",
              style: pw.TextStyle(font: ttfBold, fontSize: 16),
            ),
            pw.Divider(),
            pw.Table.fromTextArray(
              headers: ["Komponen", "Jumlah"],
              headerStyle: pw.TextStyle(font: ttfBold),
              data: [
                ["Ekspektasi Gaji", formatRupiah(gajiData["ekspektasiGaji"])],
                ["Gaji Pokok", formatRupiah(gajiData["gajiPokok"])],
                ["Uang Makan", formatRupiah(gajiData["uangMakan"])],
                ["Uang Lembur", formatRupiah(gajiData["uangLembur"])],
              ],
              cellStyle: pw.TextStyle(font: ttfRegular),
            ),

            // Detail Pajak
            pw.SizedBox(height: 18),
            pw.Text(
              "Detail Pajak",
              style: pw.TextStyle(font: ttfBold, fontSize: 16),
            ),
            pw.Divider(),
            pw.Table.fromTextArray(
              headers: ["Pajak", "Nilai"],
              headerStyle: pw.TextStyle(font: ttfBold),
              data: [
                ["Jenis Tarif", bulan != "12" ? "TER" : "Progresif"],
                [
                  "Tarif Pajak",
                  gajiData["tarifPajak"] == null
                      ? "0%"
                      : "${gajiData["tarifPajak"]}%",
                ],
                ["Potongan Pajak", formatRupiah(gajiData["potonganPajak"])],
              ],
              cellStyle: pw.TextStyle(font: ttfRegular),
            ),

            // Total Penghasilan
            pw.SizedBox(height: 18),
            pw.Text(
              "Total Penghasilan",
              style: pw.TextStyle(font: ttfBold, fontSize: 16),
            ),
            pw.Divider(),
            pw.Table.fromTextArray(
              headers: ["Deskripsi", "Jumlah"],
              headerStyle: pw.TextStyle(font: ttfBold),
              data: [
                ["Penghasilan Kotor", formatRupiah(gajiData["totalGajiBruto"])],
                ["Potongan Pajak", formatRupiah(gajiData["potonganPajak"])],
                [
                  "Penghasilan Bersih",
                  formatRupiah(gajiData["totalGajiNetto"]),
                ],
              ],
              cellStyle: pw.TextStyle(font: ttfRegular),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
