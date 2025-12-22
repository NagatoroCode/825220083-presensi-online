import 'package:flutter/material.dart';

class Statuscicocard extends StatelessWidget {
  final String checkInTime;
  final String checkOutTime;
  final bool isCheckedIn;
  final bool isCheckedOut;
  final String checkInStatus;
  final String checkOutStatus;

  const Statuscicocard({
    super.key,
    required this.checkInTime,
    required this.checkOutTime,
    this.isCheckedIn = false,
    this.isCheckedOut = false,
    this.checkInStatus = "Belum Absen",
    this.checkOutStatus = "Belum Absen",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.login, color: Colors.green, size: 28),
                const SizedBox(height: 8),
                const Text(
                  "Check In",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  checkInTime,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  checkInStatus,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCheckedIn ? Colors.green[700] : Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 80,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.logout, color: Colors.red, size: 28),
                const SizedBox(height: 8),
                const Text(
                  "Check Out",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  checkOutTime,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  checkOutStatus,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCheckedOut
                        ? Colors.green[700]
                        : Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
