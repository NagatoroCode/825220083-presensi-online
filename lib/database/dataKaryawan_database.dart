import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/model/jabatan.dart';
import 'package:aplikasiabsensi/model/jenisPTKP.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatakaryawanDatabase {
  final database = Supabase.instance.client.from('dataKaryawan');

  // Tambah karyawan baru
  Future createNewKaryawan(dataKaryawan newKaryawan) async {
    await database.insert(newKaryawan.toMap());
  }

  // 🔹 Ambil semua karyawan dengan relasi jabatan & jenisPTKP
  Future<List<dataKaryawan>> getKaryawanWithJabatan() async {
    final response = await Supabase.instance.client
        .from('dataKaryawan')
        .select('*, jenisJabatan(*), jenisPTKP(*)');

    final data = response as List;

    return data.map((karyawanMap) {
      final jabatan = karyawanMap['jenisJabatan'] != null
          ? Jabatan.fromMap(karyawanMap['jenisJabatan'])
          : null;

      final ptkp = karyawanMap['jenisPTKP'] != null
          ? JenisPTKP.fromMap(karyawanMap['jenisPTKP'])
          : null;

      final karyawan = dataKaryawan.fromMap(karyawanMap);
      karyawan.jabatan = jabatan;
      karyawan.jenisPTKP = ptkp;

      return karyawan;
    }).toList();
  }

  Future<dataKaryawan?> getKaryawanByUserId(String userId) async {
    final response = await Supabase.instance.client
        .from('dataKaryawan')
        .select('*, jenisJabatan(*), jenisPTKP(*)')
        .eq('userID', userId)
        .maybeSingle();

    if (response == null) return null;

    final jabatan = response['jenisJabatan'] != null
        ? Jabatan.fromMap(response['jenisJabatan'])
        : null;

    final ptkp = response['jenisPTKP'] != null
        ? JenisPTKP.fromMap(response['jenisPTKP'])
        : null;

    final karyawan = dataKaryawan.fromMap(response);
    karyawan.jabatan = jabatan;
    karyawan.jenisPTKP = ptkp;

    return karyawan;
  }

  Future<dataKaryawan?> getKaryawanByID(String karyawanID) async {
    final response = await Supabase.instance.client
        .from('dataKaryawan')
        .select('*, jenisJabatan(*), jenisPTKP(*)')
        .eq('karyawanID', karyawanID)
        .maybeSingle();

    if (response == null) return null;

    final karyawan = dataKaryawan.fromMap(response);

    return karyawan;
  }

  // Update data karyawan
  Future<void> updateKaryawan(dataKaryawan updatedKaryawan) async {
    await database
        .update(updatedKaryawan.toMap())
        .eq('karyawanID', updatedKaryawan.karyawanID!);
  }

  // Hapus data karyawan
  Future<void> deleteKaryawan(String karyawanID) async {
    await database.delete().eq('karyawanID', karyawanID);
  }
}
