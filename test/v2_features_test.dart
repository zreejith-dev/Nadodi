import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nadodi/models/expense_item.dart';
import 'package:nadodi/models/hidden_spot_model.dart';
import 'package:nadodi/models/hotel_model.dart';
import 'package:nadodi/models/place_model.dart';
import 'package:nadodi/models/restaurant_model.dart';
import 'package:nadodi/providers/expense_provider.dart';
import 'package:nadodi/services/geo_service.dart';

void main() {
  group('GeoService.distanceKm', () {
    test('same point is 0 km', () {
      expect(GeoService.distanceKm(9.98, 76.28, 9.98, 76.28), closeTo(0, 0.0001));
    });

    test('one degree of latitude is ~111.2 km', () {
      expect(GeoService.distanceKm(0, 0, 1, 0), closeTo(111.19, 0.5));
    });

    test('is symmetric', () {
      final a = GeoService.distanceKm(9.98, 76.28, 10.5, 76.9);
      final b = GeoService.distanceKm(10.5, 76.9, 9.98, 76.28);
      expect(a, closeTo(b, 0.0001));
    });

    test('Kochi to Munnar is roughly 80-90 km', () {
      // Kochi ~ (9.9816, 76.2999), Munnar ~ (10.0889, 77.0595)
      final d = GeoService.distanceKm(9.9816, 76.2999, 10.0889, 77.0595);
      expect(d, greaterThan(80));
      expect(d, lessThan(90));
    });

    test('antipodal points are ~20015 km (half earth circumference)', () {
      final d = GeoService.distanceKm(0, 0, 0, 180);
      expect(d, closeTo(20015, 50));
    });
  });

  group('GeoService.nearby', () {
    final places = [
      TouristPlace(id: 1, name: 'Near Place', category: 'hill', district: 'Idukki', rating: 4.5, latitude: 10.0, longitude: 76.3),
      TouristPlace(id: 2, name: 'Far Place', category: 'beach', district: 'Kochi', rating: 4.0, latitude: 12.0, longitude: 76.3),
      TouristPlace(id: 3, name: 'No Coords', category: 'hill', district: 'Munnar', rating: 3.5),
    ];
    final hotels = [
      Hotel(id: 1, name: 'Near Hotel', type: 'Hotel', district: 'Idukki', priceRange: 'Luxury', rating: 4.2, latitude: 10.01, longitude: 76.31),
    ];
    final restaurants = [
      Restaurant(id: 1, name: 'Far Restaurant', cuisine: 'Kerala', district: 'Kochi', rating: 4.1, latitude: 11.5, longitude: 76.3),
    ];
    final hidden = [
      HiddenSpot(id: 1, name: 'Near Waterfall', type: 'Secret Waterfall', district: 'Idukki', difficulty: 'Easy', rating: 4.8, latitude: 10.02, longitude: 76.28),
    ];

    test('returns only points within radius, sorted by distance', () {
      final result = GeoService.nearby(
        lat: 10.0,
        lon: 76.3,
        radiusKm: 10,
        places: places,
        hotels: hotels,
        restaurants: restaurants,
        hiddenSpots: hidden,
      );

      // The nearby waterfall, hotel and place should be included; the far
      // restaurant (11.5 lat ~ 167 km) and the null-coordinate place excluded.
      expect(result.length, 3);
      expect(result.map((p) => p.name), containsAll(['Near Place', 'Near Hotel', 'Near Waterfall']));
      expect(result.map((p) => p.name), isNot(contains('Far Restaurant')));
      expect(result.map((p) => p.name), isNot(contains('No Coords')));

      // Sorted ascending by distanceKm.
      for (var i = 1; i < result.length; i++) {
        expect(result[i].distanceKm, greaterThanOrEqualTo(result[i - 1].distanceKm));
      }
    });

    test('id prefix reflects the source type', () {
      final result = GeoService.nearby(
        lat: 10.0,
        lon: 76.3,
        radiusKm: 10,
        places: places,
        hotels: hotels,
        restaurants: restaurants,
        hiddenSpots: hidden,
      );
      final types = result.map((p) => p.type).toSet();
      expect(types, {'place', 'hotel', 'hidden'});
      expect(result.any((p) => p.id.startsWith('place-')), isTrue);
      expect(result.any((p) => p.id.startsWith('hotel-')), isTrue);
      expect(result.any((p) => p.id.startsWith('hidden-')), isTrue);
    });

    test('empty datasets produce empty result', () {
      final result = GeoService.nearby(
        lat: 10.0,
        lon: 76.3,
        radiusKm: 50,
        places: const [],
        hotels: const [],
        restaurants: const [],
        hiddenSpots: const [],
      );
      expect(result, isEmpty);
    });
  });

  group('GeoService.formatDistance', () {
    test('formats meters under 1 km', () {
      expect(GeoService.formatDistance(0.25), '250 m');
    });

    test('formats km with one decimal under 100', () {
      expect(GeoService.formatDistance(5.249), '5.2 km');
      expect(GeoService.formatDistance(1.0), '1.0 km');
      expect(GeoService.formatDistance(5.25), '5.3 km');
    });

    test('rounds km at 100 and above', () {
      expect(GeoService.formatDistance(123.7), '124 km');
    });
  });

  group('ExpenseItem', () {
    test('toJson/fromJson round-trips', () {
      final original = ExpenseItem(
        id: 'e1',
        title: 'Ferry',
        category: 'transport',
        amount: 120.5,
        date: DateTime(2026, 7, 15),
        placeId: 42,
      );
      final restored = ExpenseItem.fromJson(original.toJson());
      expect(restored.id, 'e1');
      expect(restored.title, 'Ferry');
      expect(restored.category, 'transport');
      expect(restored.amount, 120.5);
      expect(restored.date, DateTime(2026, 7, 15));
      expect(restored.placeId, 42);
    });

    test('fromJson fills safe defaults', () {
      final item = ExpenseItem.fromJson(<String, dynamic>{});
      expect(item.id, '');
      expect(item.title, 'Expense');
      expect(item.category, 'misc');
      expect(item.amount, 0);
      expect(item.placeId, isNull);
    });

    test('copyWith keeps id and placeId, overrides provided fields', () {
      final original = ExpenseItem(
        id: 'e1',
        title: 'Ferry',
        category: 'transport',
        amount: 120.5,
        date: DateTime(2026, 7, 15),
        placeId: 7,
      );
      final updated = original.copyWith(title: 'Boat', amount: 200);
      expect(updated.id, 'e1');
      expect(updated.title, 'Boat');
      expect(updated.amount, 200);
      expect(updated.category, 'transport');
      expect(updated.placeId, 7);
    });
  });

  group('ExpenseCategories', () {
    test('has the five expected categories', () {
      expect(ExpenseCategories.all, ['transport', 'stay', 'food', 'activities', 'misc']);
    });

    test('labels known categories and defaults misc', () {
      expect(ExpenseCategories.label('food'), 'Food');
      expect(ExpenseCategories.label('stay'), 'Stay');
      expect(ExpenseCategories.label('nonsense'), 'Misc');
    });
  });

  group('ExpenseProvider', () {
    late ExpenseProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = ExpenseProvider();
      await provider.load();
    });

    test('starts empty with one traveler', () {
      expect(provider.expenses, isEmpty);
      expect(provider.travelers, 1);
      expect(provider.total, 0);
      expect(provider.perPerson, 0);
    });

    test('addExpense updates totals and categories', () async {
      await provider.addExpense(title: 'Room', category: 'stay', amount: 1000, date: DateTime(2026, 7, 15));
      await provider.addExpense(title: 'Lunch', category: 'food', amount: 250, date: DateTime(2026, 7, 15));

      expect(provider.expenses.length, 2);
      expect(provider.total, 1250);
      expect(provider.perPerson, 1250);
      expect(provider.categoryTotal('stay'), 1000);
      expect(provider.categoryTotal('food'), 250);
      expect(provider.categoryTotal('transport'), 0);
      expect(provider.categoryTotals['stay'], 1000);
    });

    test('perPerson divides by traveler count', () async {
      await provider.addExpense(title: 'Room', category: 'stay', amount: 1200, date: DateTime(2026, 7, 15));
      await provider.setTravelers(3);
      expect(provider.perPerson, 400);
    });

    test('setTravelers clamps to minimum 1', () async {
      await provider.setTravelers(0);
      expect(provider.travelers, 1);
    });

    test('expensesOn filters by day and sorts newest first', () async {
      await provider.addExpense(title: 'A', category: 'food', amount: 10, date: DateTime(2026, 7, 15, 9));
      await provider.addExpense(title: 'B', category: 'food', amount: 20, date: DateTime(2026, 7, 16, 8));
      await provider.addExpense(title: 'C', category: 'food', amount: 30, date: DateTime(2026, 7, 15, 18));

      final day = provider.expensesOn(DateTime(2026, 7, 15));
      expect(day.map((e) => e.title), ['C', 'A']); // 18:00 before 09:00 => C first

      expect(provider.days, [DateTime(2026, 7, 15), DateTime(2026, 7, 16)]);
    });

    test('updateExpense modifies in place', () async {
      await provider.addExpense(title: 'Old', category: 'misc', amount: 10, date: DateTime(2026, 7, 15));
      final item = provider.expenses.first;

      await provider.updateExpense(
        item,
        title: 'New',
        category: 'transport',
        amount: 99,
        date: DateTime(2026, 7, 16),
      );

      final updated = provider.expenses.first;
      expect(updated.title, 'New');
      expect(updated.category, 'transport');
      expect(updated.amount, 99);
      expect(updated.date, DateTime(2026, 7, 16));
      expect(updated.id, item.id);
    });

    test('removeExpense removes by id', () async {
      await provider.addExpense(title: 'A', category: 'misc', amount: 10, date: DateTime(2026, 7, 15));
      await provider.addExpense(title: 'B', category: 'misc', amount: 20, date: DateTime(2026, 7, 15));
      final first = provider.expenses.first;

      await provider.removeExpense(first.id);
      expect(provider.expenses.length, 1);
      expect(provider.expenses.first.title, 'B');
    });

    test('clearAll removes everything but keeps travelers', () async {
      await provider.addExpense(title: 'A', category: 'misc', amount: 10, date: DateTime(2026, 7, 15));
      await provider.setTravelers(2);
      await provider.clearAll();

      expect(provider.expenses, isEmpty);
      expect(provider.total, 0);
      expect(provider.travelers, 2);
    });

    test('load restores persisted data', () async {
      await provider.addExpense(title: 'Room', category: 'stay', amount: 500, date: DateTime(2026, 7, 10));
      await provider.setTravelers(4);

      // A fresh provider on the same mock storage must see the data.
      final fresh = ExpenseProvider();
      await fresh.load();
      expect(fresh.expenses.length, 1);
      expect(fresh.expenses.first.title, 'Room');
      expect(fresh.travelers, 4);
    });

    test('load tolerates corrupt stored JSON', () async {
      SharedPreferences.setMockInitialValues({
        'nadodi_trip_expenses_v1': 'not-json{',
      });
      final fresh = ExpenseProvider();
      await fresh.load();
      expect(fresh.expenses, isEmpty);
      expect(fresh.loaded, isTrue);
    });

    test('persists a valid JSON blob to storage', () async {
      await provider.addExpense(title: 'Room', category: 'stay', amount: 500, date: DateTime(2026, 7, 10));
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('nadodi_trip_expenses_v1');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as List;
      expect(decoded, hasLength(1));
      expect(decoded.first['title'], 'Room');
    });
  });
}
