import 'package:flutter/material.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/pengajuanCuti_database.dart';
import 'package:aplikasiabsensi/model/pengajuanCuti.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Izin%20Cuti/detailCutiKaryawan_page.dart';
import 'package:aplikasiabsensi/widgets/Izin/karyawanCutiCard.dart';

class HistoryCutiKaryawan extends StatefulWidget {
  final String userID;
  const HistoryCutiKaryawan({super.key, required this.userID});

  @override
  State<HistoryCutiKaryawan> createState() => _HistoryCutiKaryawanState();
}

class _HistoryCutiKaryawanState extends State<HistoryCutiKaryawan> {
  final PengajuancutiDatabase db = PengajuancutiDatabase();
  final DatakaryawanDatabase karyawanDB = DatakaryawanDatabase();
  late Future<List<Map<String, dynamic>>> pengajuanCutiFuture;

  @override
  void initState() {
    super.initState();
    pengajuanCutiFuture = getPengajuanDenganNamaKaryawan();
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
  Widget build(BuildContext context) {
    return Padding(
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
            return const Center(child: Text('Belum ada riwayat cuti'));
          }

          final historyList = snapshot.data!
              .where(
                (item) =>
                    (item['cuti'] as Pengajuancuti).statusPengajuan
                        .toLowerCase() !=
                    "menunggu approval",
              )
              .toList();

          if (historyList.isEmpty) {
            return const Center(child: Text('Belum ada riwayat cuti'));
          }

          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];
              final cuti = item['cuti'] as Pengajuancuti;
              final namaKaryawan = item['namaKaryawan'] as String;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailCutiKaryawan(cuti: cuti),
                    ),
                  );
                },
                child: Karyawancuticard(
                  namaKaryawan: namaKaryawan,
                  jenisCuti: cuti.cuti?.namaCuti ?? "-",
                  tanggal: "${cuti.tanggalMulai} s/d ${cuti.tanggalSelesai}",
                  status: cuti.statusPengajuan,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
