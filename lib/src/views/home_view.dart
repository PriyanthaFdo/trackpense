import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpense/core/navigation/route_names.dart';
import 'package:trackpense/data/blocs/ui_bloc.dart';
import 'package:trackpense/features/transactions/presentation/blocs/transaction_bloc.dart';
import 'package:trackpense/src/widgets/item_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
            onPressed: () => context.pushNamed(RouteNames.paymentForm),
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
              return const Center(child: Text('No transactions yet'));
            }
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ItemCard(
                  date: transaction.dateTime,
                  description: transaction.description,
                  amount: transaction.amount,
                  isExpense: transaction.isExpense,
                  onTap: () => context.pushNamed(
                    RouteNames.paymentForm,
                    extra: transaction,
                  ),
                  notes: transaction.notes,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
