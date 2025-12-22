import 'package:flutter/material.dart';
import 'package:aplikasiabsensi/database/historygaji_database.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/pages/Owner/Laporan%20Gaji/detailLaporanGajiOwner_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanGajiOwnerPage extends StatefulWidget {
  const LaporanGajiOwnerPage({super.key});

  @override
  State<LaporanGajiOwnerPage> createState() => _LaporanGajiOwnerPageState();
}

class _LaporanGajiOwnerPageState extends State<LaporanGajiOwnerPage> {
  final HistorygajiDatabase _historyGajiDb = HistorygajiDatabase();
  final DatakaryawanDatabase _karyawanDb = DatakaryawanDatabase();

  List<Map<String, dynamic>> gajiList = [];
  List<dataKaryawan> allKaryawan = [];
  bool isLoading = true;

  String selectedMonth = DateTime.now().month.toString();
  String selectedYear = DateTime.now().year.toString();

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
      allKaryawan = await _karyawanDb.getKaryawanWithJabatan();

      final dataGaji = await _historyGajiDb.supabase
          .from('historyGaji')
          .select('*')
          .eq('periodeBulan', selectedMonth)
          .eq('periodeTahun', selectedYear);

      final Map<String, Map<String, dynamic>> gajiMap = {
        for (var g in dataGaji)
          g['karyawanID'].toString(): Map<String, dynamic>.from(g),
      };

      List<Map<String, dynamic>> tempList = allKaryawan.map((karyawan) {
        final gaji = gajiMap[karyawan.karyawanID];

        return {"karyawan": karyawan, "gaji": gaji, "hasGaji": gaji != null};
      }).toList();

      setState(() => gajiList = tempList);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data gaji: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  ImageProvider<Object> profileImage(dataKaryawan? karyawan) {
    if (karyawan != null &&
        karyawan.fotoProfil != null &&
        karyawan.fotoProfil!.isNotEmpty) {
      final path = karyawan.fotoProfil!;
      if (path.startsWith('http')) return NetworkImage(path);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Laporan Gaji Karyawan')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Filter Bulan & Tahun
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedMonth,
                          items: bulanMap.entries
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedMonth = val);
                              loadData();
                            }
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Bulan",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedYear,
                          items:
                              [
                                    DateTime.now().year - 1,
                                    DateTime.now().year,
                                    DateTime.now().year + 1,
                                  ]
                                  .map(
                                    (y) => DropdownMenuItem(
                                      value: y.toString(),
                                      child: Text("$y"),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedYear = val);
                              loadData();
                            }
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Tahun",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // List Gaji
                  Expanded(
                    child: gajiList.isEmpty
                        ? const Center(
                            child: Text(
                              "Belum ada data gaji untuk bulan ini.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: gajiList.length,
                            itemBuilder: (context, index) {
                              final gaji = gajiList[index];
                              final karyawan =
                                  gaji['karyawan'] as dataKaryawan?;
                              final namaJabatan =
                                  karyawan?.jabatan?.namaJabatan ?? "-";

                              return InkWell(
                                onTap: () {
                                  final hasGaji = gaji['hasGaji'] as bool;
                                  final karyawan =
                                      gaji['karyawan'] as dataKaryawan;

                                  if (!hasGaji) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text(
                                          "Data Belum Tersedia",
                                        ),
                                        content: const Text(
                                          "Data gaji bulanan untuk karyawan ini belum tersedia.",
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text("OK"),
                                            onPressed: () =>
                                                Navigator.pop(context),
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
                                          DetailLaporanGajiOwnerPage(
                                            karyawanID: karyawan.karyawanID!,
                                            bulan: selectedMonth,
                                            tahun: selectedYear,
                                          ),
                                    ),
                                  );
                                },

                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              karyawan?.namaLengkap ?? "-",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              namaJabatan,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
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
