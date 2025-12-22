import 'package:intl/intl.dart';

class waktuService {
  static String getCurrentTime() {
    final now = DateTime.now();
    return DateFormat.Hms().format(now);
  }

  static String getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('dd MMM yyyy').format(now);
  }

  static String greetingStatus() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Selamat Pagi,";
    if (hour < 17) return "Selamat Siang,";
    if (hour < 20) return "Selamat Sore,";
    return "Selamat Malam,";
  }
}
