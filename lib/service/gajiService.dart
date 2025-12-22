// file: gaji_service.dart
import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/database/checkout_database.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/historygaji_database.dart';
import 'package:aplikasiabsensi/model/historyGaji.dart';
import 'package:intl/intl.dart';

class GajiService {
  final CheckinDatabase checkinDB = CheckinDatabase();
  final CheckoutDatabase checkoutDB = CheckoutDatabase();
  final DatakaryawanDatabase karyawanDB = DatakaryawanDatabase();
  final HistorygajiDatabase historyDB = HistorygajiDatabase();

  String _jamToString(double jam) {
    final totalSeconds = (jam * 3600).round();
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Future<String> hitungGajiBulanan(String userId, int bulan, int tahun) async {
    try {
      final karyawan = await karyawanDB.getKaryawanByUserId(userId);
      if (karyawan == null) {
        return "❌ Data karyawan tidak ditemukan.";
      }

      final checkins = await checkinDB.getCheckinByMonth(userId, bulan, tahun);
      final checkouts = await checkoutDB.getCheckoutByMonth(
        userId,
        bulan,
        tahun,
      );

      double totalJamKerja = 0;
      int jumlahHariMasuk = 0;

      final tanggalUnik = checkins.map((e) => e.tanggalMasuk).toSet();
      for (var tanggal in tanggalUnik) {
        final checkinHarian = checkins
            .where((c) => c.tanggalMasuk == tanggal)
            .toList();
        final checkoutHarian = checkouts
            .where((c) => c.tanggalKeluar == tanggal)
            .toList();

        if (checkinHarian.isEmpty || checkoutHarian.isEmpty) {
          continue;
        }

        DateTime waktuMasuk = checkinHarian
            .map((e) => DateTime.parse("${e.tanggalMasuk} ${e.waktuMasuk}"))
            .reduce((a, b) => a.isBefore(b) ? a : b);

        DateTime waktuKeluar = checkoutHarian
            .map((e) => DateTime.parse("${e.tanggalKeluar} ${e.waktuKeluar}"))
            .reduce((a, b) => a.isAfter(b) ? a : b);

        final batasAkhir = DateTime(
          waktuKeluar.year,
          waktuKeluar.month,
          waktuKeluar.day,
          17,
          0,
        );

        if (waktuKeluar.isAfter(batasAkhir)) {
          waktuKeluar = batasAkhir;
        }

        final istirahatMulai = DateTime(
          waktuMasuk.year,
          waktuMasuk.month,
          waktuMasuk.day,
          12,
          0,
        );
        final istirahatSelesai = DateTime(
          waktuMasuk.year,
          waktuMasuk.month,
          waktuMasuk.day,
          13,
          0,
        );

        double durasiJam = waktuKeluar.difference(waktuMasuk).inSeconds / 3600;

        if (waktuKeluar.isAfter(istirahatMulai) &&
            waktuMasuk.isBefore(istirahatSelesai)) {
          final mulaiPotong = waktuMasuk.isAfter(istirahatMulai)
              ? waktuMasuk
              : istirahatMulai;
          final selesaiPotong = waktuKeluar.isBefore(istirahatSelesai)
              ? waktuKeluar
              : istirahatSelesai;

          final potonganIstirahat = selesaiPotong.difference(mulaiPotong);
          durasiJam -= (potonganIstirahat.inSeconds / 3600);
        }

        if (durasiJam > 0) {
          totalJamKerja += durasiJam;
          jumlahHariMasuk++;
        }
      }

      // ============================
      //     PERHITUNGAN GURU BARU
      // ============================

      final double gajiPokok = karyawan.gajiPokok.toDouble();
      final double uangMakan = karyawan.uangMakan.toDouble();

      // Rumus 6 hari kerja
      final int jumlahHariKerjaSebulan = 25;
      final int jamKerjaPerHari = 8;
      final int totalJamKerjaNormalSebulan =
          jumlahHariKerjaSebulan * jamKerjaPerHari;

      final double upahPerJam = gajiPokok / totalJamKerjaNormalSebulan;

      final double totalGaji = upahPerJam * totalJamKerja;

      // Gaji bruto
      final int totalGajiBruto = (totalGaji + uangMakan).round();

      final newGaji = Historygaji(
        karyawanID: karyawan.karyawanID,
        periodeBulan: bulan.toString(),
        periodeTahun: tahun.toString(),
        totalJamKerja: _jamToString(totalJamKerja),
        totalJamLembur: "00:00:00",
        ekspektasiGaji: karyawan.gajiPokok,
        gajiPokok: totalGaji.round(),
        uangMakan: uangMakan.round(),
        uangLembur: 0,
        tarifPajak: 0,
        potonganPajak: 0,
        totalGajiBruto: totalGajiBruto,
        totalGajiNetto: 0,
      );

      final existing = await historyDB.getGajiByPeriode(
        karyawan.karyawanID!,
        bulan,
        tahun,
      );

      if (existing != null) {
        await historyDB.updateGajiSaatCICOIncremental(
          karyawan.karyawanID!,
          newGaji,
        );
      } else {
        await historyDB.createNewGaji(newGaji);
      }

      return """
Gaji bulan ${DateFormat('MMMM yyyy').format(DateTime(tahun, bulan))} berhasil dihitung.
Total Jam Kerja: ${_jamToString(totalJamKerja)}
Hari Masuk: $jumlahHariMasuk hari
Upah per Jam: Rp${upahPerJam.toStringAsFixed(2)}
---------------------------------
Total Gaji Bruto: Rp$totalGajiBruto
""";
    } catch (e) {
      return "❌ Terjadi kesalahan saat menghitung gaji: $e";
    }
  }
}
