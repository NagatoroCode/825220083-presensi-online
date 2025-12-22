import 'package:flutter/material.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/pengajuanCuti_database.dart';
import 'package:aplikasiabsensi/model/pengajuanCuti.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Izin%20Cuti/detailCutiKaryawan_page.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Izin%20Cuti/historyCutiKaryawan_page.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Izin%20Cuti/tambahCuti_page.dart';
import 'package:aplikasiabsensi/widgets/Izin/karyawanCutiCard.dart';

class ApprovalCutiKaryawan extends StatefulWidget {
  final String userID;

  const ApprovalCutiKaryawan({super.key, required this.userID});

  @override
  State<ApprovalCutiKaryawan> createState() => _ApprovalCutiKaryawanState();
}

class _ApprovalCutiKaryawanState extends State<ApprovalCutiKaryawan>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final PengajuancutiDatabase db = PengajuancutiDatabase();
  final DatakaryawanDatabase karyawanDB = DatakaryawanDatabase();
  late Future<List<Map<String, dynamic>>> pengajuanCutiFuture;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    pengajuanCutiFuture = getPengajuanDenganNamaKaryawan();
  }

  Future<void> refreshData() async {
    setState(() {
      pengajuanCutiFuture = getPengajuanDenganNamaKaryawan();
    });
  }

  Future<List<Map<String, dynamic>>> getPengajuanDenganNamaKaryawan() async {
    final cutiList = await db.getStatusWithCutiByUser(widget.userID);
    List<Map<String, dynamic>> result = [];

    for (var cuti in cutiList) {
      final karyawan = await karyawanDB.getKaryawanByUserId(cuti.userID!);
      result.add({'cuti': cuti, 'namaKaryawan': karyawan?.namaLengkap ?? '-'});
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
          title: const Text("Daftar Pengajuan Izin Cuti"),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.black,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: const [
              Tab(text: "Cuti Aktif"),
              Tab(text: "History Cuti"),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            // TAB 1: Pengajuan Cuti Aktif
            Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: pengajuanCutiFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Belum ada pengajuan cuti'),
                    );
                  }

                  final cutiList = snapshot.data!
                      .where(
                        (item) =>
                            (item['cuti'] as Pengajuancuti).statusPengajuan
                                .toLowerCase() ==
                            "menunggu approval",
                      )
                      .toList();

                  if (cutiList.isEmpty) {
                    return const Center(
                      child: Text('Belum ada pengajuan cuti aktif'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: refreshData,
                    child: ListView.builder(
                      itemCount: cutiList.length,
                      itemBuilder: (context, index) {
                        final item = cutiList[index];
                        final cuti = item['cuti'] as Pengajuancuti;
                        final namaKaryawan = item['namaKaryawan'] as String;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailCutiKaryawan(cuti: cuti),
                              ),
                            );
                          },
                          child: Karyawancuticard(
                            namaKaryawan:
                                namaKaryawan, // 🔹 tampilkan namaKaryawan
                            jenisCuti: cuti.cuti?.namaCuti ?? "-",
                            tanggal:
                                "${cuti.tanggalMulai} s/d ${cuti.tanggalSelesai}",
                            status: cuti.statusPengajuan,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // TAB 2: History Cuti
            HistoryCutiKaryawan(userID: widget.userID),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TambahCutiPage(userID: widget.userID),
              ),
            );
            refreshData();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
