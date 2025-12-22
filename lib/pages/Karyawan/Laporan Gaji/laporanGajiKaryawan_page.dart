import 'package:aplikasiabsensi/database/historygaji_database.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Laporan%20Gaji/detailLaporanGajiKaryawan_page.dart';
import 'package:flutter/material.dart';

class LaporanGajiPribadiPage extends StatefulWidget {
  final String userID;

  const LaporanGajiPribadiPage({super.key, required this.userID});

  @override
  State<LaporanGajiPribadiPage> createState() => _LaporanGajiPribadiPageState();
}

class _LaporanGajiPribadiPageState extends State<LaporanGajiPribadiPage> {
  final HistorygajiDatabase _historyGajiDb = HistorygajiDatabase();
  List<Map<String, dynamic>> gajiList = [];

  String selectedYear = "2025"; // tetap string
  bool isLoading = true;

  final Map<String, String> bulanMap = {
    "1": "Januari",
    "2": "Februari",
    "3": "Maret",
    "4": "April",
    "5": "Mei",
    "6": "Juni",
    "7": "Juli",
    "8": "Agustus",
    "9": "September",
    "10": "Oktober",
    "11": "November",
    "12": "Desember",
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      // ambil karyawanID berdasarkan userID
      final karyawanData = await _historyGajiDb.supabase
          .from('dataKaryawan')
          .select('karyawanID')
          .eq('userID', widget.userID)
          .maybeSingle();

      if (karyawanData == null) {
        throw Exception("Data karyawan tidak ditemukan untuk user ini");
      }

      final karyawanID = karyawanData['karyawanID'];

      // ambil data gaji
      final data = await _historyGajiDb.supabase
          .from('historyGaji')
          .select('*')
          .eq('karyawanID', karyawanID)
          .eq('periodeTahun', selectedYear) // string filter
          .order('periodeBulan', ascending: true);

      setState(() {
        gajiList = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data gaji: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<String> getAvailableMonths() {
    final bulanSet = gajiList
        .map((g) => g["periodeBulan"].toString())
        .where((b) => b.isNotEmpty)
        .toSet();
    final bulanList = bulanSet.toList();

    bulanList.sort((a, b) {
      final ai = int.tryParse(a) ?? 0;
      final bi = int.tryParse(b) ?? 0;
      return ai.compareTo(bi);
    });
    return bulanList;
  }

  @override
  Widget build(BuildContext context) {
    final availableMonths = getAvailableMonths();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Laporan Gaji Pribadi')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown Tahun
                  DropdownButtonFormField<String>(
                    value: selectedYear,
                    items: ["2023", "2024", "2025"]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      setState(() => selectedYear = val!);
                      loadData();
                    },
                    decoration: const InputDecoration(
                      labelText: "Tahun",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // List gaji per bulan
                  Expanded(
                    child: availableMonths.isEmpty
                        ? const Center(
                            child: Text(
                              "Belum ada data gaji untuk tahun ini.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: availableMonths.length,
                            itemBuilder: (context, index) {
                              final bulan = availableMonths[index];
                              final namaBulan = bulanMap[bulan] ?? "-";
                              final gaji = gajiList.firstWhere(
                                (g) => g["periodeBulan"].toString() == bulan,
                              );

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailLaporanGajiPage(
                                        karyawanID: gaji["karyawanID"]
                                            .toString(),
                                        bulan: bulan,
                                        tahun: selectedYear,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$namaBulan $selectedYear",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
