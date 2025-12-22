import 'dart:ui';
import 'package:aplikasiabsensi/auth/auth_gate.dart';
import 'package:aplikasiabsensi/service/notificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi Supabase
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwbHlzdW1rcWVnemFod2psbm5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzMzAwNTQsImV4cCI6MjA2NzkwNjA1NH0.sYXb9uuCTLuMJjJj3eSXvQTVw_-vR8PNlPAi9zkrs1k",
    url: "https://lplysumkqegzahwjlnnl.supabase.co",
  );

  await initializeDateFormatting('id_ID', null);

  await NotificationService.init();

  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'location_channel',
      channelName: 'Location Tracking',
      channelDescription: 'Tracking lokasi secara realtime',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      enableVibration: false,
      playSound: false,
      showWhen: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 900000,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1976D2);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Absensi',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.robotoTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryBlue,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
