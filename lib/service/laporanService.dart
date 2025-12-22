import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/database/checkout_database.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/model/checkin.dart';
import 'package:aplikasiabsensi/model/checkout.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanService {
  final DatakaryawanDatabase _karyawanDb;
  final CheckinDatabase _checkinDb;
  final CheckoutDatabase _checkoutDb;

  LaporanService({
    required DatakaryawanDatabase karyawanDb,
    required CheckinDatabase checkinDb,
    required CheckoutDatabase checkoutDb,
  }) : _karyawanDb = karyawanDb,
       _checkinDb = checkinDb,
       _checkoutDb = checkoutDb;

  final bulanMap = {
    "Januari": 1,
    "Februari": 2,
    "Maret": 3,
    "April": 4,
    "Mei": 5,
    "Juni": 6,
    "Juli": 7,
    "Agustus": 8,
    "September": 9,
    "Oktober": 10,
    "November": 11,
    "Desember": 12,
  };

  Future<dataKaryawan?> getKaryawan(String userId) async {
    return await _karyawanDb.getKaryawanByUserId(userId);
  }

  Future<List<Map<String, dynamic>>> getLaporanHarian({
    required String userId,
    required String month,
    required String year,
  }) async {
    final karyawan = await _karyawanDb.getKaryawanByUserId(userId);
    if (karyawan == null) return [];

    final bulan = bulanMap[month]!;
    final tahun = int.parse(year);

    final checkins = await _checkinDb.getCheckinByMonth(
      karyawan.userID,
      bulan,
      tahun,
    );

    final checkouts = await _checkoutDb.getCheckoutByMonth(
      karyawan.userID,
      bulan,
      tahun,
    );

    final totalHari = DateUtils.getDaysInMonth(tahun, bulan);
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    final List<Map<String, dynamic>> tempLaporan = [];

    for (int i = 1; i <= totalHari; i++) {
      final tanggal = DateTime(tahun, bulan, i);
      final tanggalStr = DateFormat('yyyy-MM-dd').format(tanggal);

      final checkin = checkins.firstWhere(
        (c) => c.tanggalMasuk == tanggalStr,
        orElse: () => Checkin.empty(),
      );

      final checkout = checkouts.firstWhere(
        (c) => c.tanggalKeluar == tanggalStr,
        orElse: () => Checkout.empty(),
      );

      final checkinStatus = checkin.status?.namaStatus;
      final checkoutStatus = checkout.status?.namaStatus;

      const hadirHijau = ["Hadir"];

      const warnaKuning = [
        "Hadir Terlambat",
        "Pulang Cepat",
        "Pulang Terlambat",
      ];

      String status;
      Color color;

      if (tanggal.isAfter(todayDateOnly)) {
        status = "Data CICO tidak tersedia";
        color = Colors.grey;
      } else if (checkin.tanggalMasuk.isNotEmpty &&
          checkout.tanggalKeluar.isNotEmpty) {
        status = "Hadir";
        color = Colors.green;
      } else if (checkin.tanggalMasuk.isNotEmpty &&
          checkout.tanggalKeluar.isEmpty &&
          tanggal.isBefore(todayDateOnly)) {
        status = "Suspended";
        color = Colors.orange;
      } else if (checkout.tanggalKeluar.isNotEmpty &&
          checkin.tanggalMasuk.isEmpty) {
        status = "Suspended";
        color = Colors.orange;
      } else if (warnaKuning.contains(checkinStatus) ||
          warnaKuning.contains(checkoutStatus)) {
        status = checkinStatus ?? checkoutStatus!;
        color = Colors.orange;
      } else if (hadirHijau.contains(checkinStatus) ||
          hadirHijau.contains(checkoutStatus)) {
        status = "Hadir";
        color = Colors.green;
      } else {
        status = "Tidak Hadir";
        color = Colors.red;
      }

      tempLaporan.add({
        "tanggal": DateFormat('dd MMMM yyyy', 'id').format(tanggal),
        "status": status,
        "color": color,
        "checkin": checkinStatus != null ? checkin : null,
        "checkout": checkoutStatus != null ? checkout : null,
      });
    }

    return tempLaporan.reversed.toList();
  }
}
