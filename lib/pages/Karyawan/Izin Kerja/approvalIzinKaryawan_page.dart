import 'package:flutter/material.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/pengajuanIzin_database.dart';
import 'package:aplikasiabsensi/model/pengajuanIzin.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Izin%20Kerja/detailIzinKaryawan_page.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Izin%20Kerja/historyIzinKaryawan_page.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Izin%20Kerja/tambahIzin_page.dart';
import 'package:aplikasiabsensi/widgets/Izin/karyawanIzinCard.dart';

class ApprovalIzinKaryawan extends StatefulWidget {
  final String userID;

  const ApprovalIzinKaryawan({super.key, required this.userID});

  @override
  State<ApprovalIzinKaryawan> createState() => _ApprovalIzinKaryawanState();
}

class _ApprovalIzinKaryawanState extends State<ApprovalIzinKaryawan>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final pengajuanIzinDB = pengajuanIzinDatabase();
  final karyawanDB = DatakaryawanDatabase();
  late Future<List<Map<String, dynamic>>> pengajuanIzinFuture;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    pengajuanIzinFuture = getPengajuanDenganNamaKaryawan();
  }

  Future<List<Map<String, dynamic>>> getPengajuanDenganNamaKaryawan() async {
    final izinList = await pengajuanIzinDB.getStatusWithIzinByUser(
      widget.userID,
    );
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
          title: const Text("Daftar Pengajuan Izin Kerja"),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.black,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: const [
              Tab(text: "Izin Aktif"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
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
                      child: Text('Belum ada pengajuan izin'),
                    );
                  }

                  final izinList = snapshot.data!
                      .where(
                        (item) =>
                            (item['izin'] as PengajuanIzin).statusPengajuan
                                .toLowerCase() ==
                            "menunggu approval",
                      )
                      .toList();

                  if (izinList.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada izin yang menunggu approval'),
                    );
                  }

                  return ListView.builder(
                    itemCount: izinList.length,
                    itemBuilder: (context, index) {
                      final item = izinList[index];
                      final izin = item['izin'] as PengajuanIzin;
                      final namaKaryawan = item['namaKaryawan'] as String;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailIzinKaryawan(izin: izin),
                            ),
                          );
                        },
                        child: Karyawanizincard(
                          namaKaryawan: namaKaryawan,
                          jenisIzin: izin.status?.namaStatus ?? "-",
                          tanggal: "${izin.tanggalIzin}",
                          status: izin.statusPengajuan,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            HistoryIzinKaryawan(userID: widget.userID),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TambahizinPage(userID: widget.userID),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
