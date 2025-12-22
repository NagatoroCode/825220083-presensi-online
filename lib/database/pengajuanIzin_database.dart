import 'package:aplikasiabsensi/model/jenisStatus.dart';
import 'package:aplikasiabsensi/model/pengajuanIzin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class pengajuanIzinDatabase {
  final database = Supabase.instance.client.from('pengajuanIzin');

  Future<String?> createNewIzin(PengajuanIzin newIzin) async {
    final response = await Supabase.instance.client
        .from('pengajuanIzin')
        .insert(newIzin.toMap())
        .select('izinID')
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return response['izinID']?.toString();
  }

  final streamPengajuanIzin = Supabase.instance.client
      .from('pengajuanIzin')
      .stream(primaryKey: ["izinID"])
      .map((data) {
        return data.map((izinMap) => PengajuanIzin.fromMap(izinMap)).toList();
      });

  Future<List<PengajuanIzin>> getStatusWithIzin() async {
    final response = await Supabase.instance.client
        .from('pengajuanIzin')
        .select('*, jenisStatus(*)');

    final data = response as List;

    return data.map((izinMap) {
      final izinJenis = izinMap['jenisStatus'] != null
          ? jenisStatus.fromMap(izinMap['jenisStatus'])
          : null;

      final pengajuan = PengajuanIzin.fromMap(izinMap);
      pengajuan.status = izinJenis;

      return pengajuan;
    }).toList();
  }

  Future<PengajuanIzin?> getApprovedLemburByUserAndDate(
    String userId,
    String tanggal,
  ) async {
    final response = await database
        .select()
        .eq('userID', userId)
        .eq('statusPengajuan', 'Disetujui')
        .eq('tanggalIzin', tanggal)
        .maybeSingle();

    if (response == null) return null;
    return PengajuanIzin.fromMap(response);
  }

  Future<void> updateIzin(PengajuanIzin updateIzin) async {
    await database.update(updateIzin.toMap()).eq('izinID', updateIzin.izinID!);
  }

  Future<List<PengajuanIzin>> getStatusWithIzinByUser(String userID) async {
    final response = await Supabase.instance.client
        .from('pengajuanIzin')
        .select('*, jenisStatus(*)')
        .eq('userID', userID)
        .order('tanggalIzin', ascending: false);

    final data = response as List;

    return data.map((izinMap) {
      final izinJenis = izinMap['jenisStatus'] != null
          ? jenisStatus.fromMap(izinMap['jenisStatus'])
          : null;

      final pengajuan = PengajuanIzin.fromMap(izinMap);
      pengajuan.status = izinJenis;

      return pengajuan;
    }).toList();
  }

  Future<PengajuanIzin?> getIzinById(String izinID) async {
    try {
      final response = await database
          .select('*, jenisStatus(*)')
          .eq('izinID', izinID)
          .maybeSingle();

      if (response == null) return null;

      final pengajuan = PengajuanIzin.fromMap(response);

      if (response['jenisStatus'] != null) {
        pengajuan.status = jenisStatus.fromMap(response['jenisStatus']);
      }

      return pengajuan;
    } catch (e) {
      print("❌ Gagal ambil izin by ID: $e");
      return null;
    }
  }

  Future<PengajuanIzin?> getIzinByUserAndDate(
    String userId,
    String tanggal,
  ) async {
    try {
      final response = await Supabase.instance.client
          .from('pengajuanIzin')
          .select()
          .eq('userID', userId)
          .eq('tanggalIzin', tanggal)
          .maybeSingle();

      if (response == null) return null;

      return PengajuanIzin.fromMap(response);
    } catch (e) {
      print("❌ Gagal get izin by user & date: $e");
      return null;
    }
  }

  Future<List<PengajuanIzin>> getApprovedIzinByUser(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('pengajuanIzin')
          .select()
          .eq('userID', userId)
          .eq('statusPengajuan', 'Pengajuan Disetujui')
          .order('tanggalIzin', ascending: true);

      if (response.isEmpty) {
        print("⚠️ Tidak ada izin disetujui untuk user $userId");
        return [];
      }

      return (response as List)
          .map((izinMap) => PengajuanIzin.fromMap(izinMap))
          .toList();
    } catch (e) {
      print("❌ Gagal ambil daftar izin disetujui: $e");
      return [];
    }
  }

  Future<bool> canSubmitJenisStatusOnDate(
    String userId,
    String statusID,
    String tanggal,
  ) async {
    try {
      final response = await Supabase.instance.client
          .from('pengajuanIzin')
          .select()
          .eq('userID', userId)
          .eq('tanggalIzin', tanggal)
          .eq('statusID', statusID)
          .not('statusPengajuan', 'in', ['Pengajuan Dibatalkan'])
          .maybeSingle();

      return response == null;
    } catch (e) {
      print("❌ Error cek jenis status per tanggal: $e");
      return false;
    }
  }

  Future<int> hitungSuratIzinDisetujui({
    required String userId,
    required int tahun,
    required int bulan,
  }) async {
    final supabase = Supabase.instance.client;

    final start = DateTime(tahun, bulan, 1);
    final end = (bulan == 12)
        ? DateTime(tahun + 1, 1, 1)
        : DateTime(tahun, bulan + 1, 1);

    final startDate = start.toIso8601String().substring(0, 10);
    final endDate = end.toIso8601String().substring(0, 10);

    final response = await supabase
        .from('pengajuanIzin')
        .select('*, jenisStatus!inner(namaStatus)')
        .eq('userID', userId)
        .eq('statusPengajuan', 'Pengajuan Disetujui')
        .gte('tanggalIzin', startDate)
        .lt('tanggalIzin', endDate)
        .inFilter('jenisStatus.namaStatus', [
          'Hadir Terlambat',
          'Pulang Cepat',
        ]);

    return response.length;
  }

  Future<int> hitungTidakHadirDisetujui({
    required String userId,
    required int tahun,
    required int bulan,
  }) async {
    final supabase = Supabase.instance.client;

    final start = DateTime(tahun, bulan, 1);
    final end = (bulan == 12)
        ? DateTime(tahun + 1, 1, 1)
        : DateTime(tahun, bulan + 1, 1);

    final startDate = start.toIso8601String().substring(0, 10);
    final endDate = end.toIso8601String().substring(0, 10);

    final response = await supabase
        .from('pengajuanIzin')
        .select('*, jenisStatus!inner(namaStatus)')
        .eq('userID', userId)
        .eq('statusPengajuan', 'Pengajuan Disetujui')
        .inFilter('jenisStatus.namaStatus', ['Tidak Hadir'])
        .gte('tanggalIzin', startDate)
        .lt('tanggalIzin', endDate);

    return response.length;
  }

  Future<int> hitungSuspended({
    required String userId,
    required int tahun,
    required int bulan,
  }) async {
    final supabase = Supabase.instance.client;

    final start = DateTime(tahun, bulan, 1);
    final end = (bulan == 12)
        ? DateTime(tahun + 1, 1, 1)
        : DateTime(tahun, bulan + 1, 1);

    final startDate = start.toIso8601String().substring(0, 10);
    final endDate = end.toIso8601String().substring(0, 10);

    final response = await supabase
        .from('pengajuanIzin')
        .select('*, jenisStatus!inner(namaStatus)')
        .eq('userID', userId)
        .eq('statusPengajuan', 'Pengajuan Disetujui')
        .inFilter('jenisStatus.namaStatus', ['Lupa Check In', 'Lupa Check Out'])
        .gte('tanggalIzin', startDate)
        .lt('tanggalIzin', endDate);

    return response.length;
  }

  Future<int> hitungLembur({
    required String userId,
    required int tahun,
    required int bulan,
  }) async {
    final supabase = Supabase.instance.client;

    final start = DateTime(tahun, bulan, 1);
    final end = (bulan == 12)
        ? DateTime(tahun + 1, 1, 1)
        : DateTime(tahun, bulan + 1, 1);

    final startDate = start.toIso8601String().substring(0, 10);
    final endDate = end.toIso8601String().substring(0, 10);

    final response = await supabase
        .from('pengajuanIzin')
        .select('*, jenisStatus!inner(namaStatus)')
        .eq('userID', userId)
        .eq('statusPengajuan', 'Pengajuan Disetujui')
        .inFilter('jenisStatus.namaStatus', ['Lembur'])
        .gte('tanggalIzin', startDate)
        .lt('tanggalIzin', endDate);

    return response.length;
  }
}
