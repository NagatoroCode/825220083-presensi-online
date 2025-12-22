import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/database/checkout_database.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/model/checkin.dart';
import 'package:aplikasiabsensi/model/checkout.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanServiceOwner {
  final DatakaryawanDatabase _karyawanDb;
  final CheckinDatabase _checkinDb;
  final CheckoutDatabase _checkoutDb;

  LaporanServiceOwner({
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

  /// 🧩 NORMALISASI TANGGAL (harus sama dengan aturan laporan user)
  String normalizeDate(String dbDate) {
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(dbDate).toLocal());
    } catch (_) {
      return "";
    }
  }

  /// 🧩 Ambil semua karyawan
  Future<List<dataKaryawan>> getAllKaryawan() async {
    return await _karyawanDb.getKaryawanWithJabatan();
  }

  /// 🧩 HITUNG Total Jam Kerja
  Duration hitungTotalJam(Checkin checkin, Checkout checkout) {
    if (checkin.tanggalMasuk.isEmpty ||
        checkout.tanggalKeluar.isEmpty ||
        checkin.waktuMasuk.isEmpty ||
        checkout.waktuKeluar.isEmpty) {
      return Duration.zero;
    }

    try {
      final masuk = DateTime.parse(
        "${checkin.tanggalMasuk} ${checkin.waktuMasuk}",
      );
      final keluar = DateTime.parse(
        "${checkout.tanggalKeluar} ${checkout.waktuKeluar}",
      );

      if (keluar.isBefore(masuk)) return Duration.zero;

      return keluar.difference(masuk);
    } catch (_) {
      return Duration.zero;
    }
  }

  /// 🧩 Tentukan status harian (mengikuti aturan LaporanService)
  Map<String, dynamic> getStatusHarian(
    Checkin checkin,
    Checkout checkout,
    DateTime tanggal,
  ) {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    const hadirHijau = ["Hadir"];
    const warnaKuning = ["Hadir Terlambat", "Pulang Cepat", "Pulang Terlambat"];

    String? checkinStatus = checkin.status?.namaStatus;
    String? checkoutStatus = checkout.status?.namaStatus;

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

    return {"status": status, "color": color};
  }

  /// 🧩 Laporan per karyawan — mengikuti struktur LaporanService
  Future<Map<String, dynamic>> getLaporanKaryawan(
    dataKaryawan karyawan,
    int bulan,
    int tahun,
  ) async {
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
    final List<Map<String, dynamic>> temp = [];

    for (int i = 1; i <= totalHari; i++) {
      final tanggal = DateTime(tahun, bulan, i);
      final tanggalStr = DateFormat('yyyy-MM-dd').format(tanggal);

      final checkin = checkins.firstWhere(
        (c) => normalizeDate(c.tanggalMasuk) == tanggalStr,
        orElse: () => Checkin.empty(),
      );

      final checkout = checkouts.firstWhere(
        (c) => normalizeDate(c.tanggalKeluar) == tanggalStr,
        orElse: () => Checkout.empty(),
      );

      final statusData = getStatusHarian(checkin, checkout, tanggal);

      final durasi = hitungTotalJam(checkin, checkout);
      final totalJamKerja =
          durasi.inHours.toString().padLeft(2, '0') +
          ":" +
          (durasi.inMinutes % 60).toString().padLeft(2, '0');

      temp.add({
        "tanggal": DateFormat('dd MMMM yyyy', 'id').format(tanggal),
        "status": statusData["status"],
        "color": statusData["color"],
        "totalJamKerja": totalJamKerja,
        "checkin": checkin.tanggalMasuk.isNotEmpty ? checkin : null,
        "checkout": checkout.tanggalKeluar.isNotEmpty ? checkout : null,
      });
    }

    return {"karyawan": karyawan, "laporan": temp};
  }

  /// 🧩 Laporan seluruh karyawan
  Future<List<Map<String, dynamic>>> getLaporanSemuaKaryawan({
    required String month,
    required String year,
  }) async {
    final bulan = bulanMap[month]!;
    final tahun = int.parse(year);

    final karyawans = await getAllKaryawan();
    final List<Map<String, dynamic>> hasil = [];

    for (var k in karyawans) {
      final ls = await getLaporanKaryawan(k, bulan, tahun);
      hasil.add(ls);
    }

    return hasil;
  }
}
