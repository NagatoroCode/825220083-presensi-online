import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/database/pengajuanIzin_database.dart';
import 'package:aplikasiabsensi/model/pengajuanIzin.dart';
import 'package:aplikasiabsensi/pages/Karyawan/Izin%20Kerja/detailIzinKaryawan_page.dart';
import 'package:aplikasiabsensi/widgets/Izin/karyawanIzinCard.dart';
import 'package:flutter/material.dart';

class HistoryIzinKaryawan extends StatefulWidget {
  final String userID; // hanya tampil milik user login

  const HistoryIzinKaryawan({super.key, required this.userID});

  @override
  State<HistoryIzinKaryawan> createState() => _HistoryIzinKaryawanState();
}

class _HistoryIzinKaryawanState extends State<HistoryIzinKaryawan> {
  final pengajuanIzinDB = pengajuanIzinDatabase();
  final karyawanDB = DatakaryawanDatabase();
  late Future<List<Map<String, dynamic>>> pengajuanIzinFuture;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
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

            // Filter status "Disetujui", "Ditolak", "Dibatalkan"
            final izinList = snapshot.data!.where((item) {
              final status = (item['izin'] as PengajuanIzin).statusPengajuan
                  .toLowerCase();
              return status == "pengajuan disetujui".toLowerCase() ||
                  status == "pengajuan ditolak".toLowerCase() ||
                  status == "pengajuan dibatalkan".toLowerCase();
            }).toList();

            if (izinList.isEmpty) {
              return const Center(child: Text('Belum ada riwayat izin'));
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
                        builder: (context) => DetailIzinKaryawan(izin: izin),
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
    );
  }
}
