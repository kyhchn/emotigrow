import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cakmoji_flutter/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen renders the splash image', (tester) async {
    // Render just the splash screen (it does not require Supabase/Firebase to
    // be initialized until it navigates away, which happens after its timer).
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    // The splash image should be present.
    expect(find.byType(Image), findsOneWidget);

    // And the loading indicator is shown.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
