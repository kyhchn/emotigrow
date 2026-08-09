import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin, app-wide wrapper around the Supabase client.
///
/// Used for authentication and reading/writing the user's profile info.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // -- Auth -------------------------------------------------------------------

  User? get currentUser => _client.auth.currentUser;

  /// Stream that emits whenever the auth state changes (sign in / sign out).
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

  /// Allowed values for the user's `type`.
  static const List<String> userTypes = ['petani', 'pelanggan'];

  /// Creates the auth user + profile row.
  ///
  /// Returns `true` when the user is usable immediately (e.g. email
  /// confirmation is disabled), or `false` when the user must first confirm
  /// their email before signing in.
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) async {
    // Create the auth user.
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      // Happens when "Confirm email" is enabled: no session yet, so the user
      // must verify their email before they can sign in / get a profile row.
      return false;
    }

    // Store the extra profile info. Requires the `profiles` table and the
    // insert policy described in the README.
    await _client.from('profiles').insert({
      'id': user.id,
      'email': email.trim().toLowerCase(),
      'name': name.trim(),
      'type': userType, // 'petani' | 'pelanggan'
    });
    return true;
  }

  Future<void> signOut() => _client.auth.signOut();

  // -- User info ---------------------------------------------------------------

  /// Fetches the signed-in user's profile from the `profiles` table.
  ///
  /// Assumes a table named `profiles` with a primary key / id that matches the
  /// auth user id (`auth.users.id`). Adjust the table name to match your schema.
  Future<Map<String, dynamic>?> fetchProfile() async {
    final user = currentUser;
    if (user == null) return null;

    return _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) return;

    await _client.from('profiles').update(data).eq('id', user.id);
  }
}