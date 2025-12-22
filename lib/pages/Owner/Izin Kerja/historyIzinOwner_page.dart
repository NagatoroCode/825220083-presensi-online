import 'package:aplikasiabsensi/database/pengajuanIzin_database.dart';
import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/model/pengajuanIzin.dart';
import 'package:aplikasiabsensi/pages/Owner/Izin%20Kerja/detailIzinOwner_page.dart';
import 'package:aplikasiabsensi/widgets/Izin/ownerIzinCard.dart';
import 'package:flutter/material.dart';

class HistoryIzinOwner extends StatefulWidget {
  const HistoryIzinOwner({super.key});

  @override
  State<HistoryIzinOwner> createState() => _HistoryIzinOwnerState();
}

class _HistoryIzinOwnerState extends State<HistoryIzinOwner> {
  final pengajuanIzinDB = pengajuanIzinDatabase();
  final karyawanDB = DatakaryawanDatabase();
  late Future<List<Map<String, dynamic>>> pengajuanIzinFuture;

  @override
  void initState() {
    super.initState();
    pengajuanIzinFuture = _getHistoryIzinWithNama();
  }

  Future<List<Map<String, dynamic>>> _getHistoryIzinWithNama() async {
    final allIzin = await pengajuanIzinDB.getStatusWithIzin();

    // Filter hanya status "Disetujui" atau "Ditolak"
    final historyList = allIzin
        .where(
          (izin) =>
              izin.statusPengajuan.toLowerCase() == "pengajuan disetujui" ||
              izin.statusPengajuan.toLowerCase() == "pengajuan ditolak",
        )
        .toList();

    // Tambahkan nama karyawan untuk tiap izin
    List<Map<String, dynamic>> listWithNama = [];
    for (var izin in historyList) {
      final karyawan = await karyawanDB.getKaryawanByUserId(izin.userID!);
      listWithNama.add({
        "izin": izin,
        "namaKaryawan": karyawan?.namaLengkap ?? "Tidak diketahui",
      });
    }

    return listWithNama;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            return const Center(child: Text('Belum ada riwayat izin'));
          }

          final historyList = snapshot.data!;
          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final izin = historyList[index]["izin"] as PengajuanIzin;
              final namaKaryawan = historyList[index]["namaKaryawan"] as String;

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
    );
  }
}
