import 'package:aplikasiabsensi/pages/Owner/Pengaturan/jabatan_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Pengaturan/jenisCuti_page..dart';
import 'package:aplikasiabsensi/pages/Owner/Pengaturan/jenisPTKP_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Pengaturan/jenisStatus_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Pengaturan/menuKaryawan_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Pengaturan/roleUser_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Pengaturan/tarifProgresif_page.dart';
import 'package:aplikasiabsensi/pages/Owner/Pengaturan/tarifTer_page.dart';
import 'package:aplikasiabsensi/widgets/pengaturanCard.dart';
import 'package:flutter/material.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Halaman Menu Pengaturan')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pengaturancard(
                  title: "Pengaturan Sistem",
                  items: [
                    pengaturanItem(
                      title: 'Kelola Jenis Role',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Roleuser(),
                          ),
                        );
                      },
                    ),
                    pengaturanItem(
                      title: 'Kelola Jenis Status CICO',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JenisstatusPage(),
                          ),
                        );
                      },
                    ),
                    pengaturanItem(
                      title: 'Kelola Jenis Cuti',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JeniscutiPage(),
                          ),
                        );
                      },
                    ),
                    pengaturanItem(
                      title: 'Kelola Jabatan Karyawan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JabatanPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Pengaturancard(
                  title: "Pengaturan Pajak & Karyawan",
                  items: [
                    pengaturanItem(
                      title: 'Kelola jenis PTKP',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JenisptkpPage(),
                          ),
                        );
                      },
                    ),
                    pengaturanItem(
                      title: 'Kelola Tarif Progresif',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TarifprogresifPage(),
                          ),
                        );
                      },
                    ),
                    pengaturanItem(
                      title: 'Kelola Tarif Ter',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TarifterPage(),
                          ),
                        );
                      },
                    ),
                    pengaturanItem(
                      title: 'Kelola Menu Karyawan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MenukaryawanPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
