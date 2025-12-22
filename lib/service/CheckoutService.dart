import 'package:aplikasiabsensi/database/checkout_database.dart';
import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/database/jenisStatus_database.dart';
import 'package:aplikasiabsensi/model/checkout.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutService {
  final CheckoutDatabase checkoutDB = CheckoutDatabase();
  final CheckinDatabase checkinDB = CheckinDatabase();
  final JenisstatusDatabase statusDB = JenisstatusDatabase();

  /// 🔹 Fungsi untuk melakukan check-out
  Future<String> handleCheckOut({
    required String lokasiKeluar,
    required String fotoKeluar,
    required String deskripsi,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return "Gagal: User tidak login.";

    final userId = user.id;
    final now = DateTime.now();
    final tanggal = DateFormat('yyyy-MM-dd').format(now);
    final waktuSekarang = DateFormat('HH:mm:ss').format(now);

    // 🔹 Tentukan status berdasarkan jam check-out
    final batasPulangCepat = DateTime.parse("$tanggal 17:00:00");
    final batasPulangNormal = DateTime.parse("$tanggal 17:30:00");
    final waktuKeluar = DateTime.parse("$tanggal $waktuSekarang");

    String statusName;
    if (waktuKeluar.isBefore(batasPulangCepat)) {
      statusName = "Pulang Cepat";
    } else if (waktuKeluar.isBefore(batasPulangNormal)) {
      statusName = "Check Out";
    } else {
      statusName = "Pulang Terlambat";
    }

    final statusId = await statusDB.getStatusIdByName(statusName);
    if (statusId == null) return "Gagal: Status '$statusName' belum ada";

    // 🔹 Simpan data checkout ke database
    final newCheckout = Checkout(
      checkoutID: null,
      userID: userId,
      statusID: statusId,
      tanggalKeluar: tanggal,
      waktuKeluar: waktuSekarang,
      lokasiKeluar: lokasiKeluar,
      fotoKeluar: fotoKeluar,
      deskripsi: deskripsi,
    );

    final checkoutID = await checkoutDB.createNewCheckout(newCheckout);
    print("✅ Check-out berhasil disimpan dengan ID: $checkoutID");

    // 🔹 STOP foreground service setelah check-out
    await FlutterForegroundTask.stopService();
    print("✅ Foreground service dihentikan setelah check-out");

    return "✅ Check-out berhasil ($statusName)";
  }
}
