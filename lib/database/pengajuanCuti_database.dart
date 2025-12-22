import 'package:aplikasiabsensi/model/jenisCuti.dart';
import 'package:aplikasiabsensi/model/pengajuanCuti.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengajuancutiDatabase {
  final database = Supabase.instance.client.from('pengajuanCuti');

  Future<String?> createNewCuti(Pengajuancuti cuti) async {
    final response = await Supabase.instance.client
        .from('pengajuanCuti')
        .insert(cuti.toMap())
        .select('cutiID')
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return response['cutiID']?.toString();
  }

  // Baca Pengajuan Cuti
  final streamPengajuanCuti = Supabase.instance.client
      .from('pengajuanCuti')
      .stream(primaryKey: ["cutiID"])
      .map(
        (data) =>
            data.map((cutiMap) => Pengajuancuti.fromMap(cutiMap)).toList(),
      );

  // Baca pengajuan cuti + relasi jenisCuti
  Future<List<Pengajuancuti>> getStatusWithCuti() async {
    final response = await Supabase.instance.client
        .from('pengajuanCuti')
        .select('*, jenisCuti(*)');

    final data = response as List;

    return data.map((cutiMap) {
      final cutiJenis = cutiMap['jenisCuti'] != null
          ? jenisCuti.fromMap(cutiMap['jenisCuti'])
          : null;

      final pengajuan = Pengajuancuti.fromMap(cutiMap);
      pengajuan.cuti = cutiJenis;

      return pengajuan;
    }).toList();
  }

  Future<void> updateCuti(Pengajuancuti updatedCuti) async {
    await database
        .update(updatedCuti.toMap())
        .eq('cutiID', updatedCuti.cutiID!);
  }

  Future<List<Pengajuancuti>> getStatusWithCutiByUser(String userID) async {
    final response = await Supabase.instance.client
        .from('pengajuanCuti')
        .select('*, jenisCuti(*)')
        .eq('userID', userID)
        .order('tanggalMulai', ascending: false);

    final data = response as List;

    return data.map((cutiMap) {
      final cutiJenis = cutiMap['jenisCuti'] != null
          ? jenisCuti.fromMap(cutiMap['jenisCuti'])
          : null;

      final pengajuan = Pengajuancuti.fromMap(cutiMap);
      pengajuan.cuti = cutiJenis;

      return pengajuan;
    }).toList();
  }

  Future<int> hitungJumlahCuti({
    required String userId,
    required int tahun,
    required int bulan,
  }) async {
    final supabase = Supabase.instance.client;

    final startOfMonth = DateTime(tahun, bulan, 1);
    final endOfMonth = (bulan == 12)
        ? DateTime(tahun + 1, 1, 1)
        : DateTime(tahun, bulan + 1, 1);

    final startDate = startOfMonth.toIso8601String().substring(0, 10);
    final endDate = endOfMonth.toIso8601String().substring(0, 10);

    // Ambil semua cuti yang disetujui + join inner ke jenisCuti
    final response = await supabase
        .from('pengajuanCuti')
        .select('*, jenisCuti!inner(namaCuti)')
        .eq('userID', userId)
        .eq('statusPengajuan', 'Pengajuan Disetujui')
        .gte('tanggalMulai', startDate)
        .lt('tanggalMulai', endDate);

    int totalHari = 0;

    for (final cuti in response) {
      final mulai = DateTime.parse(cuti['tanggalMulai']);
      final selesai = DateTime.parse(cuti['tanggalSelesai']);

      final effectiveStart = mulai.isBefore(startOfMonth)
          ? startOfMonth
          : mulai;

      final effectiveEnd = selesai.isBefore(endOfMonth)
          ? selesai
          : endOfMonth.subtract(Duration(days: 1));

      final durasi = effectiveEnd.difference(effectiveStart).inDays + 1;

      if (durasi > 0) {
        totalHari += durasi;
      }
    }

    return totalHari;
  }
}
