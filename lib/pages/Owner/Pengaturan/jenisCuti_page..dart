import 'package:aplikasiabsensi/database/jenisCuti_database..dart';
import 'package:aplikasiabsensi/model/jenisCuti.dart';
import 'package:aplikasiabsensi/widgets/bottomModalTambah.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:flutter/material.dart';

class JeniscutiPage extends StatefulWidget {
  const JeniscutiPage({super.key});

  @override
  State<JeniscutiPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<JeniscutiPage> {
  final cutiDB = jenisCutiDatabase();
  final namaCutiController = TextEditingController();

  void tambahJenisCuti() {
    namaCutiController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Tambah Jenis Cuti",
        buttonText: "Simpan",
        onSave: () async {
          if (namaCutiController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Nama Cuti tidak boleh kosong")),
            );
            return;
          }

          final newCuti = jenisCuti(namaCuti: namaCutiController.text.trim());
          await cutiDB.createNewCuti(newCuti);
          if (!mounted) return;
          Navigator.pop(context);
          namaCutiController.clear();
        },
        children: [
          CustomTextField(
            controller: namaCutiController,
            label: "Nama Cuti",
            hint: "Ketik Nama Cuti",
          ),
        ],
      ),
    );
  }

  void editJenisCuti(jenisCuti statusCuti) {
    namaCutiController.text = statusCuti.namaCuti;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Edit Cuti",
        buttonText: "Update",
        onSave: () async {
          if (namaCutiController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Nama Cuti tidak boleh kosong")),
            );
            return;
          }

          final updatedCuti = jenisCuti(
            jenisCutiID: statusCuti.jenisCutiID,
            namaCuti: namaCutiController.text.trim(),
          );
          await cutiDB.updateCuti(updatedCuti);

          if (!mounted) return;
          Navigator.pop(context);
          namaCutiController.clear();
        },
        children: [
          CustomTextField(
            controller: namaCutiController,
            label: "Nama Cuti",
            hint: "Ketik nama cuti",
          ),
        ],
      ),
    );
  }

  void deleteCuti(jenisCuti statusCuti) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Cuti"),
        content: Text(
          "Apakah kamu yakin ingin menghapus '${statusCuti.namaCuti}' ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await cutiDB.deleteCuti(statusCuti.jenisCutiID!);
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
      appBar: AppBar(title: const Text("List Jenis Cuti")),
      floatingActionButton: FloatingActionButton(
        onPressed: tambahJenisCuti,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<jenisCuti>>(
        stream: cutiDB.streamCuti,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Jenis Cuti available"));
          }

          final statusCuti = snapshot.data!;

          return ListView.builder(
            itemCount: statusCuti.length,
            itemBuilder: (context, index) {
              final status = statusCuti[index];
              return ListTile(
                title: Text(status.namaCuti),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => editJenisCuti(status),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit, color: Colors.black),
                    ),
                    IconButton(
                      onPressed: () => deleteCuti(status),
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
