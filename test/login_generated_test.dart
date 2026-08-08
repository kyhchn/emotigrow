import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cakmoji_flutter/screens/login_generated.dart';

void main() {
  // Regression test: the original Figma-generated markup threw
  // "RenderBox was not laid out" / overflow errors. The rebuilt screen must
  // render cleanly at both a tablet size and a small phone size.
  testWidgets('LoginGenerated renders without overflow on a large screen',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: LoginGenerated()));

    expect(find.byType(LoginGenerated), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('LoginGenerated renders without overflow on a small phone',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: LoginGenerated()));

    // Interactive widgets that should be present.
    expect(find.text('Email atau Nomor HP'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Petani'), findsOneWidget);
    expect(find.text('Pengguna'), findsOneWidget);
    // No overflow / layout exceptions.
    expect(tester.takeException(), isNull);
  });
}
