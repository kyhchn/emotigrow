import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cakmoji_flutter/screens/ai_diagnosis/ai_diagnosis_screen.dart';
import 'package:cakmoji_flutter/screens/ai_diagnosis/ai_diagnosis_transition.dart';

void main() {
  group('AiDiagnosisScreen', () {
    testWidgets('renders the first result without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: AiDiagnosisScreen()));
      await tester.pump();

      // First result (Selada Sehat) is the default. With no live Firebase data
      // available (test env) it falls back to demo values. The name appears in
      // both the dropdown trigger and the status header.
      expect(find.text('Selada Sehat'), findsWidgets);
      expect(find.text('96% Keyakinan'), findsOneWidget);

      // Normal mood → "Saran Ke Depan" is shown.
      expect(find.text('SARAN KE DEPAN'), findsOneWidget);
      expect(find.text('FOTO ANDA'), findsOneWidget);
      expect(find.text('REFERENSI'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('dropdown switches to a sad result', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: AiDiagnosisScreen()));
      await tester.pump();

      // Open the dropdown (whole container is the trigger). The trigger is the
      // first occurrence of the name in the tree.
      await tester.tap(find.text('Selada Sehat').first);
      await tester.pumpAndSettle();

      // The menu lists the other results too.
      expect(find.text('Pakcoy Terinfeksi'), findsWidgets);
      expect(find.text('Tomat Sehat'), findsOneWidget);

      // Pick the infected one → sad mood shows symptoms + impact.
      await tester.tap(find.text('Pakcoy Terinfeksi').last);
      await tester.pumpAndSettle();

      expect(find.text('GEJALA UTAMA'), findsOneWidget);
      expect(find.text('DAMPAK UTAMA'), findsOneWidget);
      expect(find.text('78% Keyakinan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AiDiagnosisTransition', () {
    testWidgets('holds ~1 second then swipes to AiDiagnosisScreen', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AiDiagnosisTransition()));

      // Transition page first.
      expect(find.text('Menyiapkan AI Diagnosis…'), findsOneWidget);
      expect(find.byType(AiDiagnosisScreen), findsNothing);

      // Advance past the 1s hold; route transition is starting/active.
      await tester.pump(const Duration(milliseconds: 1100));

      // Complete the swipe transition.
      await tester.pump(const Duration(milliseconds: 600));

      // The next screen is now on top.
      expect(find.byType(AiDiagnosisScreen), findsOneWidget);
      expect(find.text('Selada Sehat'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
