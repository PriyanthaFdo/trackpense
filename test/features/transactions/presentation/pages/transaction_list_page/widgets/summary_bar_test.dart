import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trackpense/core/extensions/color_extensions.dart';
import 'package:trackpense/core/theme/app_colors.dart';
import 'package:trackpense/features/transactions/presentation/pages/transaction_list_page/widgets/summary_bar.dart';

Future<void> _pumpBar(
  WidgetTester tester, {
  double income = 0,
  double expense = 0,
  double textScale = 1,
}) {
  return tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: SummaryBar(income: income, expense: expense),
      ),
    ),
  );
}

/// Finds a painted segment of the proximity bar by its color. Container builds
/// an internal DecoratedBox with the same decoration, so matching DecoratedBox
/// finds each painted region exactly once.
Finder _barSegment(Color color) {
  return find.descendant(
    of: find.byType(SummaryBar),
    matching: find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration is BoxDecoration && (widget.decoration as BoxDecoration).color == color,
    ),
  );
}

void main() {
  testWidgets('shows expenses, income and balance with formatted amounts', (tester) async {
    await _pumpBar(tester, income: 5000, expense: 1234.5);

    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('1,234.50'), findsOneWidget);
    expect(find.text('5,000.00'), findsOneWidget);
    expect(find.text('3,765.50'), findsOneWidget);
  });

  testWidgets('colors the amounts by type and the balance by sign', (tester) async {
    await _pumpBar(tester, income: 100, expense: 40);

    Text amountOf(String label) {
      final column = find.ancestor(of: find.text(label), matching: find.byType(Column)).first;
      return tester.widgetList<Text>(find.descendant(of: column, matching: find.byType(Text))).firstWhere((t) => t.data != label);
    }

    expect(amountOf('Expenses').style?.color, AppColors.expense);
    expect(amountOf('Income').style?.color, AppColors.income);

    final balance = tester.widget<Text>(find.text('60.00'));
    expect(balance.style?.color, AppColors.income);
    expect(balance.style?.fontWeight, FontWeight.bold);
  });

  testWidgets('shows a negative balance in the expense color', (tester) async {
    await _pumpBar(tester, income: 50, expense: 100);

    final balance = tester.widget<Text>(find.text('-50.00'));
    expect(balance.style?.color, AppColors.expense);
  });

  testWidgets('shows a neutral bar and zero balance when there is no activity', (tester) async {
    await _pumpBar(tester);

    expect(find.text('0.00'), findsNWidgets(3));
    expect(_barSegment(AppColors.grey500), findsOneWidget);
    expect(_barSegment(AppColors.income), findsNothing);
    expect(_barSegment(AppColors.expense), findsNothing);
  });

  testWidgets('fills the bar with the dominant side and caps it with the minority share', (tester) async {
    await _pumpBar(tester, income: 40, expense: 100);

    // Expenses dominate, so the track is expense-tinted and income is the cap.
    expect(_barSegment(AppColors.expense.lighten(0.8)), findsOneWidget);
    expect(_barSegment(AppColors.income), findsOneWidget);

    final barSize = tester.getSize(_barSegment(AppColors.expense.lighten(0.8)));
    final foregroundSize = tester.getSize(_barSegment(AppColors.income));
    expect(foregroundSize.height, barSize.height);
    expect(foregroundSize.width, closeTo(barSize.width * 0.4, 1));
  });

  testWidgets('draws the cap on the opposite side when income dominates', (tester) async {
    await _pumpBar(tester, income: 100, expense: 40);

    expect(_barSegment(AppColors.income.lighten(0.8)), findsOneWidget);
    expect(_barSegment(AppColors.expense), findsOneWidget);
  });

  testWidgets('lays out without overflow at a large system text size', (tester) async {
    await _pumpBar(tester, income: 5000, expense: 1234.5, textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
