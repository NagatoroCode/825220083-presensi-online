import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:aplikasiabsensi/service/rangeService.dart';

@pragma('vm:entry-point')
class LocationTaskHandler extends TaskHandler {
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) {
    print("✅ Foreground task dimulai: $timestamp");
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    print("📡 Foreground: Mulai tracking lokasi di $timestamp");

    try {
      await RangeService().trackAndSendLocation();

      print("✅ Foreground: Tracking & upload selesai");
    } catch (e) {
      print("❌ Error saat tracking: $e");
    }
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    print("🛑 Foreground task dihentikan: $timestamp");
  }

  @override
  void onNotificationPressed() {}

  @override
  void onNotificationButtonPressed(String id) {}
}

/// 🔹 Fungsi untuk set handler Foreground Task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}
