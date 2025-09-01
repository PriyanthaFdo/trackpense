import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpense/core/extensions/color_extension.dart';
import 'package:trackpense/core/extensions/double_extension.dart';
import 'package:trackpense/core/extensions/string_extension.dart';
import 'package:trackpense/core/utils/comma_seperated_decimal_text_input_formatter.dart';
import 'package:trackpense/core/utils/decimal_text_input_formatter.dart';
import 'package:trackpense/data/blocs/payment_bloc.dart';
import 'package:trackpense/data/constants/kjp_colors.dart';
import 'package:trackpense/src/widgets/item_card.dart';
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
        onPressed: _showCreatePaymentDialog,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (_, __) {},
        builder: (context, state) {
          if (state is PaymentLoadedState) {
            return ListView.builder(
              itemCount: state.payments.length,
              itemBuilder: (context, index) {
                final payment = state.payments[index];
                return ItemCard(
                  amount: payment.amount,
                  date: payment.date,
                  description: payment.description,
                  isExpense: payment.isExpense,
                  onTap: () => _showCreatePaymentDialog(
                    uuid: payment.uuid,
                    description: payment.description,
                    amount: payment.amount,
                    isExpense: payment.isExpense,
                  ),
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

  void _showCreatePaymentDialog({
    String? uuid,
    String? description,
    double? amount,
    bool isExpense = true,
  }) {
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    descriptionController.text = description ?? '';
    amountController.text = amount?.toCommaString() ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Transaction'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUnfocus,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      DecimalTextInputFormatter(decimalDigits: 2),
                      CommaSeparatedInputFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Expense / Income toggle using parent RadioGroup
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Income'),
                          const SizedBox(width: 12),
                          Switch.adaptive(
                            value: isExpense,
                            activeTrackColor: KjpColors.expense.darken(0.2),
                            inactiveTrackColor: KjpColors.income.darken(0.2),
                            inactiveThumbColor: Colors.white,
                            thumbIcon: const WidgetStatePropertyAll(
                              Icon(
                                Icons.circle,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            onChanged: (val) => setState(() => isExpense = val),
                          ),
                          const SizedBox(width: 12),
                          const Text('Expense'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (uuid == null) {
                    _paymentBloc.add(
                      CreatePaymentEvent(
                        description: descriptionController.text,
                        amount: amountController.text.toCleanDouble(),
                        isExpense: isExpense,
                      ),
                    );
                  } else {
                    _paymentBloc.add(
                      UpdatePaymentEvent(
                        uuid: uuid,
                        description: descriptionController.text,
                        amount: amountController.text.toCleanDouble(),
                        isExpense: isExpense,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
