// file: historygaji_database.dart
import 'package:aplikasiabsensi/model/historyGaji.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistorygajiDatabase {
  final database = Supabase.instance.client.from('historyGaji');
  final supabase = Supabase.instance.client;

  final streamGaji = Supabase.instance.client
      .from('historyGaji')
      .stream(primaryKey: ["gajiID"])
      .map((data) => data.map((map) => Historygaji.fromMap(map)).toList());

  Future<Historygaji?> getGajiByPeriode(
    String karyawanID,
    int bulan,
    int tahun,
  ) async {
    try {
      final res = await supabase
          .from('historyGaji')
          .select()
          .eq('karyawanID', karyawanID)
          .eq('periodeBulan', bulan.toString())
          .eq('periodeTahun', tahun.toString())
          .maybeSingle();
      if (res != null) {
        return Historygaji.fromMap(res);
      }
      return null;
    } catch (e) {
      print("❌ Gagal ambil gaji by periode: $e");
      return null;
    }
  }

  Duration _parseTime(String timeString) {
    final parts = timeString.split(':');
    if (parts.length < 2) return Duration.zero;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Future<void> updateGajiSaatCICOIncremental(
    String karyawanID,
    Historygaji newGaji,
  ) async {
    final bulan = int.parse(newGaji.periodeBulan);
    final tahun = int.parse(newGaji.periodeTahun);
    try {
      final existing = await supabase
          .from('historyGaji')
          .select()
          .eq('karyawanID', karyawanID)
          .eq('periodeBulan', bulan.toString())
          .eq('periodeTahun', tahun.toString())
          .maybeSingle();

      if (existing != null) {
        final oldGaji = Historygaji.fromMap(existing);

        final totalJamKerja = _formatDuration(
          _parseTime(oldGaji.totalJamKerja) + _parseTime(newGaji.totalJamKerja),
        );
        final totalJamLembur = _formatDuration(
          _parseTime(oldGaji.totalJamLembur) +
              _parseTime(newGaji.totalJamLembur),
        );

        final updatedGaji = Historygaji(
          gajiID: oldGaji.gajiID,
          karyawanID: oldGaji.karyawanID,
          tarifTerID: newGaji.tarifTerID ?? oldGaji.tarifTerID,
          tarifProgresifID:
              newGaji.tarifProgresifID ?? oldGaji.tarifProgresifID,
          periodeBulan: oldGaji.periodeBulan,
          periodeTahun: oldGaji.periodeTahun,
          totalJamKerja: totalJamKerja,
          totalJamLembur: totalJamLembur,
          ekspektasiGaji: newGaji.ekspektasiGaji,
          gajiPokok: newGaji.gajiPokok,
          uangMakan: newGaji.uangMakan,
          uangLembur: newGaji.uangLembur,
          tarifPajak: newGaji.tarifPajak,
          potonganPajak: newGaji.potonganPajak,
          totalGajiBruto: newGaji.totalGajiBruto,
          totalGajiNetto: newGaji.totalGajiNetto,
        );

        await supabase
            .from('historyGaji')
            .update(updatedGaji.toMap())
            .eq('gajiID', oldGaji.gajiID!);
      } else {
        await createNewGaji(newGaji);
      }
    } catch (e) {
      print("❌ Gagal update/insert gaji: $e");
    }
  }

  Future<void> updateLemburOnly(
    String karyawanID,
    Historygaji oldGaji,
    String tambahanJamLembur,
    double tambahanUangLembur,
  ) async {
    try {
      final totalJamLembur = _formatDuration(
        _parseTime(oldGaji.totalJamLembur) + _parseTime(tambahanJamLembur),
      );

      final updatedGaji = Historygaji(
        gajiID: oldGaji.gajiID,
        karyawanID: oldGaji.karyawanID,
        tarifTerID: oldGaji.tarifTerID,
        tarifProgresifID: oldGaji.tarifProgresifID,
        periodeBulan: oldGaji.periodeBulan,

        periodeTahun: oldGaji.periodeTahun,
        totalJamKerja: oldGaji.totalJamKerja,
        totalJamLembur: totalJamLembur,
        ekspektasiGaji: oldGaji.ekspektasiGaji,
        gajiPokok: oldGaji.gajiPokok,
        uangMakan: oldGaji.uangMakan,
        uangLembur: oldGaji.uangLembur + tambahanUangLembur.round(),
        tarifPajak: oldGaji.tarifPajak,
        potonganPajak: oldGaji.potonganPajak,
        totalGajiBruto:
            oldGaji.gajiPokok +
            oldGaji.uangMakan +
            (oldGaji.uangLembur + tambahanUangLembur.round()),
        totalGajiNetto:
            oldGaji.gajiPokok +
            oldGaji.uangMakan +
            (oldGaji.uangLembur + tambahanUangLembur.round()),
      );

      await supabase
          .from('historyGaji')
          .update(updatedGaji.toMap())
          .eq('gajiID', oldGaji.gajiID!);
    } catch (e) {
      print("❌ Gagal update jam lembur saja: $e");
    }
  }

  // Insert data baru ke historyGaji
  Future<void> createNewGaji(Historygaji newGaji) async {
    try {
      await database.insert(newGaji.toMap());
    } catch (e) {
      print("❌ Gagal insert gaji baru: $e");
    }
  }
}
