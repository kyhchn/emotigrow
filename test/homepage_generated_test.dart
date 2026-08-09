import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cakmoji_flutter/screens/home/kebunku_page.dart';
import 'package:cakmoji_flutter/screens/homepage_generated.dart';

void main() {
  // Responsive regression tests for the refactored homepage: it must render
  // without overflow at a small phone and a tablet, with the bottom nav intact.
  testWidgets('Homepage renders on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HomepageGenerated()));
    await tester.pump();

    // Header greeting.
    expect(find.text('Hello!'), findsOneWidget);
    // Content sections.
    expect(find.text('Kontrol IoT'), findsOneWidget);
    expect(find.text('AI Diagnosis'), findsOneWidget);
    expect(find.text('Konsultasi Ahli'), findsOneWidget);
    expect(find.text('Kategori terbaik'), findsOneWidget);
    // WhatsApp/status SVG logos render on the page (header, cards, FAB).
    expect(find.byType(SvgPicture), findsWidgets);
    // Bottom navigation destinations.
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Kebunku'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Homepage renders on a tablet', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HomepageGenerated()));
    await tester.pump();

    expect(find.text('Kategori terbaik'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing); // custom nav used
    expect(find.text('Kebunku'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Tapping the WhatsApp icon fails gracefully in tests', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomepageGenerated()));
    await tester.pump();

    // Tap the "Konsultasi Ahli" card — its tap handler opens WhatsApp. In the
    // test environment there is no url_launcher plugin, so this exercises the
    // graceful error path rather than throwing.
    await tester.ensureVisible(find.text('Konsultasi Ahli'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Konsultasi Ahli'));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('"Kebunku" nav tab opens the full KebunkuPage', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HomepageGenerated()));
    await tester.pump();

    // Home tab first.
    expect(find.byType(PlantCard), findsNothing);

    // Switch to the Kebunku tab.
    await tester.tap(find.text('Kebunku'));
    await tester.pumpAndSettle();

    // The full page renders with the filter bar + all plants.
    expect(find.text('Kategori terbaik'), findsNothing);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.byType(PlantCard), findsNWidgets(3));

    // No unbounded-height / layout exceptions.
    expect(tester.takeException(), isNull);
  });
}
