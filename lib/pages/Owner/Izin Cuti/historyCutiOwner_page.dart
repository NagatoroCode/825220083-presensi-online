import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/pengajuanCuti_database.dart';
import 'package:aplikasiabsensi/model/pengajuanCuti.dart';
import 'package:aplikasiabsensi/pages/Owner/Izin%20Cuti/detailCutiOwner_page.dart';
import 'package:aplikasiabsensi/widgets/Izin/onwerCutiCard.dart';
import 'package:flutter/material.dart';

class HistoryCutiOwner extends StatefulWidget {
  const HistoryCutiOwner({super.key});

  @override
  State<HistoryCutiOwner> createState() => _HistoryCutiOwnerState();
}

class _HistoryCutiOwnerState extends State<HistoryCutiOwner> {
  final PengajuancutiDatabase db = PengajuancutiDatabase();
  final DatakaryawanDatabase karyawanDB = DatakaryawanDatabase();
  late Future<List<Map<String, dynamic>>> historyCutiFuture;

  @override
  void initState() {
    super.initState();
    historyCutiFuture = _getHistoryCutiWithNama();
  }

  Future<List<Map<String, dynamic>>> _getHistoryCutiWithNama() async {
    final allCuti = await db.getStatusWithCuti();

    // Filter status "Pengajuan Disetujui" & "Pengajuan Ditolak"
    final filtered = allCuti
        .where(
          (cuti) =>
              cuti.statusPengajuan.toLowerCase() == "pengajuan disetujui" ||
              cuti.statusPengajuan.toLowerCase() == "pengajuan ditolak",
        )
        .toList();

    // Tambahkan nama karyawan
    List<Map<String, dynamic>> listWithNama = [];
    for (var cuti in filtered) {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: historyCutiFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Belum ada riwayat cuti karyawan'),
              );
            }

            final list = snapshot.data!;
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final cuti = list[index]["cuti"] as Pengajuancuti;
                final namaKaryawan = list[index]["namaKaryawan"] as String;

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
                    tanggal: "${cuti.tanggalMulai} s/d ${cuti.tanggalSelesai}",
                    status: cuti.statusPengajuan,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
