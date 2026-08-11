import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cakmoji_flutter/screens/kontrol_iot/kontrol_iot_page.dart';
import 'package:cakmoji_flutter/screens/kontrol_iot/kontrol_iot_transition.dart';

void main() {
  group('KontrolIotPage', () {
    testWidgets('renders responsively without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: KontrolIotPage()));
      await tester.pump();

      // First plant (Selada Keriting) is the default selection. With no live
      // Firebase data available (test env) it falls back to demo values.
      expect(find.text('Selada Keriting'), findsOneWidget);
      expect(find.text('100/100'), findsOneWidget);

      // Key sections present.
      expect(find.text('ACHIEVEMENTS'), findsOneWidget);
      expect(find.text('JUAL'), findsOneWidget);
      expect(find.text('Lingkungan'), findsOneWidget);
      expect(find.text('SUHU'), findsWidgets);
      expect(find.text('Aktivitas Terakhir'), findsOneWidget);
      expect(find.text('Scan Kesehatan'), findsOneWidget);
      expect(find.text('Control Status'), findsOneWidget);
      expect(find.text('Flex Your Plant'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on a small phone as well', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: KontrolIotPage()));
      await tester.pump();

      expect(find.text('Selada Keriting'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dropdown switches between the three plants', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: KontrolIotPage()));
      await tester.pump();

      // Default plant -> sehat, 100/100.
      expect(find.text('Selada Keriting'), findsOneWidget);
      expect(find.text('100/100'), findsOneWidget);

      // The whole container is the trigger: tapping the plant name opens it.
      await tester.tap(find.text('Selada Keriting'));
      await tester.pumpAndSettle();

      // The menu lists the other gardens too.
      expect(find.text('Pakcoy'), findsWidgets);
      expect(find.text('Cabai Rawit'), findsOneWidget);

      // Pick Pakcoy -> perhatian, 55/100.
      await tester.tap(find.text('Pakcoy').last);
      await tester.pumpAndSettle();
      expect(find.text('55/100'), findsOneWidget);
      expect(find.text('17 Hari lagi panen'), findsOneWidget);

      // Pick Cabai Rawit -> darurat, 30/100.
      await tester.tap(find.text('Pakcoy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cabai Rawit').last);
      await tester.pumpAndSettle();
      expect(find.text('30/100'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('KontrolIotTransition', () {
    testWidgets('holds ~1 second then swipes to KontrolIotPage', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: KontrolIotTransition()));

      // Transition page first.
      expect(find.text('Menyiapkan kontrol…'), findsOneWidget);
      expect(find.byType(KontrolIotPage), findsNothing);

      // Advance past the 1s hold; route transition is starting/active.
      await tester.pump(const Duration(milliseconds: 1100));

      // Complete the swipe transition.
      await tester.pump(const Duration(milliseconds: 600));

      // The next screen is now on top.
      expect(find.byType(KontrolIotPage), findsOneWidget);
      expect(find.text('Selada Keriting'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
