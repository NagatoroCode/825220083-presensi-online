import 'package:aplikasiabsensi/database/jenisStatus_database.dart';
import 'package:aplikasiabsensi/model/jenisStatus.dart';
import 'package:aplikasiabsensi/widgets/bottomModalTambah.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:flutter/material.dart';

class JenisstatusPage extends StatefulWidget {
  const JenisstatusPage({super.key});

  @override
  State<JenisstatusPage> createState() => _JenisstatusPageState();
}

class _JenisstatusPageState extends State<JenisstatusPage> {
  final statusDB = JenisstatusDatabase();
  final namaStatusController = TextEditingController();

  void tambahJenisStatus() {
    namaStatusController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Tambah Jenis Status",
        buttonText: "Simpan",
        onSave: () async {
          if (namaStatusController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Nama Status tidak boleh kosong")),
            );
            return;
          }

          final newStatus = jenisStatus(
            namaStatus: namaStatusController.text.trim(),
          );
          await statusDB.createNewStatus(newStatus);
          if (!mounted) return;
          Navigator.pop(context);
          namaStatusController.clear();
        },
        children: [
          CustomTextField(
            controller: namaStatusController,
            label: "Nama Status",
            hint: "Ketik Nama Status",
          ),
        ],
      ),
    );
  }

  void editJenisStatus(jenisStatus statusCICO) {
    namaStatusController.text = statusCICO.namaStatus;

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
          if (namaStatusController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Nama jabatan tidak boleh kosong")),
            );
            return;
          }

          final updatedStatus = jenisStatus(
            statusID: statusCICO.statusID,
            namaStatus: namaStatusController.text.trim(),
          );
          await statusDB.updateStatus(updatedStatus);

          if (!mounted) return;
          Navigator.pop(context);
          namaStatusController.clear();
        },
        children: [
          CustomTextField(
            controller: namaStatusController,
            label: "Nama Jabatan",
            hint: "Ketik nama jabatan",
          ),
        ],
      ),
    );
  }

  void deleteStatus(jenisStatus statusCICO) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Jabatan"),
        content: Text(
          "Apakah kamu yakin ingin menghapus '${statusCICO.namaStatus}' ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await statusDB.deleteStatus(statusCICO.statusID!);
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
      appBar: AppBar(title: const Text("List Status CICO")),
      floatingActionButton: FloatingActionButton(
        onPressed: tambahJenisStatus,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<jenisStatus>>(
        stream: statusDB.StreamStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Status CICO available"));
          }

          final statusCICO = snapshot.data!;

          return ListView.builder(
            itemCount: statusCICO.length,
            itemBuilder: (context, index) {
              final status = statusCICO[index];
              return ListTile(
                title: Text(status.namaStatus),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => editJenisStatus(status),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit, color: Colors.black),
                    ),
                    IconButton(
                      onPressed: () => deleteStatus(status),
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
