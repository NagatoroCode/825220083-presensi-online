import 'package:flutter/material.dart';

class statusPengajuan {
  final String namaStatus;
  final String? tanggalStatus;
  final Color warna;

  statusPengajuan({
    required this.namaStatus,
    this.tanggalStatus,
    required this.warna,
  });
}

class StatusPengajuanWidget extends StatefulWidget {
  final List<statusPengajuan> statuses;

  const StatusPengajuanWidget({super.key, required this.statuses});

  @override
  State<StatusPengajuanWidget> createState() => _StatusPengajuanWidgetState();
}

class _StatusPengajuanWidgetState extends State<StatusPengajuanWidget>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final latestStatus = widget.statuses.last;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status Pengajuan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => isExpanded = !isExpanded),
                  child: Row(
                    children: [
                      Text(
                        isExpanded ? "Tutup" : "Lihat",
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 Daftar status
            AnimatedCrossFade(
              firstChild: _buildStatusItem(latestStatus, false),
              secondChild: Column(
                children: widget.statuses.map((status) {
                  final isLast = widget.statuses.last == status;
                  return _buildStatusItem(status, !isLast);
                }).toList(),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(statusPengajuan status, bool showLine) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔸 Titik indikator + garis timeline
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      status.warna.withOpacity(0.9),
                      status.warna.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: status.warna.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (showLine)
                Container(width: 2, height: 40, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 14),

          // 🔸 Detail teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.namaStatus,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                if (status.tanggalStatus != null)
                  Text(
                    status.tanggalStatus!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.5,
                      fontFamily: 'Poppins',
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
