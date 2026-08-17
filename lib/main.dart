import 'package:cakmoji_flutter/screens/homepage_generated.dart';
import 'package:cakmoji_flutter/screens/login_generated.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_config.dart';
import 'core/app_theme.dart';
import 'screens/splash_screen.dart';
import 'widgets/mobile_only_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // const firebaseConfig = {
    //   apiKey: "AIzaSyCftb8Ilqxgdi-3WDIOE2wpAVnIkSlcDhY",
    //   authDomain: "cakmoji-bb2c8.firebaseapp.com",
    //   databaseURL:
    //       "https://cakmoji-bb2c8-default-rtdb.asia-southeast1.firebasedatabase.app",
    //   projectId: "cakmoji-bb2c8",
    //   storageBucket: "cakmoji-bb2c8.firebasestorage.app",
    //   messagingSenderId: "833718491791",
    //   appId: "1:833718491791:web:8222a01e31e439a834eefa",
    // };
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCftb8Ilqxgdi-3WDIOE2wpAVnIkSlcDhY',
        authDomain: 'cakmoji-bb2c8.firebaseapp.com',
        databaseURL:
            'https://cakmoji-bb2c8-default-rtdb.asia-southeast1.firebasedatabase.app',
        projectId: 'cakmoji-bb2c8',
        storageBucket: 'cakmoji-bb2c8.firebasestorage.app',
        messagingSenderId: '833718491791',
        appId: '1:833718491791:web:8222a01e31e439a834eefa',
      ),
    );
  } else {
    // Native: config comes from the platform config files
    // (GoogleService-Info.plist / google-services.json).
    await Firebase.initializeApp();
  }

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
      title: 'Emotigrow',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Web is mobile-only: desktop-sized screens get a "use a phone" screen
      // instead of the mobile UI.
      builder: (context, child) =>
          MobileOnlyGate(child: child ?? const SizedBox.shrink()),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginGenerated(),
        '/home': (_) => const HomepageGenerated(),
      },
    );
  }
}
