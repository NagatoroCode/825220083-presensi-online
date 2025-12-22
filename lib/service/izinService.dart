// file: izin_service.dart
import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/database/checkout_database.dart';
import 'package:aplikasiabsensi/database/pengajuanIzin_database.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/historygaji_database.dart';
import 'package:aplikasiabsensi/model/pengajuanIzin.dart';
import 'package:aplikasiabsensi/model/historyGaji.dart';

class IzinService {
  final CheckinDatabase checkinDB = CheckinDatabase();
  final CheckoutDatabase checkoutDB = CheckoutDatabase();
  final pengajuanIzinDatabase izinDB = pengajuanIzinDatabase();
  final DatakaryawanDatabase karyawanDB = DatakaryawanDatabase();
  final HistorygajiDatabase historyDB = HistorygajiDatabase();

  String _jamToString(double jam) {
    final totalSeconds = (jam * 3600).round();
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  double _hitungUpahNormal(double gajiPokok, double totalJamKerja) {
    const int jumlahHariKerjaSebulan = 25;
    const int jamKerjaPerHari = 8;
    final totalJamNormalSebulan = jumlahHariKerjaSebulan * jamKerjaPerHari;

    final upahPerJam = gajiPokok / totalJamNormalSebulan;

    return upahPerJam * totalJamKerja;
  }

  Future<void> updateHistoryGaji({
    required String karyawanID,
    required int bulan,
    required int tahun,
    required double jamKerja,
    double jamLembur = 0,
    int tambahUpah = 0,
  }) async {
    final existingGaji = await historyDB.getGajiByPeriode(
      karyawanID,
      bulan,
      tahun,
    );

    if (existingGaji != null) {
      // Update jam kerja & lembur
      existingGaji.totalJamKerja = _jamToString(jamKerja);
      existingGaji.totalJamLembur = _jamToString(jamLembur);

      if (tambahUpah > 0) {
        // Tambah total gaji bruto (WAJIB)
        existingGaji.totalGajiBruto += tambahUpah;

        // Jika lembur → uangLembur harus ikut bertambah
        if (jamLembur > 0) {
          existingGaji.uangLembur += tambahUpah;
        } else {
          // Jika bukan lembur → gajiPokok bertambah (izin normal)
          existingGaji.gajiPokok += tambahUpah;
        }
      }

      await historyDB.updateGajiSaatCICOIncremental(karyawanID, existingGaji);
    } else {
      final karyawan = await karyawanDB.getKaryawanByUserId(karyawanID);
      if (karyawan == null) return;

      final newGaji = Historygaji(
        karyawanID: karyawan.karyawanID,
        periodeBulan: bulan.toString(),
        periodeTahun: tahun.toString(),
        totalJamKerja: _jamToString(jamKerja),
        totalJamLembur: _jamToString(jamLembur),
        gajiPokok: jamLembur > 0
            ? karyawan.gajiPokok
            : karyawan.gajiPokok + tambahUpah,
        uangMakan: karyawan.uangMakan.round(),
        uangLembur: jamLembur > 0 ? tambahUpah : 0,
        tarifPajak: 0,
        potonganPajak: 0,
        totalGajiBruto: (karyawan.gajiPokok + karyawan.uangMakan + tambahUpah)
            .round(),

        totalGajiNetto: 0,
        ekspektasiGaji: karyawan.gajiPokok,
      );

      await historyDB.createNewGaji(newGaji);
    }
  }

  Future<String> prosesIzinByStatus(PengajuanIzin izin) async {
    try {
      final karyawan = await karyawanDB.getKaryawanByUserId(izin.userID!);
      if (karyawan == null) return "❌ Data karyawan tidak ditemukan";

      final gajiPokok = karyawan.gajiPokok.toDouble();

      final status = izin.status?.namaStatus ?? '';
      final tglIzinStr = izin.tanggalIzin;
      final tglIzin = DateTime.parse(tglIzinStr);

      late DateTime jamMulai;
      late DateTime jamSelesai;
      double selisihJam = 0;
      int tambahUpah = 0;

      if (status == "Hadir Terlambat") {
        final checkin = await checkinDB.getCheckInByUserAndDate(
          izin.userID!,
          tglIzinStr,
        );
        if (checkin == null) return "❌ Tidak ada check-in tanggal izin";

        jamMulai = DateTime(tglIzin.year, tglIzin.month, tglIzin.day, 8, 0);

        final waktuCheckin = DateTime.parse(
          "${checkin.tanggalMasuk} ${checkin.waktuMasuk}",
        );

        final batas12 = DateTime(tglIzin.year, tglIzin.month, tglIzin.day, 12);

        jamSelesai = waktuCheckin.isAfter(batas12) ? batas12 : waktuCheckin;

        selisihJam = jamSelesai.difference(jamMulai).inSeconds / 3600.0;

        // Rumus perhitungan izin normal
        tambahUpah = _hitungUpahNormal(gajiPokok, selisihJam).round();
      }
      // ============================
      // ===== PULANG CEPAT =========
      // ============================
      else if (status == "Pulang Cepat") {
        final checkout = await checkoutDB.getCheckOutByUserAndDate(
          izin.userID!,
          tglIzinStr,
        );

        final checkoutTanggal = checkout?.tanggalKeluar ?? tglIzinStr;
        final checkoutWaktu = checkout?.waktuKeluar ?? "17:00:00";

        jamMulai = DateTime.parse("$checkoutTanggal $checkoutWaktu");
        final batas17 = DateTime(tglIzin.year, tglIzin.month, tglIzin.day, 17);

        if (jamMulai.isAfter(batas17)) jamMulai = batas17;

        jamSelesai = batas17;

        selisihJam = jamSelesai.difference(jamMulai).inSeconds / 3600.0;

        tambahUpah = _hitungUpahNormal(gajiPokok, selisihJam).round();
      }
      // ============================
      // ========= LEMBUR ===========
      // ============================
      else if (status == "Lembur") {
        jamMulai = DateTime.parse("${tglIzinStr} ${izin.waktuMulai}");
        jamSelesai = DateTime.parse("${tglIzinStr} ${izin.waktuSelesai}");

        selisihJam = jamSelesai.difference(jamMulai).inSeconds / 3600.0;

        final tarifPerJamLembur = gajiPokok / 173;

        double total = 0;
        if (selisihJam <= 1) {
          total = tarifPerJamLembur * selisihJam * 1.5;
        } else {
          total =
              tarifPerJamLembur * 1 * 1.5 +
              tarifPerJamLembur * (selisihJam - 1) * 2;
        }

        tambahUpah = total.round();
      }
      // ============================
      // ======= TIDAK HADIR ========
      // ============================
      else if (status == "Tidak Hadir") {
        selisihJam = 8.0;
        tambahUpah = _hitungUpahNormal(gajiPokok, selisihJam).round();
      }
      // ============================
      // ===== LUPA CHECK IN ========
      // ============================
      else if (status == "Lupa Check In") {
        final checkout = await checkoutDB.getCheckOutByUserAndDate(
          izin.userID!,
          tglIzinStr,
        );

        final checkoutTanggal = checkout?.tanggalKeluar ?? tglIzinStr;
        final checkoutWaktu = checkout?.waktuKeluar ?? "17:00:00";

        jamMulai = DateTime(tglIzin.year, tglIzin.month, tglIzin.day, 8);
        jamSelesai = DateTime.parse("$checkoutTanggal $checkoutWaktu");

        selisihJam = jamSelesai.difference(jamMulai).inSeconds / 3600.0;

        tambahUpah = _hitungUpahNormal(gajiPokok, selisihJam).round();
      }
      // ============================
      // ===== LUPA CHECK OUT =======
      // ============================
      else if (status == "Lupa Check Out") {
        final checkin = await checkinDB.getCheckInByUserAndDate(
          izin.userID!,
          tglIzinStr,
        );

        final checkinTanggal = checkin?.tanggalMasuk ?? tglIzinStr;
        final checkinWaktu = checkin?.waktuMasuk ?? "08:00:00";

        jamMulai = DateTime.parse("$checkinTanggal $checkinWaktu");
        jamSelesai = DateTime(tglIzin.year, tglIzin.month, tglIzin.day, 17);

        selisihJam = jamSelesai.difference(jamMulai).inSeconds / 3600.0;

        tambahUpah = _hitungUpahNormal(gajiPokok, selisihJam).round();
      } else {
        return "❌ Status izin tidak dikenali";
      }

      // Update waktu izin
      izin.waktuMulai =
          "${jamMulai.hour.toString().padLeft(2, '0')}:${jamMulai.minute.toString().padLeft(2, '0')}:${jamMulai.second.toString().padLeft(2, '0')}";
      izin.waktuSelesai =
          "${jamSelesai.hour.toString().padLeft(2, '0')}:${jamSelesai.minute.toString().padLeft(2, '0')}:${jamSelesai.second.toString().padLeft(2, '0')}";

      // Update status
      izin.statusPengajuan = "Pengajuan Disetujui";
      await izinDB.updateIzin(izin);

      // Update history gaji
      await updateHistoryGaji(
        karyawanID: karyawan.karyawanID!,
        bulan: tglIzin.month,
        tahun: tglIzin.year,
        jamKerja: status == "Lembur" ? 0 : selisihJam,
        jamLembur: status == "Lembur" ? selisihJam : 0,
        tambahUpah: tambahUpah,
      );

      return "✅ Izin $status tanggal $tglIzinStr diproses.\n🕒 Jam Kerja: ${_jamToString(selisihJam)}";
    } catch (e) {
      return "❌ Gagal memproses izin: $e";
    }
  }
}
