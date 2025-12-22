import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/pengajuanIzin_database.dart';
import 'package:aplikasiabsensi/model/pengajuanIzin.dart';
import 'package:aplikasiabsensi/pages/Owner/Izin%20Kerja/detailIzinOwner_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Izin%20Kerja/historyIzinOwner_page.dart';
import 'package:aplikasiabsensi/widgets/Izin/ownerIzinCard.dart';
import 'package:flutter/material.dart';

class ApprovalIzinOwner extends StatefulWidget {
  const ApprovalIzinOwner({super.key});

  @override
  State<ApprovalIzinOwner> createState() => _ApprovalIzinOwnerState();
}

class _ApprovalIzinOwnerState extends State<ApprovalIzinOwner>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final pengajuanIzinDatabase izinDB = pengajuanIzinDatabase();
  final DatakaryawanDatabase karyawanDB = DatakaryawanDatabase();
  late Future<List<Map<String, dynamic>>> pengajuanIzinFuture;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    pengajuanIzinFuture = getPengajuanDenganNamaKaryawan();
  }

  Future<List<Map<String, dynamic>>> getPengajuanDenganNamaKaryawan() async {
    final izinList = await izinDB.getStatusWithIzin();
    List<Map<String, dynamic>> result = [];

    for (var izin in izinList) {
      final karyawan = await karyawanDB.getKaryawanByUserId(izin.userID!);
      result.add({'izin': izin, 'namaKaryawan': karyawan?.namaLengkap ?? '-'});
    }

    return result;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Daftar Pengajuan Izin"),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.black,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: const [
              Tab(text: "Izin Aktif"),
              Tab(text: "History Izin"),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            // TAB 1: Pengajuan Aktif
            Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: pengajuanIzinFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Belum ada pengajuan izin dari karyawan'),
                    );
                  }

                  final aktifList = snapshot.data!
                      .where(
                        (item) =>
                            (item['izin'] as PengajuanIzin).statusPengajuan
                                .toLowerCase() ==
                            "menunggu approval",
                      )
                      .toList();

                  if (aktifList.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada pengajuan izin yang aktif'),
                    );
                  }

                  return ListView.builder(
                    itemCount: aktifList.length,
                    itemBuilder: (context, index) {
                      final item = aktifList[index];
                      final izin = item['izin'] as PengajuanIzin;
                      final namaKaryawan = item['namaKaryawan'] as String;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailIzinOwner(izin: izin),
                            ),
                          );
                        },
                        child: Ownerizincard(
                          namaKaryawan: namaKaryawan,
                          jenisIzin: izin.status?.namaStatus ?? "-",
                          tanggal: izin.tanggalIzin,
                          status: izin.statusPengajuan,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const HistoryIzinOwner(),
          ],
        ),
      ),
    );
  }
}
