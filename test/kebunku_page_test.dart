import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cakmoji_flutter/screens/home/kebunku_page.dart';

BoxDecoration _cardDecoration(WidgetTester tester, {int index = 0}) {
  final container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(PlantCard),
          matching: find.byType(Container),
        )
        .at(index),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  group('PlantStatus styling', () {
    test('card background is white for sehat/perhatian, red-tinted for darurat',
        () {
      expect(PlantStatus.sehat.cardBackground, Colors.white);
      expect(PlantStatus.perhatian.cardBackground, Colors.white);
      expect(PlantStatus.darurat.cardBackground, isNot(Colors.white));
    });
  });

  group('KebunkuPage', () {
    Widget wrap() => const MaterialApp(
          home: Scaffold(body: KebunkuPage()),
        );

    testWidgets('starts on Semua and shows all plants', (tester) async {
      await tester.pumpWidget(wrap());

      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Sehat'), findsOneWidget);
      expect(find.text('Perhatian'), findsOneWidget);
      expect(find.text('Darurat'), findsOneWidget);
      expect(find.byType(PlantCard), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('filters to Darurat only', (tester) async {
      await tester.pumpWidget(wrap());

      await tester.tap(find.text('Darurat'));
      await tester.pumpAndSettle();

      expect(find.byType(PlantCard), findsOneWidget);
      expect(find.text('Cabai Rawit'), findsOneWidget);
      // Darurat card gets a red border + red-tinted background.
      final decoration = _cardDecoration(tester);
      expect(decoration.color, PlantStatus.darurat.cardBackground);
      expect((decoration.border! as Border).top.color, PlantStatus.darurat.color);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Semua" restores every plant', (tester) async {
      await tester.pumpWidget(wrap());

      await tester.tap(find.text('Perhatian'));
      await tester.pumpAndSettle();
      expect(find.byType(PlantCard), findsOneWidget);
      expect(find.text('Tomat Cherry'), findsOneWidget);

      await tester.tap(find.text('Semua'));
      await tester.pumpAndSettle();
      expect(find.byType(PlantCard), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  });
}