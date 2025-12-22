import 'package:aplikasiabsensi/database/jenisPTKP_database.dart';
import 'package:aplikasiabsensi/database/tarifTer_database.dart';
import 'package:aplikasiabsensi/model/jenisPTKP.dart';
import 'package:aplikasiabsensi/model/tarifTER.dart';
import 'package:aplikasiabsensi/widgets/bottomModalTambah.dart';
import 'package:aplikasiabsensi/widgets/dropdown.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TarifterPage extends StatefulWidget {
  const TarifterPage({super.key});

  @override
  State<TarifterPage> createState() => _TarifterPageState();
}

class _TarifterPageState extends State<TarifterPage> {
  final terDB = TarifterDatabase();
  final ptkpDB = JenisptkpDatabase();

  final penghasilanMinimalController = TextEditingController();
  final penghasilanMaksimalController = TextEditingController();
  final tarifPajakController = TextEditingController();

  JenisPTKP? selectedPTKP;
  String? filterPTKPId; // gunakan ID sebagai filter

  @override
  void initState() {
    super.initState();

    // Listener untuk format ribuan
    penghasilanMinimalController.addListener(
      () => formatRibuan(penghasilanMinimalController),
    );
    penghasilanMaksimalController.addListener(
      () => formatRibuan(penghasilanMaksimalController),
    );
  }

  void formatRibuan(TextEditingController controller) {
    String text = controller.text.replaceAll('.', '').replaceAll(',', '');
    if (text.isEmpty) return;
    final value = int.tryParse(text);
    if (value != null) {
      final formatted = NumberFormat('#,###', 'id_ID').format(value);
      if (formatted != controller.text) {
        controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  @override
  void dispose() {
    penghasilanMinimalController.dispose();
    penghasilanMaksimalController.dispose();
    tarifPajakController.dispose();
    super.dispose();
  }

  void tambahTarifTer(List<JenisPTKP> dataPTKP) {
    penghasilanMinimalController.clear();
    penghasilanMaksimalController.clear();
    tarifPajakController.clear();
    selectedPTKP = null;

    dataPTKP.sort((a, b) => a.namaGolongan.compareTo(b.namaGolongan));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Tambah Tarif Ter",
        buttonText: "Simpan",
        onSave: () async {
          if (penghasilanMinimalController.text.trim().isEmpty ||
              penghasilanMaksimalController.text.trim().isEmpty ||
              tarifPajakController.text.trim().isEmpty ||
              selectedPTKP == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Semua field wajib diisi")),
            );
            return;
          }

          final newTer = tarifTer(
            penghasilanMinimal: int.parse(
              penghasilanMinimalController.text.replaceAll('.', ''),
            ),
            penghasilanMaksimal: int.parse(
              penghasilanMaksimalController.text.replaceAll('.', ''),
            ),
            tarifPajak: double.parse(tarifPajakController.text.trim()),
            ptkpID: selectedPTKP!.ptkpID!,
          );

          await terDB.createNewTER(newTer);
          if (!mounted) return;
          Navigator.pop(context);
          setState(() {});
        },
        children: [
          CustomDropdown<String>(
            hint: "Pilih Golongan PTKP",
            value: selectedPTKP?.ptkpID,
            items: dataPTKP.map((ptkp) {
              return DropdownMenuItem<String>(
                value: ptkp.ptkpID,
                child: Text("${ptkp.namaGolongan} - ${ptkp.deskripsi}"),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedPTKP = dataPTKP.firstWhere(
                  (ptkp) => ptkp.ptkpID == value,
                );
              });
            },
          ),
          const SizedBox(height: 16.0),
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
            label: "Tarif Pajak",
            hint: "Ketik Tarif Pajak",
            inputType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  void editTarifTer(tarifTer ter, List<JenisPTKP> dataPTKP) {
    penghasilanMinimalController.text = NumberFormat(
      '#,###',
      'id_ID',
    ).format(ter.penghasilanMinimal);
    penghasilanMaksimalController.text = NumberFormat(
      '#,###',
      'id_ID',
    ).format(ter.penghasilanMaksimal);
    tarifPajakController.text = ter.tarifPajak.toString();

    dataPTKP.sort((a, b) => a.namaGolongan.compareTo(b.namaGolongan));

    selectedPTKP = dataPTKP.firstWhere((ptkp) => ptkp.ptkpID == ter.ptkpID);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Edit Tarif Ter",
        buttonText: "Update",
        onSave: () async {
          if (penghasilanMinimalController.text.trim().isEmpty ||
              penghasilanMaksimalController.text.trim().isEmpty ||
              tarifPajakController.text.trim().isEmpty ||
              selectedPTKP == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Semua field wajib diisi")),
            );
            return;
          }

          final updatedTer = tarifTer(
            tarifTerID: ter.tarifTerID,
            penghasilanMinimal: int.parse(
              penghasilanMinimalController.text.replaceAll('.', ''),
            ),
            penghasilanMaksimal: int.parse(
              penghasilanMaksimalController.text.replaceAll('.', ''),
            ),
            tarifPajak: double.parse(tarifPajakController.text.trim()),
            ptkpID: selectedPTKP!.ptkpID!,
          );

          await terDB.updateTER(updatedTer);
          if (!mounted) return;
          Navigator.pop(context);
          setState(() {});
        },
        children: [
          CustomDropdown<String>(
            hint: "Pilih Golongan PTKP",
            value: selectedPTKP?.ptkpID,
            items: dataPTKP.map((ptkp) {
              return DropdownMenuItem<String>(
                value: ptkp.ptkpID,
                child: Text("${ptkp.namaGolongan} - ${ptkp.deskripsi}"),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedPTKP = dataPTKP.firstWhere(
                  (ptkp) => ptkp.ptkpID == value,
                );
              });
            },
          ),
          const SizedBox(height: 16.0),
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
            label: "Tarif Pajak",
            hint: "Ketik Tarif Pajak",
            inputType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  void deleteTarifTer(String tarifTerID) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await terDB.deleteTer(tarifTerID);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus")));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Tarif TER")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final dataPTKP = await ptkpDB.streamPTKP.first;
          tambahTarifTer(dataPTKP);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Dropdown filter PTKP
          FutureBuilder<List<JenisPTKP>>(
            future: ptkpDB.streamPTKP.first,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final dataPTKP = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomDropdown<String>(
                  hint: "Filter berdasarkan PTKP",
                  value: filterPTKPId,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text("Semua Golongan"),
                    ),
                    ...dataPTKP.map((ptkp) {
                      return DropdownMenuItem<String>(
                        value: ptkp.ptkpID,
                        child: Text(ptkp.namaGolongan),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      filterPTKPId = value;
                    });
                  },
                ),
              );
            },
          ),
          // List TER
          Expanded(
            child: FutureBuilder<List<tarifTer>>(
              future: terDB.fetchAllTER(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Tarif TER available"));
                }

                var listTER = snapshot.data!;

                if (filterPTKPId != null) {
                  listTER = listTER
                      .where((ter) => ter.ptkpID == filterPTKPId)
                      .toList();
                }

                listTER.sort(
                  (a, b) =>
                      a.penghasilanMinimal.compareTo(b.penghasilanMinimal),
                );

                return FutureBuilder<List<JenisPTKP>>(
                  future: ptkpDB.streamPTKP.first,
                  builder: (context, ptkpSnapshot) {
                    if (!ptkpSnapshot.hasData) return const SizedBox();
                    final dataPTKP = ptkpSnapshot.data!;

                    return ListView.builder(
                      itemCount: listTER.length,
                      itemBuilder: (context, index) {
                        final ter = listTER[index];
                        final ptkp = dataPTKP.firstWhere(
                          (ptkp) => ptkp.ptkpID == ter.ptkpID,
                          orElse: () => JenisPTKP(
                            namaGolongan: '-',
                            deskripsi: '-',
                            nilaiPTKP: 0,
                          ),
                        );

                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tampilkan PTKP dulu
                              Text(
                                "PTKP: ${ptkp.namaGolongan} - ${ptkp.deskripsi}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Baru range penghasilan
                              Text(
                                "${NumberFormat('#,###', 'id_ID').format(ter.penghasilanMinimal)} - "
                                "${NumberFormat('#,###', 'id_ID').format(ter.penghasilanMaksimal)}",
                              ),
                              Text("Tarif Pajak: ${ter.tarifPajak}%"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final dataPTKP =
                                      await ptkpDB.streamPTKP.first;
                                  editTarifTer(ter, dataPTKP);
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    deleteTarifTer(ter.tarifTerID!),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
