import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_config.dart';
import 'core/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Firebase (Realtime Database) -----------------------------------------
  // Requires your platform config files to be present:
  //   iOS/macOS : GoogleService-Info.plist
  //   Android   : google-services.json
  //   Web       : <script> tags / options below
  await Firebase.initializeApp();

  // --- Supabase (Auth + user info) -------------------------------------------
  // Fill in your credentials in lib/core/app_config.dart
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );

  runApp(const CakmojiApp());
}

class CakmojiApp extends StatelessWidget {
  const CakmojiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cakmoji',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
