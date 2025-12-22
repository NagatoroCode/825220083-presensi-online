import 'package:aplikasiabsensi/model/roleUser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoleDatabase {
  final database = Supabase.instance.client.from('roleUser');

  // tambah nama role
  Future<void> createRole(userRole newRole) async {
    await database.insert(newRole.toMap()).select();
  }

  // Baca nama role
  final roleStream = Supabase.instance.client
      .from('roleUser')
      .stream(primaryKey: ["roleID"])
      .map((data) => data.map((roleMap) => userRole.fromMap(roleMap)).toList());

  Future<List<userRole>> getAllRole() async {
    final response = await Supabase.instance.client.from('roleUser').select();

    return (response as List)
        .map((roleMap) => userRole.fromMap(roleMap))
        .toList();
  }

  // Update nama role
  Future<void> updateRole(userRole updatedRole) async {
    await database
        .update(updatedRole.toMap())
        .eq('roleID', updatedRole.roleID!);
  }

  Future<userRole?> getRoleByName(String namaRole) async {
    final result = await Supabase.instance.client
        .from('roleUser')
        .select()
        .eq('namaRole', namaRole)
        .maybeSingle();

    if (result == null) return null;
    return userRole.fromMap(result);
  }

  Future<void> deleteRole(String roleID) async {
    await database.delete().eq('roleID', roleID);
  }
}
