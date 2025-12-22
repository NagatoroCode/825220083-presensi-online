import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/database/checkout_database.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Laporan%20Harian/detailLaporanHarian_page.dart';
import 'package:aplikasiabsensi/service/laporanService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanHarianPage extends StatefulWidget {
  final String userID;

  const LaporanHarianPage({super.key, required this.userID});

  @override
  State<LaporanHarianPage> createState() => _LaporanHarianPageState();
}

class _LaporanHarianPageState extends State<LaporanHarianPage> {
  late LaporanService _laporanService;
  dataKaryawan? karyawan;
  List<Map<String, dynamic>> laporan = [];
  String selectedMonth = "";
  String selectedYear = "";
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _laporanService = LaporanService(
      karyawanDb: DatakaryawanDatabase(),
      checkinDb: CheckinDatabase(),
      checkoutDb: CheckoutDatabase(),
    );

    DateTime today = DateTime.now();
    selectedMonth = _laporanService.bulanMap.keys.firstWhere(
      (b) => _laporanService.bulanMap[b] == today.month,
    );
    selectedYear = today.year.toString();

    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      karyawan = await _laporanService.getKaryawan(widget.userID);
      if (karyawan == null) throw Exception("Data karyawan tidak ditemukan.");

      laporan = await _laporanService.getLaporanHarian(
        userId: widget.userID,
        month: selectedMonth,
        year: selectedYear,
      );

      DateTime today = DateTime.now();
      laporan = laporan.where((lap) {
        DateTime lapTanggal = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).parse(lap["tanggal"]);
        return !lapTanggal.isAfter(today);
      }).toList();

      final todayStr = DateFormat('dd MMMM yyyy', 'id_ID').format(today);
      final index = laporan.indexWhere((lap) => lap["tanggal"] == todayStr);
      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(index * 90.0);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleTap(Map<String, dynamic> lap) async {
    final userID = widget.userID;

    final lapTanggal = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).parse(lap["tanggal"]);
    final lapTanggalStr = DateFormat('yyyy-MM-dd').format(lapTanggal);

    final checkin = await CheckinDatabase().getCheckInByUserAndDate(
      userID,
      lapTanggalStr,
    );
    final checkout = await CheckoutDatabase().getCheckOutByUserAndDate(
      userID,
      lapTanggalStr,
    );

    if (checkin == null && checkout == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Laporan CICO"),
          content: const Text("Data CICO untuk tanggal ini belum tersedia."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DetailLaporanPribadiPage(checkin: checkin, checkout: checkout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Laporan Harian Pribadi')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 16),
                  _buildDropdowns(),
                  const SizedBox(height: 16),
                  _buildLaporanList(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage:
                (karyawan?.fotoProfil != null &&
                    karyawan!.fotoProfil!.isNotEmpty)
                ? NetworkImage(karyawan!.fotoProfil!)
                : const AssetImage('assets/images/avatar.png') as ImageProvider,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                karyawan?.namaLengkap ?? "-",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                karyawan?.jabatan?.namaJabatan ?? "-",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedMonth,
            items: _laporanService.bulanMap.keys
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (val) {
              setState(() => selectedMonth = val!);
              loadData();
            },
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedYear,
            items: [
              "2023",
              "2024",
              "2025",
            ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (val) {
              setState(() => selectedYear = val!);
              loadData();
            },
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLaporanList() {
    return Column(
      children: laporan.map((lap) {
        final statusColor = lap["color"] as Color;
        return GestureDetector(
          onTap: () => _handleTap(lap),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lap["tanggal"],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          lap["status"],
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
