// file: cuti_service.dart
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/historygaji_database.dart';
import 'package:aplikasiabsensi/database/pengajuanCuti_database.dart';
import 'package:aplikasiabsensi/model/historyGaji.dart';
import '../model/pengajuanCuti.dart';

class CutiService {
  final DatakaryawanDatabase karyawanDB = DatakaryawanDatabase();
  final HistorygajiDatabase historyDB = HistorygajiDatabase();
  final PengajuancutiDatabase cutiDB = PengajuancutiDatabase();

  // Convert jam desimal ke format HH:mm:ss
  String _jamToString(double jam) {
    final totalSeconds = (jam * 3600).round();
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  // Update history gaji incremental
  Future<void> updateHistoryGaji({
    required String karyawanID,
    required int bulan,
    required int tahun,
    required double jamKerja,
    int tambahUpah = 0,
  }) async {
    final existingGaji = await historyDB.getGajiByPeriode(
      karyawanID,
      bulan,
      tahun,
    );

    if (existingGaji != null) {
      existingGaji.totalJamKerja = _jamToString(jamKerja);

      if (tambahUpah > 0) {
        existingGaji.gajiPokok += tambahUpah;
        existingGaji.totalGajiBruto += tambahUpah;
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
        totalJamLembur: "00:00:00",
        gajiPokok: karyawan.gajiPokok + tambahUpah,
        uangMakan: karyawan.uangMakan.round(),
        uangLembur: 0,
        tarifPajak: 0,
        potonganPajak: 0,
        totalGajiBruto: (karyawan.gajiPokok + tambahUpah + karyawan.uangMakan)
            .round(),
        totalGajiNetto: 0,
        ekspektasiGaji: karyawan.gajiPokok,
      );

      await historyDB.createNewGaji(newGaji);
    }
  }

  // PROSES CUTI
  Future<String> prosesCutiByStatus(Pengajuancuti cuti) async {
    try {
      final karyawan = await karyawanDB.getKaryawanByUserId(cuti.userID!);
      if (karyawan == null) return "❌ Data karyawan tidak ditemukan";

      if (cuti.statusPengajuan != "Pengajuan Disetujui") {
        return "❌ Status cuti belum disetujui";
      }

      // Hitung total hari cuti
      final tglMulai = DateTime.parse(cuti.tanggalMulai);
      final tglSelesai = DateTime.parse(cuti.tanggalSelesai);
      final totalHari = tglSelesai.difference(tglMulai).inDays + 1;

      // RULE 6 HARI KERJA / MINGGU (25 HARI KERJA / BULAN)
      // 8 jam per hari → cuti mengikuti jam kerja normal
      const double jamPerHari = 8.0;
      final totalJamCuti = totalHari * jamPerHari;

      // Upah per jam berdasarkan rule barumu
      final int totalJamKerjaSebulan = 25 * 8; // = 200
      final double upahPerJam =
          (karyawan.gajiPokok + karyawan.uangMakan) / totalJamKerjaSebulan;

      // Upah cuti = upah per jam × total jam cuti
      final int tambahUpah = (upahPerJam * totalJamCuti).round();

      // Update status cuti
      cuti.statusPengajuan = "Pengajuan Disetujui";
      cuti.tanggalVerifikasi = DateTime.now().toIso8601String();
      await cutiDB.updateCuti(cuti);

      // Update history gaji
      await updateHistoryGaji(
        karyawanID: karyawan.karyawanID!,
        bulan: tglMulai.month,
        tahun: tglMulai.year,
        jamKerja: totalJamCuti,
        tambahUpah: tambahUpah,
      );

      return "✅ Cuti ${cuti.tanggalMulai} s/d ${cuti.tanggalSelesai} diproses.\n🕒 Jam Cuti: ${_jamToString(totalJamCuti)}\n💰 Upah Cuti Ditambah: $tambahUpah";
    } catch (e) {
      return "❌ Gagal memproses cuti: $e";
    }
  }
}
