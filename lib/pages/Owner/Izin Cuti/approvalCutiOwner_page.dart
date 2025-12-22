import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/pengajuanCuti_database.dart';
import 'package:aplikasiabsensi/model/pengajuanCuti.dart';
import 'package:aplikasiabsensi/widgets/Izin/onwerCutiCard.dart';
import 'package:flutter/material.dart';
import 'package:aplikasiabsensi/pages/Owner/Izin%20Cuti/detailCutiOwner_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Izin%20Cuti/historyCutiOwner_page.dart';

class ApprovalCutiOwner extends StatefulWidget {
  const ApprovalCutiOwner({super.key});

  @override
  State<ApprovalCutiOwner> createState() => _ApprovalCutiOwnerState();
}

class _ApprovalCutiOwnerState extends State<ApprovalCutiOwner>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final PengajuancutiDatabase db = PengajuancutiDatabase();
  final DatakaryawanDatabase karyawanDB = DatakaryawanDatabase();
  late Future<List<Map<String, dynamic>>> pengajuanCutiFuture;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    pengajuanCutiFuture = _getActiveCutiWithNama();
  }

  Future<List<Map<String, dynamic>>> _getActiveCutiWithNama() async {
    final allCuti = await db.getStatusWithCuti();

    // Filter status "Menunggu Approval"
    final activeList = allCuti
        .where(
          (cuti) => cuti.statusPengajuan.toLowerCase() == "menunggu approval",
        )
        .toList();

    // Tambahkan nama karyawan
    List<Map<String, dynamic>> listWithNama = [];
    for (var cuti in activeList) {
      final karyawan = await karyawanDB.getKaryawanByUserId(cuti.userID!);
      listWithNama.add({
        "cuti": cuti,
        "namaKaryawan": karyawan?.namaLengkap ?? "Tidak diketahui",
      });
    }
    return listWithNama;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Daftar Pengajuan Cuti"),
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
            // TAB 1: Cuti Aktif
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
                      child: Text('Belum ada pengajuan cuti dari karyawan'),
                    );
                  }

                  final list = snapshot.data!;
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final cuti = list[index]["cuti"] as Pengajuancuti;
                      final namaKaryawan =
                          list[index]["namaKaryawan"] as String;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailCutiOwner(cuti: cuti),
                            ),
                          );
                        },
                        child: Ownercuticard(
                          namaLengkap: namaKaryawan,
                          jenisCuti: "${cuti.cuti?.namaCuti}",
                          tanggal:
                              "${cuti.tanggalMulai} s/d ${cuti.tanggalSelesai}",
                          status: cuti.statusPengajuan,
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // TAB 2: History Cuti
            const HistoryCutiOwner(),
          ],
        ),
      ),
    );
  }
}
