// Nadodi v2.0 widget smoke tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nadodi/app.dart';

void main() {
  testWidgets('App launches, navigates to home and shows place cards',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const NadodiApp());
    await tester.pump();

    // Splash branding is visible.
    expect(find.text('Nadodi'), findsOneWidget);
    expect(find.text('Explore Kerala · Without Fear'), findsOneWidget);

    // Let the splash finish (2.6s) and settle navigation.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Home screen shows core redesigned UI.
    expect(find.text('Explore Districts'), findsOneWidget);
    expect(find.text('Curated for you'), findsOneWidget);
    expect(find.text('Local Experiences'), findsOneWidget);
    expect(find.text('Popular Places'), findsOneWidget);

    // Flush the async dataset load (rootBundle + provider rebuilds).
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
    });
    await tester.pumpAndSettle();

    // Known places from the bundled dataset render.
    expect(find.text('Munnar'), findsWidgets);
    expect(find.text('Fort Kochi'), findsWidgets);
  });
}
