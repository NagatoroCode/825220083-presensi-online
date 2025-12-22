import 'package:aplikasiabsensi/database/roleUser_database.dart';
import 'package:aplikasiabsensi/model/roleUser.dart';
import 'package:aplikasiabsensi/widgets/bottomModalTambah.dart';
import 'package:aplikasiabsensi/widgets/customTextfield.dart';
import 'package:flutter/material.dart';

class Roleuser extends StatefulWidget {
  const Roleuser({super.key});

  @override
  State<Roleuser> createState() => _RoleuserState();
}

class _RoleuserState extends State<Roleuser> {
  final roleDatabase = RoleDatabase();
  final roleController = TextEditingController();

  // Tambah Role
  void tambahRole() {
    roleController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Tambah Role",
        buttonText: "Simpan",
        onSave: () async {
          if (roleController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Nama role tidak boleh kosong")),
            );
            return;
          }

          final newRole = userRole(namaRole: roleController.text.trim());
          await roleDatabase.createRole(newRole);

          if (!mounted) return;
          Navigator.pop(context);
          roleController.clear();
        },
        children: [
          CustomTextField(
            controller: roleController,
            label: "Nama Role",
            hint: "Ketik nama role",
          ),
        ],
      ),
    );
  }

  // Edit Role
  void editRole(userRole role) {
    roleController.text = role.namaRole; // isi dulu dengan data lama

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomBottomSheetForm(
        title: "Edit Role",
        buttonText: "Update",
        onSave: () async {
          if (roleController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Nama role tidak boleh kosong")),
            );
            return;
          }

          final updatedRole = userRole(
            roleID: role.roleID,
            namaRole: roleController.text.trim(),
          );

          await roleDatabase.updateRole(updatedRole);

          if (!mounted) return;
          Navigator.pop(context);
          roleController.clear();
        },
        children: [
          CustomTextField(
            controller: roleController,
            label: "Nama Role",
            hint: "Ketik nama role",
          ),
        ],
      ),
    );
  }

  // Delete Role
  void deleteRole(userRole role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Role?"),
        content: Text(
          "Apakah Anda yakin ingin menghapus role '${role.namaRole}'?",
        ),
        actions: [
          // tombol batal
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          // tombol hapus
          TextButton(
            onPressed: () async {
              await roleDatabase.deleteRole(role.roleID!);
              Navigator.pop(context);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Role '${role.namaRole}' berhasil dihapus"),
                  ),
                );
              }
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
      appBar: AppBar(title: const Text("Role User")),
      floatingActionButton: FloatingActionButton(
        onPressed: tambahRole,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<userRole>>(
        stream: roleDatabase.roleStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No role available"));
          }

          final rolePengguna = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.separated(
              itemCount: rolePengguna.length,
              separatorBuilder: (context, index) =>
                  const Divider(thickness: 1, height: 1),
              itemBuilder: (context, index) {
                final roles = rolePengguna[index];
                return ListTile(
                  title: Text(roles.namaRole),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => editRole(roles),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.edit, color: Colors.black),
                      ),
                      IconButton(
                        onPressed: () => deleteRole(roles),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
