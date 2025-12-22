import 'dart:convert';
import 'package:aplikasiabsensi/service/notificationService.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:aplikasiabsensi/model/rangeLocation.dart';
import 'package:intl/intl.dart';

class RangeService {
  // 🔹 Supabase REST API config
  final String supabaseUrl = "https://lplysumkqegzahwjlnnl.supabase.co";
  final String supabaseKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwbHlzdW1rcWVnemFod2psbm5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzMzAwNTQsImV4cCI6MjA2NzkwNjA1NH0.sYXb9uuCTLuMJjJj3eSXvQTVw_-vR8PNlPAi9zkrs1k";

  Future<List<Map<String, dynamic>>> getActiveCheckins() async {
    final today = DateTime.now();
    final tanggalHariIni = DateFormat('yyyy-MM-dd').format(today);

    final url = Uri.parse(
      "$supabaseUrl/rest/v1/AbsensiCheckIn?tanggalMasuk=eq.$tanggalHariIni",
    );

    final headers = {
      "apikey": supabaseKey,
      "Authorization": "Bearer $supabaseKey",
      "Content-Type": "application/json",
    };

    try {
      final response = await http.get(url, headers: headers);

      print("[REST][GET] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("[REST][GET] Jumlah check-in hari ini: ${data.length}");
        return List<Map<String, dynamic>>.from(data);
      }

      print("[REST][GET ERROR] ${response.body}");
      return [];
    } catch (e) {
      print("❌ [REST GET Error] $e");
      return [];
    }
  }

  Future<void> trackAndSendLocation() async {
    final checkins = await getActiveCheckins();
    print("[DEBUG][RangeService] Jumlah check-in aktif: ${checkins.length}");

    for (var checkin in checkins) {
      final checkinID = checkin['checkinID'];
      final latAwal = (checkin['latitudeMasuk'] as num?)?.toDouble() ?? 0;
      final longAwal = (checkin['longitudeMasuk'] as num?)?.toDouble() ?? 0;

      print("[DEBUG] Tracking checkinID: $checkinID");

      // 🔹 Ambil lokasi sekarang
      Position pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        print("❌ Gagal mengambil lokasi: $e");
        continue;
      }

      final latNow = pos.latitude;
      final longNow = pos.longitude;

      final jarak = Geolocator.distanceBetween(
        latAwal,
        longAwal,
        latNow,
        longNow,
      );

      final jarakAsli = double.parse(jarak.toStringAsFixed(2));

      print("[DEBUG] Jarak: $jarakAsli m");

      if (jarakAsli > 500) {
        await NotificationService.showNotification(
          title: "Peringatan Lokasi",
          body:
              "Anda terdeteksi keluar dari radius lokasi kerja (${jarakAsli} meter)",
        );

        final alamat = await _getAddressFromCoordinates(latNow, longNow);

        final newRange = rangeLocation(
          checkinID: checkinID,
          latitude_realtime: latNow,
          longitude_realtime: longNow,
          alamat_realtime: alamat,
          jarak_radius: jarakAsli,
        );

        await _postToSupabase(newRange);
      }

      final alamat = await _getAddressFromCoordinates(latNow, longNow);
      print("[DEBUG] Alamat realtime: $alamat");

      final newRange = rangeLocation(
        checkinID: checkinID,
        latitude_realtime: latNow,
        longitude_realtime: longNow,
        alamat_realtime: alamat,
        jarak_radius: jarakAsli,
      );

      final sent = await _postToSupabase(newRange);

      if (sent) {
        print("✅ Data rangeLocation dikirim ke Supabase");
      } else {
        print("❌ Gagal mengirim data ke Supabase");
      }
    }
  }

  Future<bool> _postToSupabase(rangeLocation range) async {
    final url = Uri.parse("$supabaseUrl/rest/v1/rangeLocation");

    final headers = {
      "apikey": supabaseKey,
      "Authorization": "Bearer $supabaseKey",
      "Content-Type": "application/json",
      "Prefer": "return=minimal",
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(range.toMap()),
      );

      print("[REST][POST] Status: ${response.statusCode}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }

      print("[REST][POST ERROR] ${response.body}");
      return false;
    } catch (e) {
      print("❌ [POST ERROR] $e");
      return false;
    }
  }

  Future<String> _getAddressFromCoordinates(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return "${p.street}, ${p.locality}, ${p.postalCode}, ${p.country}";
      }
      return "Alamat tidak ditemukan";
    } catch (e) {
      return "Gagal mendapatkan alamat";
    }
  }
}
