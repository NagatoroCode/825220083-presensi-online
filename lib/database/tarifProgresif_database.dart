import 'package:aplikasiabsensi/model/tarifProgresif.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TarifprogresifDatabase {
  final database = Supabase.instance.client.from('tarifProgresif');

  Future<void> createNewProgresif(tarifProgresif newProgresif) async {
    await database.insert(newProgresif.toMap());
  }

  Stream<List<tarifProgresif>> get streamProgresif {
    return database.stream(primaryKey: ['tarifProgresifID']).map((event) {
      final list = event as List<dynamic>;
      return list
          .map((e) => tarifProgresif.fromMap(e as Map<String, dynamic>))
          .toList();
    });
  }

  // Stream realtime data
  final streamTER = Supabase.instance.client
      .from('tarifProgresif')
      .stream(primaryKey: ["tarifProgresifID"])
      .map(
        (data) => data
            .map((progresifMap) => tarifProgresif.fromMap(progresifMap))
            .toList(),
      );

  // Fetch data sekali (bukan stream)
  Future<List<tarifProgresif>> fetchAllProgresif() async {
    final response = await database.select();
    return response
        .map<tarifProgresif>((map) => tarifProgresif.fromMap(map))
        .toList();
  }

  Future<void> updateProgresif(tarifProgresif updatedProgresif) async {
    await database
        .update(updatedProgresif.toMap())
        .eq('tarifProgresifID', updatedProgresif.tarifProgresifID!);
  }

  Future<void> deleteProgresif(String tarifProgresifID) async {
    await database.delete().eq('tarifProgresifID', tarifProgresifID);
  }
}
