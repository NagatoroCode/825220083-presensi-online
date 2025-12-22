import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/model/checkin.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'taskHandler.dart';

class CheckinService {
  final CheckinDatabase checkinDB = CheckinDatabase();

  /// 🔹 Fungsi check-in
  Future<String> handleCheckIn({
    required String lokasiMasuk,
    required String fotoMasuk,
    required String deskripsi,
    required double latitudeMasuk,
    required double longitudeMasuk,
  }) async {
    print("🔹 Memulai proses check-in...");

    // Ambil user saat ini
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return "Gagal: User belum login.";

    final userId = user.id;
    final now = DateTime.now();
    final jam = now.hour;

    String statusName = (jam < 8)
        ? "Belum Buka"
        : (jam <= 9)
        ? "Check In"
        : "Hadir Terlambat";

    if (statusName == "Belum Buka") {
      return "Waktu check-in belum dibuka. Silahkan melakukan check-in setelah pukul 08.00";
    }

    final statusId = await checkinDB.getStatusIdByName(statusName);
    if (statusId == null)
      return "Gagal: Status '$statusName' belum ada di database.";

    final waktu = DateFormat('HH:mm:ss').format(now);
    final tanggal = DateFormat('yyyy-MM-dd').format(now);

    // Buat objek checkin
    final newCheckin = Checkin(
      checkinID: null,
      userID: userId,
      statusID: statusId,
      tanggalMasuk: tanggal,
      waktuMasuk: waktu,
      lokasiMasuk: lokasiMasuk,
      fotoMasuk: fotoMasuk,
      deskripsi: deskripsi,
      longitudeMasuk: longitudeMasuk,
      latitudeMasuk: latitudeMasuk,
    );

    final checkinID = await checkinDB.createNewCheckIn(newCheckin);
    if (checkinID == null) return "Gagal menyimpan data check-in.";

    print("✅ Check-in berhasil disimpan dengan ID: $checkinID");

    // Start foreground service
    await FlutterForegroundTask.startService(
      notificationTitle: 'Tracking Location',
      notificationText: 'Monitoring lokasi aktif',
      callback: startCallback,
    );
    print("✅ Foreground service dimulai setelah check-in");

    return "✅ Check-in berhasil ($statusName)";
  }
}
