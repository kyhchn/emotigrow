import 'package:firebase_database/firebase_database.dart';

/// Thin wrapper around the Firebase Realtime Database.
///
/// Used in addition to Supabase for realtime data (chat, presence, live
/// updates, etc.).
class FirebaseRtdbService {
  FirebaseRtdbService._();
  static final FirebaseRtdbService instance = FirebaseRtdbService._();

  DatabaseReference get _root => FirebaseDatabase.instance.ref();

  /// Returns a reference for an optional sub-path under the database root.
  DatabaseReference ref([String? path]) {
    if (path == null) return _root;
    return _root.child(path);
  }

  /// Stream that emits the current value every time `path` changes.
  Stream<DatabaseEvent> onValue([String? path]) => ref(path).onValue;

  /// Convenience write helper.
  Future<void> write(String path, Object? value) => ref(path).set(value);
}