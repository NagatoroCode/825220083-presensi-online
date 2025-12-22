import 'package:aplikasiabsensi/database/tarifProgresif_database.dart';
import 'package:aplikasiabsensi/model/tarifProgresif.dart';
import 'package:aplikasiabsensi/widgets/bottomModalTambah.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TarifprogresifPage extends StatefulWidget {
  const TarifprogresifPage({super.key});

  @override
  State<TarifprogresifPage> createState() => _TarifprogresifPageState();
}

class _TarifprogresifPageState extends State<TarifprogresifPage> {
  final progresifDB = TarifprogresifDatabase();
  final penghasilanMinimalController = TextEditingController();
  final penghasilanMaksimalController = TextEditingController();
  final tarifPajakController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Format ribuan untuk minimal
    penghasilanMinimalController.addListener(() {
      final text = penghasilanMinimalController.text.replaceAll('.', '');
      if (text.isEmpty) return;
      final value = int.tryParse(text);
      if (value != null) {
        final newText = NumberFormat('#,###', 'id_ID').format(value);
        if (newText != penghasilanMinimalController.text) {
          penghasilanMinimalController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }
      }
    });

    // Format ribuan untuk maksimal
    penghasilanMaksimalController.addListener(() {
      final text = penghasilanMaksimalController.text.replaceAll('.', '');
      if (text.isEmpty) return;
      final value = int.tryParse(text);
      if (value != null) {
        final newText = NumberFormat('#,###', 'id_ID').format(value);
        if (newText != penghasilanMaksimalController.text) {
          penghasilanMaksimalController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }
      }
    });

    // Tarif pajak selalu 1 desimal
    tarifPajakController.addListener(() {
      final text = tarifPajakController.text;
      if (text.isEmpty) return;
      double? value = double.tryParse(text);
      if (value != null) {
        tarifPajakController.value = TextEditingValue(
          text: value.toStringAsFixed(1),
          selection: TextSelection.collapsed(
            offset: value.toStringAsFixed(1).length,
          ),
        );
      }
    });
  }

  void tambahTarifProgresif() {
    penghasilanMinimalController.clear();
    penghasilanMaksimalController.clear();
    tarifPajakController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Tambah Tarif Progresif",
        buttonText: "Simpan",
        onSave: () async {
          if (penghasilanMinimalController.text.trim().isEmpty ||
              penghasilanMaksimalController.text.trim().isEmpty ||
              tarifPajakController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data tidak boleh kosong")),
            );
            return;
          }

          final minimal = int.parse(
            penghasilanMinimalController.text.replaceAll('.', ''),
          );
          final maksimal = int.parse(
            penghasilanMaksimalController.text.replaceAll('.', ''),
          );
          final tarif = double.parse(tarifPajakController.text);

          final newProgresif = tarifProgresif(
            penghasilanMinimal: minimal,
            penghasilanMaksimal: maksimal,
            tarifPajak: tarif,
          );

          await progresifDB.createNewProgresif(newProgresif);
          if (!mounted) return;
          Navigator.pop(context);

          penghasilanMinimalController.clear();
          penghasilanMaksimalController.clear();
          tarifPajakController.clear();
        },
        children: [
          CustomTextField(
            controller: penghasilanMinimalController,
            label: "Penghasilan Minimal",
            hint: "Ketik Penghasilan Minimal",
            inputType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: penghasilanMaksimalController,
            label: "Penghasilan Maksimal",
            hint: "Ketik Penghasilan Maksimal",
            inputType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: tarifPajakController,
            label: "Tarif Pajak (%)",
            hint: "Ketik Tarif Pajak",
            inputType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  void editTarifProgresif(tarifProgresif progresif) {
    penghasilanMinimalController.text = NumberFormat(
      '#,###',
      'id_ID',
    ).format(progresif.penghasilanMinimal);
    penghasilanMaksimalController.text = NumberFormat(
      '#,###',
      'id_ID',
    ).format(progresif.penghasilanMaksimal);
    tarifPajakController.text = progresif.tarifPajak.toStringAsFixed(1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Edit Tarif Progresif",
        buttonText: "Update",
        onSave: () async {
          if (penghasilanMinimalController.text.trim().isEmpty ||
              penghasilanMaksimalController.text.trim().isEmpty ||
              tarifPajakController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data tidak boleh kosong")),
            );
            return;
          }

          final minimal = int.parse(
            penghasilanMinimalController.text.replaceAll('.', ''),
          );
          final maksimal = int.parse(
            penghasilanMaksimalController.text.replaceAll('.', ''),
          );
          final tarif = double.parse(tarifPajakController.text);

          final updatedProgresif = tarifProgresif(
            tarifProgresifID: progresif.tarifProgresifID,
            penghasilanMinimal: minimal,
            penghasilanMaksimal: maksimal,
            tarifPajak: tarif,
          );

          await progresifDB.updateProgresif(updatedProgresif);
          if (!mounted) return;
          Navigator.pop(context);

          penghasilanMinimalController.clear();
          penghasilanMaksimalController.clear();
          tarifPajakController.clear();
        },
        children: [
          CustomTextField(
            controller: penghasilanMinimalController,
            label: "Penghasilan Minimal",
            hint: "Ketik Penghasilan Minimal",
            inputType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: penghasilanMaksimalController,
            label: "Penghasilan Maksimal",
            hint: "Ketik Penghasilan Maksimal",
            inputType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            controller: tarifPajakController,
            label: "Tarif Pajak (%)",
            hint: "Ketik Tarif Pajak",
            inputType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  void deleteProgresif(tarifProgresif progresif) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Tarif Progresif"),
        content: Text(
          "Apakah kamu yakin ingin menghapus '${NumberFormat('#,###', 'id_ID').format(progresif.penghasilanMinimal)} - ${NumberFormat('#,###', 'id_ID').format(progresif.penghasilanMaksimal)}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await progresifDB.deleteProgresif(progresif.tarifProgresifID!);
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
      appBar: AppBar(title: const Text("List Tarif Progresif")),
      floatingActionButton: FloatingActionButton(
        onPressed: tambahTarifProgresif,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<tarifProgresif>>(
        stream: progresifDB.streamProgresif,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Tarif Progresif Available"));
          }

          final dataProgresif = snapshot.data!;

          return ListView.builder(
            itemCount: dataProgresif.length,
            itemBuilder: (context, index) {
              final progresif = dataProgresif[index];
              final formattedMinimal = NumberFormat(
                '#,###',
                'id_ID',
              ).format(progresif.penghasilanMinimal);
              final formattedMaksimal = NumberFormat(
                '#,###',
                'id_ID',
              ).format(progresif.penghasilanMaksimal);
              final formattedTarif = progresif.tarifPajak.toStringAsFixed(1);

              return ListTile(
                title: Text("Rp $formattedMinimal - Rp $formattedMaksimal"),
                subtitle: Text("Tarif Pajak: $formattedTarif%"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => editTarifProgresif(progresif),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit, color: Colors.black),
                    ),
                    IconButton(
                      onPressed: () => deleteProgresif(progresif),
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
