// Tests the save-place toggle snackbar message on the home screen.
//
// Regression test: after toggleSavePlace, the snackbar used to read the stale
// `place.isSaved` from the passed-in object (toggleSavePlace replaces it with
// a new copyWith instance), producing an inverted message.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nadodi/providers/places_provider.dart';
import 'package:nadodi/screens/home_screen.dart';
import 'package:nadodi/theme/app_theme.dart';

void main() {
  testWidgets('save toggle shows correct snackbar message', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = PlacesProvider();
    await provider.loadPlaces();

    await tester.pumpWidget(
      ChangeNotifierProvider<PlacesProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The save button is a heart outline before saving. Bring the first card's
    // overlay button into view so it is hittable.
    final firstHeart = find.byIcon(Icons.favorite_border).first;
    await tester.ensureVisible(firstHeart);
    await tester.pumpAndSettle();
    expect(firstHeart, findsOneWidget);

    // Tap save on the first place -> it is now saved.
    await tester.tap(firstHeart);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Added to saved places'), findsOneWidget);
    expect(provider.isPlaceSaved(provider.filteredPlaces.first.id), isTrue);

    // The icon flips to a filled heart.
    expect(find.byIcon(Icons.favorite), findsWidgets);

    // Let the first snackbar finish so it does not obscure the next tap.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Tap again -> it is now unsaved.
    await tester.tap(find.byIcon(Icons.favorite).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Removed from saved places'), findsOneWidget);
    expect(provider.isPlaceSaved(provider.filteredPlaces.first.id), isFalse);
  });
}
