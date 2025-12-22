import 'dart:async';
import 'package:aplikasiabsensi/database/checkout_database.dart';
import 'package:aplikasiabsensi/model/checkout.dart';
import 'package:aplikasiabsensi/pages/Karyawan/CICO/detailCICO_page.dart';
import 'package:aplikasiabsensi/service/getLocation.dart';
import 'package:aplikasiabsensi/service/greetingStatus.dart';
import 'package:aplikasiabsensi/widgets/statusCICOCard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:aplikasiabsensi/auth/auth_service.dart';
import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/model/checkin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';

final authService = AuthService();

class UserhomePage extends StatefulWidget {
  const UserhomePage({super.key});

  @override
  State<UserhomePage> createState() => _UserhomePageState();
}

class _UserhomePageState extends State<UserhomePage> {
  final GlobalKey<SlideActionState> _sliderKey = GlobalKey();
  late Timer _timer;
  String _currentTime = '';
  String _currentDate = '';
  Checkin? _checkin;
  Checkout? _checkout;
  String? _namaLengkap;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
    _loadCICOToday();
    _loadNamaKaryawan();
  }

  void _updateTime() {
    setState(() {
      _currentTime = waktuService.getCurrentTime();
      _currentDate = waktuService.getCurrentDate();
    });
  }

  Future<void> _loadCICOToday() async {
    final userID = Supabase.instance.client.auth.currentUser?.id;
    if (userID == null) return;

    final dataCheckin = await CheckinDatabase().getCheckInTodayByUser(userID);
    final dataCheckout = await CheckoutDatabase().getCheckOutTodayByUser(
      userID,
    );

    setState(() {
      _checkin = dataCheckin;
      _checkout = dataCheckout;
    });
  }

  Future<void> _loadNamaKaryawan() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final data = await DatakaryawanDatabase().getKaryawanByUserId(user.id);
    setState(() {
      _namaLengkap = data?.namaLengkap ?? "Karyawan";
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // 🔹 Fungsi Check In
  Future<void> handleCheckIn() async {
    final lokasi = await getCurrentAddress();
    final jamRealTime = DateTime.now();
    final cicoTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(jamRealTime);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailCICOPage(address: lokasi, jamCico: cicoTime),
      ),
    ).then((_) {
      _loadCICOToday(); // reload data setelah kembali
    });

    Future.delayed(const Duration(seconds: 1), () {
      _sliderKey.currentState?.reset();
    });
  }

  // 🔹 Fungsi Check Out
  Future<void> handleCheckOut() async {
    final lokasi = await getCurrentAddress();
    final jamRealTime = DateTime.now();
    final cicoTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(jamRealTime);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailCICOPage(
          address: lokasi,
          jamCico: cicoTime,
          isCheckout: true,
        ),
      ),
    ).then((_) {
      _loadCICOToday(); // reload data setelah kembali
    });

    Future.delayed(const Duration(seconds: 1), () {
      _sliderKey.currentState?.reset();
    });
  }

  // 🔹 Tentukan aksi slider berdasarkan kondisi waktu & status
  Future<void> handleSliderAction() async {
    final now = DateTime.now();
    final isAfter17 = now.hour >= 17;

    if (_checkout != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kamu sudah Check Out hari ini."),
          backgroundColor: Colors.orange,
        ),
      );
      _sliderKey.currentState?.reset();
      return;
    }

    // Belum check in dan belum jam 17.00
    if (_checkin == null && !isAfter17) {
      await handleCheckIn();
      return;
    }

    // Belum check in tapi sudah lewat jam 17.00
    if (_checkin == null && isAfter17) {
      await handleCheckOut();
      return;
    }

    // Sudah check in tapi belum check out
    if (_checkin != null && _checkout == null) {
      await handleCheckOut();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkInTime = _checkin?.waktuMasuk ?? "--:--";
    final checkOutTime = _checkout?.waktuKeluar ?? "--:--";
    final now = DateTime.now();
    final isAfter17 = now.hour >= 17;

    // 🔹 Tentukan teks di tombol slide
    String sliderText;
    if (_checkout != null) {
      sliderText = "Sudah Check Out Hari Ini";
    } else if (_checkin == null && isAfter17) {
      sliderText = "Geser untuk Check Out";
    } else if (_checkin == null) {
      sliderText = "Geser untuk Check In";
    } else {
      sliderText = "Geser untuk Check Out";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Halaman Presensi Karyawan")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  waktuService.greetingStatus(),
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  _namaLengkap ?? "Memuat...",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Today's Status",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Statuscicocard(
                  checkInTime: checkInTime,
                  checkOutTime: checkOutTime,
                  isCheckedIn: _checkin?.waktuMasuk != null,
                  isCheckedOut: _checkout?.waktuKeluar != null,
                  checkInStatus:
                      _checkin?.status?.namaStatus ?? "Belum Check In",
                  checkOutStatus:
                      _checkout?.status?.namaStatus ?? "Belum Check Out",
                ),
                const SizedBox(height: 24),
                Text(
                  _currentDate,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentTime,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                SlideAction(
                  key: _sliderKey,
                  text: sliderText,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  outerColor: _checkout == null
                      ? const Color(0xFF1976D2)
                      : Colors.grey,
                  innerColor: Colors.white,
                  elevation: 4,
                  sliderRotate: false,
                  onSubmit: _checkout == null ? handleSliderAction : null,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
