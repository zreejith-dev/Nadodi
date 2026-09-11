import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nadodi/providers/expense_provider.dart';
import 'package:nadodi/screens/expense_screen.dart';
import 'package:nadodi/theme/app_theme.dart';

void main() {
  testWidgets('ExpenseScreen renders totals and categories without crashing',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = ExpenseProvider();
    await provider.load();
    await provider.addExpense(
      title: 'Room',
      category: 'stay',
      amount: 1200,
      date: DateTime(2026, 7, 15),
    );
    await provider.addExpense(
      title: 'Lunch',
      category: 'food',
      amount: 300,
      date: DateTime(2026, 7, 15),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<ExpenseProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light(),          home: const ExpenseScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trip Expense Calculator'), findsOneWidget);
    expect(find.text('Trip Total'), findsOneWidget);
    expect(find.text('₹1,500.00'), findsOneWidget);
    expect(find.text('₹1,500.00 per person (1 traveler)'), findsOneWidget);
    expect(find.text('Spending by category'), findsOneWidget);

    // Expense tiles live in a lazily-built ListView; scroll down to reveal them.
    await tester.scrollUntilVisible(find.text('Room'), 200);
    expect(find.text('Room'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
  });

  testWidgets('editing an expense keeps decimal amount precision', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = ExpenseProvider();
    await provider.load();
    await provider.addExpense(
      title: 'Houseboat',
      category: 'activities',
      amount: 120.5,
      date: DateTime(2026, 7, 15),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<ExpenseProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ExpenseScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open the edit form for the existing expense.
    await tester.scrollUntilVisible(find.byIcon(Icons.edit_outlined), 200);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // The amount field must show the full decimal value, not a truncation.
    final amountField = find.widgetWithText(TextField, 'Amount (₹)');
    final editable = tester.widget<TextField>(amountField);
    expect(editable.controller!.text, '120.5');
  });
}
