import 'package:aplikasiabsensi/database/jabatan_database.dart';
import 'package:aplikasiabsensi/model/jabatan.dart';
import 'package:aplikasiabsensi/widgets/bottomModalTambah.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:flutter/material.dart';

class JabatanPage extends StatefulWidget {
  const JabatanPage({super.key});

  @override
  State<JabatanPage> createState() => _jabatanPageState();
}

class _jabatanPageState extends State<JabatanPage> {
  final JabatanDB = jabatanDatabase();
  final namaJabatanController = TextEditingController();

  void tambahJabatan() {
    namaJabatanController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Tambah Jabatan",
        buttonText: "Simpan",
        onSave: () async {
          if (namaJabatanController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Nama jabatan tidak boleh kosong")),
            );
            return;
          }

          final newJabatan = Jabatan(
            namaJabatan: namaJabatanController.text.trim(),
          );
          await JabatanDB.createJabatan(newJabatan);
          if (!mounted) return;
          Navigator.pop(context);
          namaJabatanController.clear();
        },
        children: [
          CustomTextField(
            controller: namaJabatanController,
            label: "Nama Jabatan",
            hint: "Ketik nama jabatan",
          ),
        ],
      ),
    );
  }

  void editJabatan(Jabatan jabatans) {
    namaJabatanController.text = jabatans.namaJabatan;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Edit Jabatan",
        buttonText: "Update",
        onSave: () async {
          if (namaJabatanController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Nama jabatan tidak boleh kosong")),
            );
            return;
          }

          final updatedJabatan = Jabatan(
            jabatanID: jabatans.jabatanID,
            namaJabatan: namaJabatanController.text.trim(),
          );
          await JabatanDB.updateJabatan(updatedJabatan);

          if (!mounted) return;
          Navigator.pop(context);
          namaJabatanController.clear();
        },
        children: [
          CustomTextField(
            controller: namaJabatanController,
            label: "Nama Jabatan",
            hint: "Ketik nama jabatan",
          ),
        ],
      ),
    );
  }

  void deleteJabatan(Jabatan jabatans) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Jabatan"),
        content: Text(
          "Apakah kamu yakin ingin menghapus '${jabatans.namaJabatan}' ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await JabatanDB.deleteJabatan(jabatans.jabatanID!);
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
      appBar: AppBar(title: const Text("List Jabatan")),
      floatingActionButton: FloatingActionButton(
        onPressed: tambahJabatan,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<Jabatan>>(
        stream: JabatanDB.StreamJabatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Jabatan available"));
          }

          final jabatans = snapshot.data!;

          return ListView.builder(
            itemCount: jabatans.length,
            itemBuilder: (context, index) {
              final jabatan = jabatans[index];
              return ListTile(
                title: Text(jabatan.namaJabatan),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => editJabatan(jabatan),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit, color: Colors.black),
                    ),
                    IconButton(
                      onPressed: () => deleteJabatan(jabatan),
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
