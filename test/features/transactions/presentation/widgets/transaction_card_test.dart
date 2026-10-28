import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/extensions/color_extensions.dart';
import 'package:trackpense/core/theme/app_colors.dart';
import 'package:trackpense/features/transactions/presentation/widgets/transaction_card.dart';

Future<void> _pumpCard(
  WidgetTester tester, {
  bool isExpense = true,
  String? notes,
  VoidCallback? onTap,
  double textScale = 1,
}) {
  return tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: TransactionCard(
          date: DateTime(2026, 10, 20, 9, 30),
          description: 'Groceries',
          amount: 1234.5,
          isExpense: isExpense,
          notes: notes,
          onTap: onTap ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the date, time, description and formatted amount', (tester) async {
    await _pumpCard(tester);

    expect(find.text('Tue'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('October'), findsOneWidget);
    expect(find.text('09:30 AM'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('1,234.50'), findsOneWidget);
  });

  testWidgets('shows single-line notes as they are', (tester) async {
    await _pumpCard(tester, notes: 'Weekly shop');

    expect(find.text('Weekly shop'), findsOneWidget);
  });

  testWidgets('shows only the first line of multi-line notes', (tester) async {
    await _pumpCard(tester, notes: 'First line\nSecond line');

    expect(find.text('First line .....'), findsOneWidget);
    expect(find.textContaining('Second line'), findsNothing);
  });

  testWidgets('shows no notes line when there are no notes', (tester) async {
    await _pumpCard(tester);

    // Weekday, day, month, time, description, amount.
    expect(find.byType(Text), findsNWidgets(6));
  });

  testWidgets('tints expenses red and income green', (tester) async {
    await _pumpCard(tester);
    expect(tester.widget<Card>(find.byType(Card)).color, isSameColorAs(AppColors.expense.lighten(0.8)));

    await _pumpCard(tester, isExpense: false);
    expect(tester.widget<Card>(find.byType(Card)).color, isSameColorAs(AppColors.income.lighten(0.8)));
  });

  // Regression: the date column was a fixed 55x55 box and overflowed when the
  // system text size was increased (an accessibility setting).
  testWidgets('lays out without overflow at a large system text size', (tester) async {
    await _pumpCard(tester, notes: 'Weekly shop', textScale: 2);

    expect(tester.takeException(), isNull);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var taps = 0;
    await _pumpCard(tester, onTap: () => taps++);

    await tester.tap(find.byType(TransactionCard));

    expect(taps, 1);
  });
}
