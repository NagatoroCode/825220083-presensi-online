import 'package:aplikasiabsensi/database/checkin_database.dart';
import 'package:aplikasiabsensi/database/checkout_database.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/model/checkin.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/pages/Owner/Laporan%20Harian/detailLaporanOwner_page.dart';
import 'package:aplikasiabsensi/service/laporanOwner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanHarianOwnerPage extends StatefulWidget {
  const LaporanHarianOwnerPage({super.key});

  @override
  State<LaporanHarianOwnerPage> createState() => _LaporanHarianOwnerPageState();
}

class _LaporanHarianOwnerPageState extends State<LaporanHarianOwnerPage> {
  late LaporanServiceOwner _laporanService;
  bool _localeInitialized = false;
  List<Map<String, dynamic>> laporanSemua = [];
  List<dataKaryawan> allKaryawan = [];

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int selectedDayIndex = 0;

  final List<String> bulanList = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];

  List<int> yearList = [];
  late ScrollController _scrollController;
  late List<DateTime> daysInMonth;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _laporanService = LaporanServiceOwner(
      karyawanDb: DatakaryawanDatabase(),
      checkinDb: CheckinDatabase(),
      checkoutDb: CheckoutDatabase(),
    );

    yearList = [
      DateTime.now().year - 1,
      DateTime.now().year,
      DateTime.now().year + 1,
    ];

    initializeDateFormatting('id_ID', null).then((_) {
      setState(() => _localeInitialized = true);
    });

    daysInMonth = getDaysInMonth(selectedYear, selectedMonth);

    final today = DateTime.now();
    selectedDayIndex = daysInMonth.indexWhere(
      (d) =>
          d.day == today.day && d.month == today.month && d.year == today.year,
    );

    if (selectedDayIndex == -1) selectedDayIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients && selectedDayIndex >= 0) {
        final offset = selectedDayIndex * 77.0; // posisi sesuai index hari ini
        _scrollController.jumpTo(offset);
      }
    });

    loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => laporanSemua = []);
    try {
      allKaryawan = await _laporanService.getAllKaryawan();
      List<Map<String, dynamic>> tempList = [];
      for (var karyawan in allKaryawan) {
        final laporan = await _laporanService.getLaporanKaryawan(
          karyawan,
          selectedMonth,
          selectedYear,
        );
        tempList.add(laporan);
      }
      setState(() => laporanSemua = tempList);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
    }
  }

  List<DateTime> getDaysInMonth(int year, int month) {
    final nextMonth = DateTime(year, month + 1, 1);
    final totalDays = nextMonth.subtract(const Duration(days: 1)).day;
    List<DateTime> allDays = List.generate(
      totalDays,
      (i) => DateTime(year, month, i + 1),
    );

    final now = DateTime.now();
    if (year == now.year && month == now.month) {
      allDays = allDays.where((d) => d.day <= now.day).toList();
    }

    return allDays;
  }

  ImageProvider<Object> profileImage(dataKaryawan karyawan) {
    if (karyawan.fotoProfil != null && karyawan.fotoProfil!.isNotEmpty) {
      final path = karyawan.fotoProfil!;
      // Bila path sudah berupa URL publik
      if (path.startsWith('http')) {
        return NetworkImage(path);
      }
      // Bila hanya menyimpan nama file atau path relative dalam bucket
      final bucket = 'Aplikasi_Absensi';
      final fullPath = 'Foto_Profile/$path';
      final publicUrl = Supabase.instance.client.storage
          .from(bucket)
          .getPublicUrl(fullPath);
      return NetworkImage(publicUrl);
    } else {
      return const AssetImage('assets/images/avatar.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized)
      return const Center(child: CircularProgressIndicator());

    daysInMonth = getDaysInMonth(selectedYear, selectedMonth);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text("Laporan Harian Karyawan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: bulanList[selectedMonth - 1],
                    items: bulanList
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedMonth = bulanList.indexOf(val) + 1;
                          daysInMonth = getDaysInMonth(
                            selectedYear,
                            selectedMonth,
                          );
                          selectedDayIndex = 0;
                        });
                        loadData();
                      }
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
                  child: DropdownButtonFormField<int>(
                    value: selectedYear,
                    items: yearList
                        .map(
                          (y) => DropdownMenuItem(value: y, child: Text("$y")),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedYear = val;
                          daysInMonth = getDaysInMonth(
                            selectedYear,
                            selectedMonth,
                          );
                          selectedDayIndex = 0;
                        });
                        loadData();
                      }
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 85,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: daysInMonth.length,
                itemBuilder: (context, index) {
                  final date = daysInMonth[index];
                  final dayName = DateFormat('EEE', 'id_ID').format(date);
                  final dayNum = DateFormat('d').format(date);
                  final isSelected = index == selectedDayIndex;

                  return GestureDetector(
                    onTap: () => setState(() => selectedDayIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.all(10),
                      width: 65,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[100] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.blueAccent
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dayNum,
                            style: TextStyle(
                              fontSize: 18,
                              color: isSelected
                                  ? Colors.blueAccent
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: laporanSemua.map((lapKaryawan) {
                final karyawan = lapKaryawan["karyawan"] as dataKaryawan;
                final laporan =
                    lapKaryawan["laporan"] as List<Map<String, dynamic>>;
                final safeIndex = selectedDayIndex.clamp(0, laporan.length - 1);
                final statusHariIni = laporan[safeIndex];

                return GestureDetector(
                  onTap: () async {
                    final checkin = statusHariIni["checkin"] as Checkin?;
                    final checkout = statusHariIni["checkout"];

                    if (checkin == null && checkout == null) {
                      // Tidak ada data sama sekali
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Laporan CICO"),
                          content: const Text(
                            "Data CICO untuk tanggal ini belum tersedia.",
                          ),
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

                    // Jika checkin ada, navigasi ke detail (checkout bisa null)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailLaporanOwnerPage(
                          checkin: checkin,
                          checkout: checkout,
                        ),
                      ),
                    );
                  },

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
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: profileImage(karyawan),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                karyawan.namaLengkap,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                statusHariIni["status"],
                                style: TextStyle(
                                  color: statusHariIni["color"],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
