import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cakmoji_flutter/screens/home/profile_page.dart';

void main() {
  // In widget tests the Supabase client is never initialized, so the page must
  // degrade gracefully to its fallback values instead of throwing.

  testWidgets('ProfilePage renders fallback info on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfilePage())),
    );
    await tester.pump();

    // Fallback profile info.
    expect(find.text('Pengguna Cakmoji'), findsOneWidget);
    expect(find.text('Pengguna'), findsOneWidget); // default badge label
    // Menu items.
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Pengaturan Aplikasi'), findsOneWidget);
    expect(find.text('Bantuan & FAQ'), findsOneWidget);
    // Logout button + version text.
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Versi Aplikasi 1.0.4 (Build 202)'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Logout asks for confirmation and cancels on "Batal"', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfilePage())),
    );
    await tester.pump();

    // The content column scrolls, so bring the button into view first.
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // Confirmation dialog is shown.
    expect(find.text('Keluar dari Cakmoji?'), findsOneWidget);
    expect(find.text('Anda akan kembali ke halaman masuk.'), findsOneWidget);

    // Cancel leaves the profile page untouched.
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.text('Keluar dari Cakmoji?'), findsNothing);
    expect(find.text('Logout'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Confirming logout shows an error snackbar when sign out fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfilePage())),
    );
    await tester.pump();

    // The content column scrolls, so bring the button into view first.
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // Confirm the dialog — the Supabase call will fail in the test env and the
    // error is surfaced through a SnackBar instead of crashing.
    await tester.tap(find.text('Keluar'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Gagal keluar. Silakan coba lagi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
