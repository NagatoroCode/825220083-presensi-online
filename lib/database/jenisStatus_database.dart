import 'package:aplikasiabsensi/model/jenisStatus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JenisstatusDatabase {
  final database = Supabase.instance.client.from('jenisStatus');

  Future createNewStatus(newStatus) async {
    await database.insert(newStatus.toMap());
  }

  // 🔹 Stream data status
  final StreamStatus = Supabase.instance.client
      .from('jenisStatus')
      .stream(primaryKey: ["statusID"])
      .map(
        (data) =>
            data.map((statusMap) => jenisStatus.fromMap(statusMap)).toList(),
      );

  Future<List<jenisStatus>> getAllStatus() async {
    final response = await database.select();
    final data = response as List;
    return data.map((map) => jenisStatus.fromMap(map)).toList();
  }

  // 🔹 Update nama jenis status
  Future<void> updateStatus(jenisStatus updatedStatus) async {
    await database
        .update({'namaStatus': updatedStatus.namaStatus})
        .eq('statusID', updatedStatus.statusID!);
  }

  // 🔹 Hapus status
  Future<void> deleteStatus(String statusID) async {
    await database.delete().eq('statusID', statusID);
  }

  // Ambil statusID berdasarkan nama status
  Future<String?> getStatusIdByName(String namaStatus) async {
    final response = await Supabase.instance.client
        .from('jenisStatus')
        .select('statusID')
        .eq('namaStatus', namaStatus)
        .maybeSingle();

    if (response == null) return null;
    return (response['statusID'].toString());
  }

  Future<jenisStatus?> getStatusByNama(String namaStatus) async {
    final response = await database
        .select()
        .eq('namaStatus', namaStatus)
        .maybeSingle();

    if (response == null) return null;
    return jenisStatus.fromMap(response);
  }
}
