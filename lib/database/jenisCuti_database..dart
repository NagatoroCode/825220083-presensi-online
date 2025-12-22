import 'package:aplikasiabsensi/model/jenisCuti.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class jenisCutiDatabase {
  final database = Supabase.instance.client.from('jenisCuti');

  Future createNewCuti(newCuti) async {
    await database.insert(newCuti.toMap());
  }

  // Baca nama Jenis Cuti
  final streamCuti = Supabase.instance.client
      .from('jenisCuti')
      .stream(primaryKey: ["jenisCutiID"])
      .map(
        (data) => data.map((cutiMap) => jenisCuti.fromMap(cutiMap)).toList(),
      );

  Future<List<jenisCuti>> getAllCuti() async {
    final response = await database.select();
    final data = response as List;
    return data.map((map) => jenisCuti.fromMap(map)).toList();
  }

  // Update nama Jenis cuti
  Future<void> updateCuti(jenisCuti updatedCuti) async {
    await database
        .update(updatedCuti.toMap())
        .eq('jenisCutiID', updatedCuti.jenisCutiID!);
  }

  Future<void> deleteCuti(String jenisCutiID) async {
    await database.delete().eq('jenisCutiID', jenisCutiID);
  }
}
