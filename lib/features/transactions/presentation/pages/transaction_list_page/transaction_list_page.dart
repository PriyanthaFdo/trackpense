import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trackpense/core/navigation/route_names.dart';
import 'package:trackpense/core/presentation/blocs/ui_bloc.dart';
import 'package:trackpense/core/widgets/common/feedback/empty_state_widget.dart';
import 'package:trackpense/features/transactions/presentation/blocs/transaction_bloc.dart';
import 'package:trackpense/features/transactions/presentation/pages/transaction_list_page/widgets/summary_bar.dart';
import 'package:trackpense/features/transactions/presentation/pages/transaction_list_page/widgets/transaction_card.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(TransactionLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackPense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.pushNamed(RouteNames.transactionForm),
          ),
        ],
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          final uiBloc = context.read<UiBloc>();
          if (state is TransactionLoadingState) {
            uiBloc.add(UiLoadingEvent());
          } else if (state is TransactionErrorState) {
            uiBloc.add(
              UiErrorEvent(
                message: state.message,
                error: Exception(state.message),
                stackTrace: StackTrace.current,
              ),
            );
          } else {
            uiBloc.add(UiReadyEvent());
          }
        },
        // Ready and Error states come from create/update/delete and carry no list,
        // so keep showing the last loaded list instead of rebuilding to blank.
        buildWhen: (previous, current) => current is TransactionLoadingState || current is TransactionLoadedState,
        builder: (context, state) {
          if (state is TransactionLoadedState) {
            final transactions = state.transactions;
            if (transactions.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                message: 'No transactions yet',
              );
            }
            final income = transactions.fold<double>(0, (sum, t) => sum + (t.isExpense ? 0 : t.amount));
            final expense = transactions.fold<double>(0, (sum, t) => sum + (t.isExpense ? t.amount : 0));
            return Column(
              children: [
                SummaryBar(
                  income: income,
                  expense: expense,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return TransactionCard(
                        date: transaction.dateTime,
                        description: transaction.description,
                        amount: transaction.amount,
                        isExpense: transaction.isExpense,
                        onTap: () => context.pushNamed(
                          RouteNames.transactionForm,
                          extra: transaction,
                        ),
                        notes: transaction.notes,
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
