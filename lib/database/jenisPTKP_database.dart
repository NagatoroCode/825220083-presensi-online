import 'package:aplikasiabsensi/model/jenisPTKP.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JenisptkpDatabase {
  final database = Supabase.instance.client.from('jenisPTKP');

  Future createNewPTKP(newPTKP) async {
    await database.insert(newPTKP.toMap());
  }

  // Baca nama Jenis PTKP
  final streamPTKP = Supabase.instance.client
      .from('jenisPTKP')
      .stream(primaryKey: ["ptkpID"])
      .map(
        (data) => data.map((ptkpMap) => JenisPTKP.fromMap(ptkpMap)).toList(),
      );

  Future<List<JenisPTKP>> getAllPTKP() async {
    final response = await Supabase.instance.client
        .from('jenisPTKP')
        .select(); // ambil semua kolom

    return (response as List)
        .map((ptkpMap) => JenisPTKP.fromMap(ptkpMap))
        .toList();
  }

  // Update jenis PTKP
  Future<void> updatePTKP(JenisPTKP updatedPTKP) async {
    await database
        .update(updatedPTKP.toMap())
        .eq('ptkpID', updatedPTKP.ptkpID!);
  }

  Future<void> deletePTKP(String ptkpID) async {
    await database.delete().eq('ptkpID', ptkpID);
  }
}
