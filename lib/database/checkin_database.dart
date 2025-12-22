import 'package:aplikasiabsensi/model/checkin.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckinDatabase {
  final database = Supabase.instance.client.from('AbsensiCheckIn');

  Future<String?> createNewCheckIn(Checkin newCheckin) async {
    try {
      final response = await database
          .insert(newCheckin.toMap())
          .select('checkinID')
          .single();

      final checkinID = response['checkinID'];

      print("✅ Check-in berhasil dibuat dengan ID: $checkinID");
      return checkinID;
    } catch (e) {
      print("❌ Gagal insert check-in: $e");
      return null;
    }
  }

  Stream<List<Checkin>> streamCheckin() {
    return database
        .stream(primaryKey: ['checkinID'])
        .map(
          (data) =>
              data.map((checkinMap) => Checkin.fromMap(checkinMap)).toList(),
        );
  }

  Future<String?> getStatusIdByName(String namaStatus) async {
    final response = await Supabase.instance.client
        .from('jenisStatus')
        .select('statusID')
        .eq('namaStatus', namaStatus)
        .maybeSingle();

    if (response == null) return null;
    return response['statusID'].toString();
  }

  Future<Checkin?> getCheckInTodayByUser(String userID) async {
    final today = DateTime.now();
    final tanggalHariIni = DateFormat('yyyy-MM-dd').format(today);

    try {
      final response = await database
          .select('*, jenisStatus(namaStatus)')
          .eq('userID', userID)
          .eq('tanggalMasuk', tanggalHariIni)
          .maybeSingle();

      if (response == null) return null;

      return Checkin.fromMap(response);
    } catch (e) {
      print('❌ Gagal getCheckInTodayByUser: $e');
      return null;
    }
  }

  Future<Checkin?> getCheckInByUserAndDate(
    String userId,
    String tanggal,
  ) async {
    final response = await database
        .select()
        .eq('userID', userId)
        .eq('tanggalMasuk', tanggal)
        .order('waktuMasuk', ascending: false)
        .limit(1);

    if (response.isEmpty) return null;
    return Checkin.fromMap(response.first);
  }

  Future<Checkin?> getCheckinById(String checkinID) async {
    try {
      final response = await database
          .select('*, jenisStatus(namaStatus)')
          .eq('checkinID', checkinID)
          .maybeSingle();

      if (response == null) return null;
      return Checkin.fromMap(response);
    } catch (e) {
      print('❌ Gagal getCheckinById: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCheckInToday(String userID) async {
    final today = DateTime.now();
    final hariMulai = DateTime(today.year, today.month, today.day);
    final hariAkhir = DateTime(today.year, today.month, today.day, 23, 59, 59);

    try {
      final response = await database
          .select('checkinID, statusID, jenisStatus(namaStatus)')
          .eq('userID', userID)
          .gte('timeCreated', hariMulai.toIso8601String())
          .lte('timeCreated', hariAkhir.toIso8601String());

      if (response.isEmpty) return null;
      return response.first;
    } catch (e) {
      print('❌ Gagal getCheckInToday: $e');
      return null;
    }
  }

  Future<List<Checkin>> getCheckinByMonth(
    String userID,
    int bulan,
    int tahun,
  ) async {
    final startDate = DateTime(tahun, bulan, 1);
    final endDate = DateTime(tahun, bulan + 1, 0);

    final response = await database
        .select('*, jenisStatus(*)')
        .eq('userID', userID)
        .gte('tanggalMasuk', DateFormat('yyyy-MM-dd').format(startDate))
        .lte('tanggalMasuk', DateFormat('yyyy-MM-dd').format(endDate));

    final data = response as List;
    return data.map((map) => Checkin.fromMap(map)).toList();
  }

  /// Update check-in
  Future<void> updateCheckIn(Checkin updatedCheckIn) async {
    try {
      await database
          .update(updatedCheckIn.toMap())
          .eq('checkinID', updatedCheckIn.checkinID!);
    } catch (e) {
      print('❌ Gagal updateCheckIn: $e');
    }
  }

  Future<List<Checkin>> getActiveCheckins() async {
    final today = DateTime.now();
    final tanggalHariIni = DateFormat('yyyy-MM-dd').format(today);

    try {
      final response = await database
          .select('*, jenisStatus(*)')
          .eq('tanggalMasuk', tanggalHariIni);

      final data = response as List;
      return data.map((e) => Checkin.fromMap(e)).toList();
    } catch (e) {
      print('❌ Gagal getActiveCheckins: $e');
      return [];
    }
  }

  Future<int> hitungJumlahHadir({
    required String userId,
    required int tahun,
    required int bulan,
  }) async {
    final supabase = Supabase.instance.client;

    final start = DateTime(tahun, bulan, 1);
    final end = (bulan == 12)
        ? DateTime(tahun + 1, 1, 1)
        : DateTime(tahun, bulan + 1, 1);

    final startDate = DateFormat('yyyy-MM-dd').format(start);
    final endDate = DateFormat('yyyy-MM-dd').format(end);

    try {
      final response = await supabase
          .from('AbsensiCheckIn')
          .select('checkinID')
          .eq('userID', userId)
          .gte('tanggalMasuk', startDate)
          .lt('tanggalMasuk', endDate);

      return response.length;
    } catch (e) {
      print("❌ Gagal hitungJumlahHadir: $e");
      return 0;
    }
  }

  // Future<int> hitungJumlahTidakHadir({
  //   required String userId,
  //   required int tahun,
  //   required int bulan,
  // }) async {
  //   try {
  //     final totalHari = DateTime(tahun, bulan + 1, 0).day;

  //     final jumlahHadir = await hitungJumlahHadir(
  //       userId: userId,
  //       tahun: tahun,
  //       bulan: bulan,
  //     );

  //     final jumlahTidakHadir = totalHari - jumlahHadir;

  //     return jumlahTidakHadir < 0 ? 0 : jumlahTidakHadir;
  //   } catch (e) {
  //     print("❌ Gagal hitungJumlahTidakHadir: $e");
  //     return 0;
  //   }
  // }
}
