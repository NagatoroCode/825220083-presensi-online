import 'package:aplikasiabsensi/model/rangeLocation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RangelocationDatabase {
  final database = Supabase.instance.client.from('rangeLocation');

  Future<String?> createNewRange(rangeLocation newRange) async {
    final response = await Supabase.instance.client
        .from('rangeLocation')
        .insert(newRange.toMap())
        .select('rangeID')
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return response['rangeID']?.toString();
  }

  Future<List<rangeLocation>> getRangeByCheckinID(String checkinID) async {
    try {
      final response = await database
          .select()
          .eq('checkinID', checkinID)
          .order('tanggalDibuat', ascending: false);

      if (response == null || response.isEmpty) return [];

      return response.map<rangeLocation>((e) {
        return rangeLocation.fromMap(e);
      }).toList();
    } catch (e) {
      print("Range error: $e");
      return [];
    }
  }
}
