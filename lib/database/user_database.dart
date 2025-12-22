import 'package:aplikasiabsensi/model/roleUser.dart';
import 'package:aplikasiabsensi/model/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDatabase {
  final database = Supabase.instance.client.from('User');

  // Create New User
  Future createUser(newUser) async {
    await database.insert(newUser.toMap());
  }

  Future<List<userRole>> fetchRoleList() async {
    final response = await Supabase.instance.client
        .from('roleUser')
        .select('roleID, namaRole');

    return response.map<userRole>((item) => userRole.fromMap(item)).toList();
  }

  // Read Data User
  final stream = Supabase.instance.client
      .from('User')
      .stream(primaryKey: ["userID"])
      .map((data) => data.map((UserMap) => AppUser.fromMap(UserMap)).toList());

  Future<AppUser?> getUserByID(String userID) async {
    final response = await Supabase.instance.client
        .from('User')
        .select()
        .eq('userID', userID)
        .maybeSingle();

    if (response != null) {
      return AppUser.fromMap(response);
    }
    return null;
  }

  Future<AppUser?> getUserByKaryawanID(String karyawanID) async {
    final response = await Supabase.instance.client
        .from('User')
        .select()
        .eq('karyawanID', karyawanID)
        .maybeSingle();

    if (response != null) {
      return AppUser.fromMap(response);
    }
    return null;
  }

  Future<void> updateUser(AppUser updateUser) async {
    await database.update(updateUser.toMap()).eq('userID', updateUser.userID!);
  }
}
