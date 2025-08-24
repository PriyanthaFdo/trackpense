import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpense/data/blocs/payment_bloc.dart';
import 'package:trackpense/src/widgets/loading.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final PaymentBloc _paymentBloc;

  @override
  void initState() {
    super.initState();
    _paymentBloc = context.read<PaymentBloc>();
    _paymentBloc.add(GetAllPaymentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _paymentBloc.add(
          CreatePaymentEvent(
            dateTime: DateTime.now(),
            description: 'Test',
            amount: 100.0,
            isExpense: true,
          ),
        ),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (_, __) {},
        builder: (context, state) {
          if (state is PaymentLoadedState) {
            return ListView.builder(
              itemCount: state.payments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(state.payments[index].description),
                  subtitle: Text(state.payments[index].amount.toString()),
                );
              },
            );
          } else {
            return loading();
          }
        },
      ),
    );
  }
}
