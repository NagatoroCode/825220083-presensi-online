import 'package:aplikasiabsensi/database/dataKaryawan_database.dart';
import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/pages/Owner/Pengaturan/editKaryawan_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Pengaturan/tambahKaryawan_page.dart';
import 'package:aplikasiabsensi/widgets/fotoProfile.dart';
import 'package:flutter/material.dart';

class MenukaryawanPage extends StatefulWidget {
  const MenukaryawanPage({super.key});

  @override
  State<MenukaryawanPage> createState() => _MenukaryawanPageState();
}

class _MenukaryawanPageState extends State<MenukaryawanPage> {
  final karyawanDB = DatakaryawanDatabase();

  Future<List<dataKaryawan>>? _futureKaryawan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureKaryawan = karyawanDB.getKaryawanWithJabatan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar User")),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
          await _futureKaryawan;
        },
        child: FutureBuilder<List<dataKaryawan>>(
          future: _futureKaryawan,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada data karyawan."));
            }

            final karyawanList = snapshot.data!;

            return ListView.builder(
              itemCount: karyawanList.length,
              itemBuilder: (context, index) {
                final karyawan = karyawanList[index];

                // Controller untuk foto profil setiap karyawan
                final controller = fotoProfileController();
                if (karyawan.fotoProfil != null &&
                    karyawan.fotoProfil!.isNotEmpty) {
                  controller.setImage(karyawan.fotoProfil!);
                }

                return ListTile(
                  leading: Fotoprofile(size: 50, controller: controller),
                  title: Text(
                    karyawan.namaLengkap,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(karyawan.jabatan?.namaJabatan ?? "-"),
                      Text(karyawan.nomorTelepon),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: karyawan.status == "Active"
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(karyawan.status == "Active" ? "Active" : "Inactive"),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditKaryawanPage(karyawan: karyawan),
                      ),
                    ).then((_) => _loadData());
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahkaryawanPage()),
          ).then((_) => _loadData()); // refresh setelah tambah karyawan
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
