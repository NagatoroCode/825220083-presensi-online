import 'package:aplikasiabsensi/model/checkout.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutDatabase {
  final database = Supabase.instance.client.from('AbsensiCheckOut');

  Future createNewCheckout(Checkout newCheckout) async {
    await database.insert(newCheckout.toMap());
  }

  Future<Checkout?> getCheckOutTodayByUser(String userID) async {
    final today = DateTime.now();
    final tanggalHariIni = DateFormat('yyyy-MM-dd').format(today);

    final response = await Supabase.instance.client
        .from('AbsensiCheckOut')
        .select('*, jenisStatus:statusID(namaStatus)')
        .eq('userID', userID)
        .eq('tanggalKeluar', tanggalHariIni)
        .maybeSingle();

    if (response == null) return null;

    return Checkout.fromMap(response);
  }

  Future<List<Checkout>> getCheckoutByMonth(
    String userId,
    int bulan,
    int tahun,
  ) async {
    final startDate = DateTime(tahun, bulan, 1);
    final endDate = DateTime(tahun, bulan + 1, 0);

    final response = await database
        .select('*, jenisStatus:statusID(*)')
        .eq('userID', userId)
        .gte('tanggalKeluar', DateFormat('yyyy-MM-dd').format(startDate))
        .lte('tanggalKeluar', DateFormat('yyyy-MM-dd').format(endDate));

    final data = response as List;
    return data.map((map) => Checkout.fromMap(map)).toList();
  }

  Future<Checkout?> getCheckOutByUserAndDate(
    String userId,
    String tanggalMasuk,
  ) async {
    final response = await database
        .select('*, jenisStatus:statusID(*)')
        .eq('userID', userId)
        .gte('tanggalKeluar', tanggalMasuk)
        .lte('tanggalKeluar', tanggalMasuk)
        .order('waktuKeluar', ascending: false)
        .limit(1);

    if (response.isEmpty) return null;

    return Checkout.fromMap(response.first);
  }

  Future<Checkout?> getLastCheckoutByUser(String userID) async {
    final response = await database
        .select('*, jenisStatus:statusID(*)')
        .eq('userID', userID)
        .order('tanggalKeluar', ascending: false)
        .order('waktuKeluar', ascending: false)
        .limit(1);

    if (response.isEmpty) return null;
    return Checkout.fromMap(response.first);
  }
}
