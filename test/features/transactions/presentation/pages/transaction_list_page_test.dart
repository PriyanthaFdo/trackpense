import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/error/failures.dart';
import 'package:trackpense/core/presentation/blocs/ui_bloc.dart';
import 'package:trackpense/features/transactions/domain/entities/transaction.dart';
import 'package:trackpense/features/transactions/presentation/blocs/transaction_bloc.dart';
import 'package:trackpense/features/transactions/presentation/pages/transaction_list_page.dart';
import 'package:trackpense/features/transactions/presentation/widgets/transaction_card.dart';

import '../../../../helpers/fake_transaction_repository.dart';
import '../../../../helpers/transaction_bloc_factory.dart';
import '../../../../helpers/transaction_fixtures.dart';

class _Harness {
  _Harness(this.repository);

  final FakeTransactionRepository repository;
  late final TransactionBloc transactionBloc;
  late final UiBloc uiBloc;
}

Future<_Harness> _pumpPage(WidgetTester tester, [List<Transaction> existing = const []]) async {
  final harness = _Harness(FakeTransactionRepository(existing));

  // The providers create and close the blocs. Closing them from addTearDown
  // instead would hang, because widget tests run in a fake-async zone.
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => harness.uiBloc = UiBloc(), lazy: false),
        BlocProvider(create: (_) => harness.transactionBloc = buildTransactionBloc(harness.repository), lazy: false),
      ],
      child: const MaterialApp(home: TransactionListPage()),
    ),
  );
  await tester.pumpAndSettle();
  return harness;
}

void main() {
  testWidgets('shows the empty state when there are no transactions', (tester) async {
    await _pumpPage(tester);

    expect(find.text('No transactions yet'), findsOneWidget);
    expect(find.byType(TransactionCard), findsNothing);
  });

  testWidgets('shows a card per transaction', (tester) async {
    await _pumpPage(tester, [
      buildTransaction(uuid: 'a'),
      buildTransaction(uuid: 'b', description: 'Salary', isExpense: false),
    ]);

    expect(find.byType(TransactionCard), findsNWidgets(2));
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
  });

  testWidgets('tells UiBloc loading has finished once data arrives', (tester) async {
    final harness = await _pumpPage(tester);

    expect(harness.uiBloc.state, isA<UiReadyState>());
  });

  testWidgets('updates when a transaction is added', (tester) async {
    final harness = await _pumpPage(tester, [buildTransaction(uuid: 'a')]);

    harness.transactionBloc.add(TransactionCreateEvent(buildTransaction(uuid: 'b')));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionCard), findsNWidgets(2));
  });

  // Regression: the list used to go blank after a failed save, because Error
  // states carry no list and the page rebuilt on every state.
  testWidgets('keeps showing the list and reports the error when a save fails', (tester) async {
    final harness = await _pumpPage(tester, [buildTransaction()]);
    harness.repository.failure = const DatabaseFailure('Failed to create transaction');

    harness.transactionBloc.add(TransactionCreateEvent(buildTransaction(uuid: 'b')));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionCard), findsOneWidget);
    expect(harness.uiBloc.state, isA<UiErrorState>().having((s) => s.message, 'message', 'Failed to create transaction'));
  });
}
