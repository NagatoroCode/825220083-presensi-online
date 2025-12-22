import 'package:aplikasiabsensi/model/jabatan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class jabatanDatabase {
  final database = Supabase.instance.client.from('jenisJabatan');

  Future createJabatan(newJabatan) async {
    await database.insert(newJabatan.toMap());
  }

  // Baca nama role
  final StreamJabatan = Supabase.instance.client
      .from('jenisJabatan')
      .stream(primaryKey: ["jabatanID"])
      .map(
        (data) =>
            data.map((jabatanMap) => Jabatan.fromMap(jabatanMap)).toList(),
      );

  Future<List<Jabatan>> getAllJabatan() async {
    final response = await Supabase.instance.client
        .from('jenisJabatan')
        .select();

    return (response as List)
        .map((jabatanMap) => Jabatan.fromMap(jabatanMap))
        .toList();
  }

  // Update nama role
  Future<void> updateJabatan(Jabatan updatedJabatan) async {
    await database
        .update({'namaJabatan': updatedJabatan.namaJabatan})
        .eq('jabatanID', updatedJabatan.jabatanID!);
  }

  Future<void> deleteJabatan(String jabatanID) async {
    await database.delete().eq('jabatanID', jabatanID);
  }
}
