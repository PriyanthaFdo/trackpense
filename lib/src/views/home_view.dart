import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpense/core/extensions/color_extension.dart';
import 'package:trackpense/core/extensions/datetime_extension.dart';
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
                  notes: payment.notes,
                  onTap: () => _showCreatePaymentDialog(
                    uuid: payment.uuid,
                    description: payment.description,
                    amount: payment.amount,
                    isExpense: payment.isExpense,
                    dateTime: payment.date,
                    notes: payment.notes,
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
    DateTime? dateTime,
    String? notes,
  }) {
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    descriptionController.text = description ?? '';
    amountController.text = amount?.toCommaString() ?? '';
    notesController.text = notes ?? '';
    final displayDateTime = ValueNotifier<DateTime>(dateTime ?? DateTime.now());

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
                  // Description
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),

                  // Amount
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

                  // Expense/ Income Switch
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
                  const SizedBox(height: 12),

                  // Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: displayDateTime,
                        builder: (_, value, __) => Text(displayDateTime.value.format(format: 'dd/MMM/yyyy')),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(backgroundColor: KjpColors.primary.lighten(0.8)),
                        child: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: displayDateTime.value,
                            firstDate: DateTime.now().subtract(const Duration(days: 7)),
                            lastDate: DateTime.now(),
                          );

                          if (selectedDate != null) {
                            displayDateTime.value = displayDateTime.value.copyWith(
                              year: selectedDate.year,
                              month: selectedDate.month,
                              day: selectedDate.day,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: displayDateTime,
                        builder: (_, value, __) => Text(displayDateTime.value.format(format: 'hh:mm a')),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(backgroundColor: KjpColors.primary.lighten(0.8)),
                        child: const Icon(Icons.watch_later_outlined),
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialEntryMode: TimePickerEntryMode.input,
                            initialTime: TimeOfDay.fromDateTime(displayDateTime.value),
                          );

                          if (selectedTime != null) {
                            displayDateTime.value = displayDateTime.value.copyWith(
                              hour: selectedTime.hour,
                              minute: selectedTime.minute,
                              second: 0,
                              millisecond: 0,
                              microsecond: 0,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Notes
                  TextField(
                    controller: notesController,
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Enter your text here...',
                      border: OutlineInputBorder(),
                    ),
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
                        dateTime: displayDateTime.value,
                        notes: notesController.text,
                      ),
                    );
                  } else {
                    _paymentBloc.add(
                      UpdatePaymentEvent(
                        uuid: uuid,
                        description: descriptionController.text,
                        amount: amountController.text.toCleanDouble(),
                        isExpense: isExpense,
                        dateTime: displayDateTime.value,
                        notes: notesController.text,
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
