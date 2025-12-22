import 'package:aplikasiabsensi/model/dataKaryawan.dart';
import 'package:aplikasiabsensi/widgets/fotoProfile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatakaryawanPage extends StatefulWidget {
  final dataKaryawan? karyawan;

  const DatakaryawanPage({super.key, this.karyawan});

  @override
  State<DatakaryawanPage> createState() => _DatakaryawanPageState();
}

class _DatakaryawanPageState extends State<DatakaryawanPage> {
  final fotoProfileController fotoController = fotoProfileController();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    // Set foto profil jika tersedia dari Supabase
    if (widget.karyawan?.fotoProfil != null &&
        widget.karyawan!.fotoProfil!.isNotEmpty) {
      fotoController.setImage(widget.karyawan!.fotoProfil!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final karyawan = widget.karyawan;
    final currentUser = supabase.auth.currentUser;
    final email = currentUser?.email ?? '-';

    // Jika data karyawan tidak ada
    if (karyawan == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Profile Data Karyawan')),
        body: const Center(
          child: Text(
            "Data karyawan tidak tersedia untuk akun ini.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Jika data karyawan ada
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Profile Data Karyawan')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                Fotoprofile(size: 90, controller: fotoController),

                const SizedBox(height: 16),

                Text(
                  karyawan.namaLengkap,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // KARTU DATA KARYAWAN
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tambahkan Email di atas Jabatan
                      _InfoItem(title: 'Email', value: email),
                      const Divider(),

                      _InfoItem(
                        title: 'Jabatan',
                        value: karyawan.jabatan?.namaJabatan ?? '-',
                      ),
                      const Divider(),

                      _InfoItem(
                        title: 'Gaji Pokok',
                        value: NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(karyawan.gajiPokok),
                      ),
                      const Divider(),

                      _InfoItem(
                        title: 'Uang Makan',
                        value: NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(karyawan.uangMakan),
                      ),
                      const Divider(),

                      _InfoItem(
                        title: 'Status Golongan',
                        value: karyawan.jenisPTKP != null
                            ? "${karyawan.jenisPTKP!.namaGolongan} - ${karyawan.jenisPTKP!.deskripsi}"
                            : '-',
                      ),
                      const Divider(),

                      _InfoItem(
                        title: 'Tanggal Masuk',
                        value: _formatTanggal(karyawan.tanggalMasuk),
                      ),
                      const Divider(),

                      _InfoItem(
                        title: 'Status Karyawan',
                        value: karyawan.status,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi format tanggal
  String _formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(tanggal);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return '-';
    }
  }
}

// WIDGET UNTUK ITEM INFORMASI
class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
