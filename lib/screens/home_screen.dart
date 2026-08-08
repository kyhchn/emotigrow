import 'package:flutter/material.dart';

import '../services/firebase_rtdb_service.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';

/// Post-login home screen.
///
/// Demonstrates reading Supabase user info and writing/reading a value from
/// the Firebase Realtime Database.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _profileSummary;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = SupabaseService.instance.currentUser;
    final profile = await SupabaseService.instance.fetchProfile();
    final String name = (profile?['name'] as String?) ?? '(no name)';
    final String type = (profile?['type'] as String?) ?? '-';
    setState(() {
      _profileSummary = user == null
          ? 'Not signed in'
          : 'Signed in as ${user.email}\n'
              'Name: $name\n'
              'Type: $type';
    });
  }

  /// Writes a timestamp so you can watch a realtime update in the Firebase
  /// Realtime Database console under `/ping`.
  Future<void> _pingRealtimeDb() async {
    await FirebaseRtdbService.instance.write(
      'ping',
      {'at': DateTime.now().toIso8601String()},
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ping sent to Realtime DB /ping')),
      );
    }
  }

  Future<void> _signOut() async {
    await SupabaseService.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_emotions, size: 80),
              const SizedBox(height: 16),
              Text(
                _profileSummary ?? 'Loading…',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _pingRealtimeDb,
                icon: const Icon(Icons.bolt),
                label: const Text('Ping Realtime DB'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}