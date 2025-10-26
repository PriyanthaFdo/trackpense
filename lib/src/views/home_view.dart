import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpense/data/blocs/payment_bloc.dart';
import 'package:trackpense/data/blocs/ui_bloc.dart';
import 'package:trackpense/data/models/payment_model.dart';
import 'package:trackpense/src/router/route_names.dart';
import 'package:trackpense/src/widgets/item_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final PaymentBloc _paymentBloc;
  late final UiBloc _uiBloc;

  @override
  void initState() {
    super.initState();
    _paymentBloc = context.read<PaymentBloc>();
    _uiBloc = context.read<UiBloc>();

    _paymentBloc.add(GetAllPaymentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.paymentForm),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (_, state) {
          if (state is PaymentLoadingState) {
            _uiBloc.add(UiLoadingEvent());
          } else {
            _uiBloc.add(UiReadyEvent());
          }

          if (state is PaymentErrorState) {
            _uiBloc.add(
              UiErrorEvent(
                message: state.message,
                error: state.error,
                stackTrace: state.stackTrace,
              ),
            );
          }
        },
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.payments.length,
            itemBuilder: (context, index) {
              final payment = state.payments[index];
              return ItemCard(
                amount: payment.amount,
                date: payment.date,
                description: payment.description,
                isExpense: payment.isExpense,
                notes: payment.notes,
                onTap: () => context.pushNamed(
                  RouteNames.paymentForm,
                  extra: PaymentModel.fromPaymentData(payment),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
