import 'package:aplikasiabsensi/database/jenisPTKP_database.dart';
import 'package:aplikasiabsensi/model/jenisPTKP.dart';
import 'package:aplikasiabsensi/widgets/bottomModalTambah.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JenisptkpPage extends StatefulWidget {
  const JenisptkpPage({super.key});

  @override
  State<JenisptkpPage> createState() => _JenisptkpPageState();
}

class _JenisptkpPageState extends State<JenisptkpPage> {
  final ptkpDB = JenisptkpDatabase();
  final namaGolonganController = TextEditingController();
  final deskripsiController = TextEditingController();
  final nilaiPTKPController = TextEditingController();

  void tambahJenisPTKP() {
    // Pastikan controller kosong
    namaGolonganController.clear();
    deskripsiController.clear();
    nilaiPTKPController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Tambah Jenis PTKP",
        buttonText: "Simpan",
        onSave: () async {
          if (namaGolonganController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Nama PTKP tidak boleh kosong")),
            );
            return;
          }

          // Hapus titik jika user memasukkan format ribuan
          final nilaiPTKP = int.parse(
            nilaiPTKPController.text.replaceAll('.', '').trim(),
          );

          final newPTKP = JenisPTKP(
            namaGolongan: namaGolonganController.text.trim(),
            deskripsi: deskripsiController.text.trim(),
            nilaiPTKP: nilaiPTKP,
          );

          await ptkpDB.createNewPTKP(newPTKP);
          if (!mounted) return;
          Navigator.pop(context);

          // bersihkan controller setelah submit
          namaGolonganController.clear();
          deskripsiController.clear();
          nilaiPTKPController.clear();
        },
        children: [
          CustomTextField(
            controller: namaGolonganController,
            label: "Nama Golongan",
            hint: "Ketik Nama Golongan",
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: deskripsiController,
            label: "Deskripsi",
            hint: "Ketik Deskripsi",
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: nilaiPTKPController,
            label: "Nilai PTKP",
            hint: "Ketik Nilai PTKP",
          ),
        ],
      ),
    );
  }

  void editJenisPTKP(JenisPTKP ptkp) {
    // isi form dengan data lama
    namaGolonganController.text = ptkp.namaGolongan;
    deskripsiController.text = ptkp.deskripsi;
    nilaiPTKPController.text = NumberFormat(
      '#,###',
      'id_ID',
    ).format(ptkp.nilaiPTKP);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Edit Jenis PTKP",
        buttonText: "Update",
        onSave: () async {
          if (namaGolonganController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Nama PTKP tidak boleh kosong")),
            );
            return;
          }

          // Hapus titik sebelum parsing ke int
          final nilaiPTKP = int.parse(
            nilaiPTKPController.text.replaceAll('.', '').trim(),
          );

          final updatedPTKP = JenisPTKP(
            ptkpID: ptkp.ptkpID,
            namaGolongan: namaGolonganController.text.trim(),
            deskripsi: deskripsiController.text.trim(),
            nilaiPTKP: nilaiPTKP,
          );

          await ptkpDB.updatePTKP(updatedPTKP);
          if (!mounted) return;
          Navigator.pop(context);

          // bersihkan controller setelah submit
          namaGolonganController.clear();
          deskripsiController.clear();
          nilaiPTKPController.clear();
        },
        children: [
          CustomTextField(
            controller: namaGolonganController,
            label: "Nama Golongan",
            hint: "Ketik Nama Golongan",
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: deskripsiController,
            label: "Deskripsi",
            hint: "Ketik Deskripsi",
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: nilaiPTKPController,
            label: "Nilai PTKP",
            hint: "Ketik Nilai PTKP",
          ),
        ],
      ),
    );
  }

  void deleteJenisPTKP(JenisPTKP ptkp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Jenis PTKP"),
        content: Text(
          "Apakah kamu yakin ingin menghapus '${ptkp.namaGolongan}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await ptkpDB.deletePTKP(ptkp.ptkpID!);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Jenis PTKP")),
      floatingActionButton: FloatingActionButton(
        onPressed: tambahJenisPTKP,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<JenisPTKP>>(
        stream: ptkpDB.streamPTKP,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Jenis PTKP available"));
          }

          final dataPTKP = snapshot.data!;

          // di dalam ListView.builder
          return ListView.builder(
            itemCount: dataPTKP.length,
            itemBuilder: (context, index) {
              final PTKP = dataPTKP[index];
              final formattedNilai = NumberFormat(
                '#,###',
                'id_ID',
              ).format(PTKP.nilaiPTKP);

              return ListTile(
                title: Text(PTKP.namaGolongan),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(PTKP.deskripsi),
                    const SizedBox(height: 4), // jarak tipis
                    Text(
                      "Rp $formattedNilai",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                isThreeLine:
                    true, // supaya ListTile otomatis menyesuaikan tinggi
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => editJenisPTKP(PTKP),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit, color: Colors.black),
                    ),
                    IconButton(
                      onPressed: () => deleteJenisPTKP(PTKP),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
