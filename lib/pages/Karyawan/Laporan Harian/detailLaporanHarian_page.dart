import 'package:aplikasiabsensi/model/checkin.dart';
import 'package:aplikasiabsensi/model/checkout.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/model/rangeLocation.dart';
import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/database/checkout_database.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/rangeLocation_database.dart';
import 'package:aplikasiabsensi/database/pengajuanIzin_database.dart';
import 'package:aplikasiabsensi/model/pengajuanIzin.dart';
import 'package:aplikasiabsensi/service/photoService.dart';
import 'package:aplikasiabsensi/service/statusService.dart';
import 'package:aplikasiabsensi/widgets/customButton.dart';
import 'package:aplikasiabsensi/widgets/fotoProfile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailLaporanPribadiPage extends StatefulWidget {
  final Checkin? checkin;
  final Checkout? checkout;

  const DetailLaporanPribadiPage({super.key, this.checkin, this.checkout});

  @override
  State<DetailLaporanPribadiPage> createState() =>
      _DetailLaporanPribadiPageState();
}

class _DetailLaporanPribadiPageState extends State<DetailLaporanPribadiPage> {
  final fotoProfileController _fotoCtrl = fotoProfileController();
  final izinDB = pengajuanIzinDatabase();

  String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "-";
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final jam = parts[0].padLeft(2, '0');
        final menit = parts[1].padLeft(2, '0');
        return "$jam.$menit AM";
      }
      return timeStr;
    } catch (_) {
      return "-";
    }
  }

  String totalJamKerja(Checkin? checkin, Checkout? checkout) {
    if (checkin == null ||
        checkin.waktuMasuk.isEmpty ||
        checkout == null ||
        checkout.waktuKeluar.isEmpty) {
      return "-";
    }

    try {
      final masukParts = checkin.waktuMasuk.split(':');
      DateTime masuk = DateTime(
        2024,
        1,
        1,
        int.parse(masukParts[0]),
        int.parse(masukParts[1]),
        masukParts.length > 2 ? int.parse(masukParts[2]) : 0,
      );

      final keluarParts = checkout.waktuKeluar.split(':');
      DateTime keluar = DateTime(
        2024,
        1,
        1,
        int.parse(keluarParts[0]),
        int.parse(keluarParts[1]),
        keluarParts.length > 2 ? int.parse(keluarParts[2]) : 0,
      );

      if (keluar.isBefore(masuk)) {
        keluar = keluar.add(const Duration(hours: 24));
      }

      final breakStart = DateTime(2024, 1, 1, 12, 0, 0);
      final breakEnd = DateTime(2024, 1, 1, 13, 0, 0);

      Duration totalDuration = keluar.difference(masuk);

      if (masuk.isBefore(breakStart) && keluar.isAfter(breakEnd)) {
        totalDuration -= const Duration(hours: 1);
      } else if (keluar.isAfter(breakStart) && keluar.isBefore(breakEnd)) {
        totalDuration -= keluar.difference(breakStart);
      }

      if (totalDuration.inMinutes < 0) {
        return "0 Jam 0 Menit";
      }

      final jam = totalDuration.inHours;
      final menit = totalDuration.inMinutes % 60;

      return "$jam Jam $menit Menit";
    } catch (_) {
      return "-";
    }
  }

  String totalJamLembur(List<PengajuanIzin> izinList) {
    int totalMenit = 0;

    for (var izin in izinList) {
      if ((izin.statusPengajuan.toLowerCase() == 'pengajuan disetujui') &&
          (izin.status?.namaStatus.toLowerCase() == 'lembur')) {
        try {
          final mulai = izin.waktuMulai?.split(':') ?? ['0', '0'];
          final selesai = izin.waktuSelesai?.split(':') ?? ['0', '0'];

          int jamMulai = int.parse(mulai[0]);
          int menitMulai = int.parse(mulai[1]);

          int jamSelesai = int.parse(selesai[0]);
          int menitSelesai = int.parse(selesai[1]);

          int menitTotal =
              (jamSelesai * 60 + menitSelesai) - (jamMulai * 60 + menitMulai);
          if (menitTotal < 0) menitTotal += 24 * 60;

          totalMenit += menitTotal;
        } catch (_) {
          continue;
        }
      }
    }

    final jam = totalMenit ~/ 60;
    final menit = totalMenit % 60;

    return "$jam Jam $menit Menit";
  }

  Future<Map<String, dynamic>> _loadData(
    String userID,
    String? checkinID,
  ) async {
    Checkin? checkinData;
    Checkout? checkout;

    if (checkinID != null && checkinID.isNotEmpty) {
      checkinData = await CheckinDatabase().getCheckinById(checkinID);
    }

    if (checkinData != null) {
      checkout = await CheckoutDatabase().getCheckOutByUserAndDate(
        userID,
        checkinData.tanggalMasuk,
      );
    } else {
      checkout = await CheckoutDatabase().getLastCheckoutByUser(userID);
    }

    final karyawan = await DatakaryawanDatabase().getKaryawanByUserId(userID);

    final rangeList = checkinData != null
        ? await RangelocationDatabase().getRangeByCheckinID(checkinID!)
        : <rangeLocation>[];

    rangeLocation? latestRange;
    final validRanges = rangeList
        .where((r) => r.tanggalDibuat != null)
        .toList();
    if (validRanges.isNotEmpty) {
      validRanges.sort((a, b) => b.tanggalDibuat!.compareTo(a.tanggalDibuat!));
      latestRange = validRanges.first;
    }

    return {
      "checkin": checkinData,
      "checkout": checkout,
      "karyawan": karyawan,
      "latestRange": latestRange,
    };
  }

  @override
  Widget build(BuildContext context) {
    final userID = widget.checkin?.userID ?? widget.checkout?.userID ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Detail Laporan Karyawan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(userID, widget.checkin?.checkinID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final checkinData = snapshot.data!["checkin"] as Checkin?;
          final checkout = snapshot.data!["checkout"] as Checkout?;
          final karyawan = snapshot.data!["karyawan"] as dataKaryawan?;
          final latestRange = snapshot.data!["latestRange"] as rangeLocation?;

          if (karyawan?.fotoProfil != null &&
              karyawan!.fotoProfil!.isNotEmpty) {
            _fotoCtrl.setImage(karyawan.fotoProfil!);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==== Profil ====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _boxDecoration(),
                  child: Row(
                    children: [
                      Fotoprofile(
                        size: 60,
                        controller: _fotoCtrl,
                        placeholder: 'assets/images/fotoOrang.png',
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              karyawan?.namaLengkap ?? "-",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              karyawan?.jabatan?.namaJabatan ?? "-",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ==== Check In ====
                _buildCheckWidget(
                  "Check In",
                  checkinData?.waktuMasuk,
                  checkinData?.status?.namaStatus,
                  checkinData?.lokasiMasuk,
                  checkinData?.fotoMasuk,
                  checkinData?.deskripsi,
                ),
                const SizedBox(height: 16),

                // ==== Check Out ====
                _buildCheckWidget(
                  "Check Out",
                  checkout?.waktuKeluar,
                  checkout?.status?.namaStatus,
                  checkout?.lokasiKeluar,
                  checkout?.fotoKeluar,
                  checkout?.deskripsi,
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Informasi Jam Kerja",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _labelText("Total Jam Kerja"),
                              const SizedBox(height: 4),
                              Text(
                                totalJamKerja(checkinData, checkout),
                                style: _valueStyle(),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _labelText("Total Jam Lembur"),
                              const SizedBox(height: 4),
                              FutureBuilder<List<PengajuanIzin>>(
                                future: izinDB.getStatusWithIzinByUser(userID),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return Text("-", style: _valueStyle());
                                  final izinList = snapshot.data!;
                                  return Text(
                                    totalJamLembur(izinList),
                                    style: _valueStyle(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ==== Informasi Tambahan ====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: _boxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Informasi Tambahan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        latestRange != null
                            ? "Pada pukul ${latestRange.tanggalDibuat != null ? DateFormat('HH.mm').format(latestRange.tanggalDibuat!) : '-'}, "
                                  "Anda terdeteksi berada di luar radius. "
                                  "Lokasi Anda berada di ${latestRange.alamat_realtime} "
                                  "dengan jarak ${latestRange.jarak_radius.toStringAsFixed(2)} meter dari titik check-in."
                            : "-",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==== Informasi Izin ====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: _boxDecoration(),
                  child: FutureBuilder<List<PengajuanIzin>>(
                    future: izinDB.getStatusWithIzinByUser(userID),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final izinList = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Informasi Izin",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (izinList.isEmpty)
                            const Text(
                              "Tidak ada izin kerja.",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else
                            Column(
                              children: izinList.map((izin) {
                                final tanggal = izin.tanggalIzin;
                                final waktuMulai = izin.waktuMulai ?? '-';
                                final waktuSelesai = izin.waktuSelesai ?? '-';
                                final status = izin.statusPengajuan;
                                Color statusColor;
                                switch (status.toLowerCase()) {
                                  case 'pengajuan disetujui':
                                    statusColor = const Color(0xFF10B981);
                                    break;
                                  case 'menunggu approval':
                                    statusColor = const Color(0xFFF59E0B);
                                    break;
                                  case 'ditolak':
                                    statusColor = const Color(0xFFEF4444);
                                    break;
                                  default:
                                    statusColor = Colors.grey;
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _izinItem(
                                    title: izin.status?.namaStatus ?? '-',
                                    time: "$waktuMulai - $waktuSelesai",
                                    status: status,
                                    statusColor: statusColor,
                                    date: tanggal,
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
                CustomButton(
                  text: "OK",
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  // -------------------- Helper Widgets --------------------
  Widget _buildCheckWidget(
    String label,
    String? waktu,
    String? status,
    String? lokasi,
    String? foto,
    String? deskripsi,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informasi $label",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _infoText("Waktu", formatTime(waktu))),
              Expanded(
                child: _infoText(
                  "Status",
                  status ?? "-",
                  color: StatusColorService.getStatusColor(status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _labelText("Lokasi"),
          Text(lokasi ?? "-", style: _valueStyle()),
          const SizedBox(height: 16),
          _labelText("Foto $label"),
          const SizedBox(height: 8),
          PhotoService.buildPhotoBox(context, foto),
          const SizedBox(height: 16),
          _labelText("Keterangan Tambahan"),
          Text(deskripsi ?? "-", style: _valueStyle()),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _labelText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
    );
  }

  Widget _infoText(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  TextStyle _valueStyle() =>
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  Widget _izinItem({
    required String title,
    required String time,
    required String status,
    required Color statusColor,
    required String date,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labelText(title),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labelText(""),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
