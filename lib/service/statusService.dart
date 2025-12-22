import 'package:flutter/material.dart';

class StatusColorService {
  static Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    final s = status.toLowerCase().trim();

    // ======== STATUS HIJAU ========
    if (s == "check in" || s == "check out") {
      return const Color(0xFF10B981); // Hijau
    }

    // ======== STATUS KUNING ========
    if (s == "hadir terlambat" ||
        s == "pulang terlambat" ||
        s == "pulang cepat") {
      return const Color(0xFFF59E0B); // Kuning
    }

    // DEFAULT
    return Colors.grey;
  }
}
