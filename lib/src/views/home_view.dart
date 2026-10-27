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
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoadingState) {
            context.read<UiBloc>().add(UiLoadingEvent());
            return const SizedBox.shrink();
          } else if (state is TransactionErrorState) {
            context.read<UiBloc>().add(
              UiErrorEvent(
                message: state.message,
                error: Exception(state.message),
                stackTrace: StackTrace.current,
              ),
            );
            return const SizedBox.shrink();
          } else if (state is TransactionLoadedState) {
            context.read<UiBloc>().add(UiReadyEvent());
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
