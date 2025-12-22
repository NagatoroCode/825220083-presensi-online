import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    await _supabase.auth.signOut();
    return response;
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<String?> getUserRole() async {
    final email = _supabase.auth.currentUser?.email;
    if (email == null) return null;

    try {
      final userResponse = await _supabase
          .from('User')
          .select('roleID')
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) {
        print('⚠️ User tidak ditemukan');
        return null;
      }

      final roleId = userResponse['roleID'];
      if (roleId == null) {
        print('⚠️ RoleID tidak ditemukan');
        return null;
      }

      // 🔹 Ambil namaRole dari tabel roleUser berdasarkan roleID
      final roleResponse = await _supabase
          .from('roleUser')
          .select('namaRole')
          .eq('roleID', roleId)
          .maybeSingle();

      final roleName = roleResponse?['namaRole'];
      print('✅ Role user: $roleName');

      return roleName;
    } catch (e) {
      print('❌ Error fetching role: $e');
      return null;
    }
  }

  // Get User Email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
