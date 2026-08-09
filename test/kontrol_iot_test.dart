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

      // Key sections present.
      expect(find.text('Pakcoy'), findsOneWidget);
      expect(find.text('ACHIEVEMENTS'), findsOneWidget);
      expect(find.text('17 Hari lagi panen'), findsOneWidget);
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

      expect(find.text('Pakcoy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dropdown opens from the container and menu matches value UI',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: KontrolIotPage()));
      await tester.pump();

      // Default plant selected.
      expect(find.text('Pakcoy'), findsOneWidget);
      expect(find.text('80/100'), findsOneWidget);

      // The WHOLE container is the trigger: tapping the plant name (not the
      // chevron) opens the list.
      await tester.tap(find.text('Pakcoy'));
      await tester.pumpAndSettle();

      // The menu items reuse the selected-value UI -> status pills are shown.
      expect(find.text('Sehat'), findsWidgets);
      expect(find.text('Perhatian'), findsOneWidget);
      expect(find.text('Darurat'), findsOneWidget);

      // Pick another plant from the menu.
      await tester.tap(find.text('Selada Keriting').last);
      await tester.pumpAndSettle();

      // Selection applied: name + status pill + health value all updated.
      expect(find.text('Selada Keriting'), findsOneWidget);
      expect(find.text('Perhatian'), findsOneWidget);
      expect(find.text('55/100'), findsOneWidget);
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
      expect(find.text('Pakcoy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
