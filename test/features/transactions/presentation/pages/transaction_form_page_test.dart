import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpense/core/error/failures.dart';
import 'package:trackpense/features/transactions/domain/entities/transaction.dart';
import 'package:trackpense/features/transactions/presentation/pages/transaction_form_page.dart';

import '../../../../helpers/fake_transaction_repository.dart';
import '../../../../helpers/transaction_bloc_factory.dart';
import '../../../../helpers/transaction_fixtures.dart';

final _descriptionField = find.byType(TextFormField).at(0);
final _amountField = find.byType(TextFormField).at(1);
final _notesField = find.byType(TextFormField).at(2);

/// Opens the form on top of a placeholder home page, as the app's router does,
/// so the form's pop-after-save can be observed.
Future<FakeTransactionRepository> _pumpForm(
  WidgetTester tester, {
  Transaction? transaction,
  Failure? failure,
}) async {
  tester.view
    ..physicalSize = const Size(800, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = FakeTransactionRepository([?transaction])..failure = failure;
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Text('Home page')),
        routes: [
          GoRoute(
            path: 'form',
            builder: (context, state) => TransactionFormPage(transaction: state.extra as Transaction?),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  // The provider creates and closes the bloc. Closing it from addTearDown
  // instead would hang, because widget tests run in a fake-async zone.
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => buildTransactionBloc(repository),
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  unawaited(router.push('/form', extra: transaction));
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  group('create', () {
    testWidgets('opens empty with the Create title', (tester) async {
      await _pumpForm(tester);

      expect(find.text('Create Transaction'), findsOneWidget);
      expect(tester.widget<TextFormField>(_descriptionField).controller!.text, isEmpty);
      expect(tester.widget<TextFormField>(_amountField).controller!.text, isEmpty);
    });

    // Regression: the refactor dropped validate(), so empty forms were saved.
    testWidgets('does not save while required fields are empty', (tester) async {
      final repository = await _pumpForm(tester);

      await _save(tester);

      expect(find.text('Description is required'), findsOneWidget);
      expect(find.text('Amount is required'), findsOneWidget);
      expect(repository.calls, isEmpty);
      expect(find.text('Create Transaction'), findsOneWidget);
    });

    testWidgets('rejects a zero amount', (tester) async {
      final repository = await _pumpForm(tester);

      await tester.enterText(_descriptionField, 'Lunch');
      await tester.enterText(_amountField, '0');
      await _save(tester);

      expect(find.text('Amount must be greater than 0'), findsOneWidget);
      expect(repository.calls, isEmpty);
    });

    testWidgets('formats the amount with thousands separators while typing', (tester) async {
      await _pumpForm(tester);

      await tester.enterText(_amountField, '1234567.891');

      expect(tester.widget<TextFormField>(_amountField).controller!.text, '1,234,567.89');
    });

    testWidgets('saves a valid expense and returns to the previous page', (tester) async {
      final repository = await _pumpForm(tester);

      await tester.enterText(_descriptionField, 'Lunch');
      await tester.enterText(_amountField, '1234.5');
      await _save(tester);

      final saved = repository.items.single;
      expect(saved.description, 'Lunch');
      expect(saved.amount, 1234.5);
      expect(saved.isExpense, isTrue);
      expect(saved.notes, isNull);
      expect(saved.uuid, isNotEmpty);
      expect(find.text('Home page'), findsOneWidget);
    });

    testWidgets('saves an income when the switch is turned off', (tester) async {
      final repository = await _pumpForm(tester);

      await tester.enterText(_descriptionField, 'Salary');
      await tester.enterText(_amountField, '5000');
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await _save(tester);

      expect(repository.items.single.isExpense, isFalse);
    });

    testWidgets('stays open when saving fails', (tester) async {
      await _pumpForm(tester, failure: const DatabaseFailure('Failed to create transaction'));

      await tester.enterText(_descriptionField, 'Lunch');
      await tester.enterText(_amountField, '10');
      await _save(tester);

      expect(find.text('Create Transaction'), findsOneWidget);
      expect(find.text('Home page'), findsNothing);
    });
  });

  group('edit', () {
    final recent = DateTime.now().subtract(const Duration(days: 1));

    testWidgets('opens pre-filled with the Edit title', (tester) async {
      await _pumpForm(
        tester,
        transaction: buildTransaction(dateTime: recent, notes: 'Weekly shop'),
      );

      expect(find.text('Edit Transaction'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('1,234.50'), findsOneWidget);
      expect(find.text('Weekly shop'), findsOneWidget);
    });

    testWidgets('updates the existing transaction instead of creating one', (tester) async {
      final repository = await _pumpForm(tester, transaction: buildTransaction(dateTime: recent));

      await tester.enterText(_descriptionField, 'Supermarket');
      await _save(tester);

      expect(repository.calls, ['update:tx-1']);
      expect(repository.items.single.description, 'Supermarket');
      expect(repository.items.single.amount, 1234.5);
    });

    // Regression: clearing the notes field used to keep the old notes.
    testWidgets('saves without notes when the notes field is cleared', (tester) async {
      final repository = await _pumpForm(
        tester,
        transaction: buildTransaction(dateTime: recent, notes: 'Old note'),
      );

      await tester.enterText(_notesField, '');
      await _save(tester);

      expect(repository.items.single.notes, isNull);
    });

    testWidgets('allows changing the date and time of a recent transaction', (tester) async {
      await _pumpForm(tester, transaction: buildTransaction(dateTime: recent));

      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
      expect(find.byIcon(Icons.watch_later_outlined), findsOneWidget);
    });

    testWidgets('shows the date and time read-only for transactions older than the edit window', (tester) async {
      final old = DateTime.now().subtract(const Duration(days: 10));
      await _pumpForm(tester, transaction: buildTransaction(dateTime: old));

      expect(find.byIcon(Icons.calendar_month), findsNothing);
      expect(find.byIcon(Icons.watch_later_outlined), findsNothing);
      expect(find.textContaining(old.year.toString()), findsOneWidget);
    });
  });
}
