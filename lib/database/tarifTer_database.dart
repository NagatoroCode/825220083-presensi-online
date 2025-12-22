import 'package:aplikasiabsensi/model/tarifTER.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TarifterDatabase {
  final database = Supabase.instance.client.from('tarifTER');

  Future createNewTER(tarifTer newTER) async {
    await database.insert(newTER.toMap());
  }

  // Stream realtime data
  final streamTER = Supabase.instance.client
      .from('tarifTER')
      .stream(primaryKey: ["tarifTerID"])
      .map((data) => data.map((terMap) => tarifTer.fromMap(terMap)).toList());

  // Fetch data sekali (bukan stream)
  Future<List<tarifTer>> fetchAllTER() async {
    final response = await database.select();
    return response.map<tarifTer>((map) => tarifTer.fromMap(map)).toList();
  }

  // Update data
  Future<void> updateTER(tarifTer updatedTer) async {
    await database
        .update(updatedTer.toMap())
        .eq('tarifTerID', updatedTer.tarifTerID!);
  }

  // Delete data
  Future<void> deleteTer(String tarifTerID) async {
    await database.delete().eq('tarifTerID', tarifTerID);
  }
}
