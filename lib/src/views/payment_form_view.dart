import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpense/core/extensions/color_extension.dart';
import 'package:trackpense/core/extensions/datetime_extension.dart';
import 'package:trackpense/core/extensions/double_extension.dart';
import 'package:trackpense/core/extensions/string_extension.dart';
import 'package:trackpense/core/utils/comma_seperated_decimal_text_input_formatter.dart';
import 'package:trackpense/core/utils/decimal_text_input_formatter.dart';
import 'package:trackpense/data/blocs/payment_bloc.dart';
import 'package:trackpense/data/constants/kjp_colors.dart';
import 'package:trackpense/data/models/payment_model.dart';
import 'package:trackpense/src/widgets/my_widgets/my_text_form_field.dart';

class PaymentFormView extends StatefulWidget {
  const PaymentFormView({super.key, this.payment});

  final PaymentModel? payment;

  @override
  State<PaymentFormView> createState() => _PaymentFormViewState();
}

class _PaymentFormViewState extends State<PaymentFormView> {
  late final PaymentBloc _paymentBloc;

  @override
  void initState() {
    super.initState();
    _paymentBloc = context.read<PaymentBloc>();
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.payment == null;
    if (!isCreate) assert(widget.payment?.uuid != null);

    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final dateTimeNotifier = ValueNotifier<DateTime>(widget.payment?.dateTime ?? DateTime.now());

    descriptionController.text = widget.payment?.description ?? '';
    amountController.text = widget.payment?.amount.toCommaString() ?? '';
    notesController.text = widget.payment?.notes ?? '';
    bool isExpense = widget.payment?.isExpense ?? true;

    return Scaffold(
      appBar: AppBar(title: Text('${isCreate ? 'Create' : 'Edit'} Transaction')),
      body: Column(
        children: [
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUnfocus,
            child: SingleChildScrollView(
              child: BlocListener<PaymentBloc, PaymentState>(
                listener: (context, state) {
                  if (state is PaymentReadyState) {
                    context.pop();
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Description
                    MyTextFormField(
                      controller: descriptionController,
                      showTextLengthCounter: true,
                      labelText: 'Description',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        return null;
                      },
                    ),

                    // Amount
                    MyTextFormField(
                      controller: amountController,
                      labelText: 'Amount',
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

                    _dateTimeSelectors(dateTimeNotifier),
                    const SizedBox(height: 12),

                    // Notes
                    MyTextFormField(
                      controller: notesController,
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 6,
                      hintText: 'Enter your text here...',
                      outlineBOrder: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (isCreate) {
                      _paymentBloc.add(
                        CreatePaymentEvent(
                          description: descriptionController.text,
                          amount: amountController.text.toCleanDouble(),
                          isExpense: isExpense,
                          dateTime: dateTimeNotifier.value,
                          notes: notesController.text,
                        ),
                      );
                    } else {
                      _paymentBloc.add(
                        UpdatePaymentEvent(
                          uuid: widget.payment!.uuid!,
                          description: descriptionController.text,
                          amount: amountController.text.toCleanDouble(),
                          isExpense: isExpense,
                          dateTime: dateTimeNotifier.value,
                          notes: notesController.text,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateTimeSelectors(ValueNotifier<DateTime> dateTimeNotifier) {
    final now = DateTime.now();
    final displayedDateTime = dateTimeNotifier.value;

    if (now.difference(displayedDateTime).inDays > 7) {
      // If more than 7 days passed after set date, cannot edit dateTime
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(displayedDateTime.format(format: 'dd/MMM/yyyy')),
          Text(displayedDateTime.format(format: 'hh:mm a')),
        ],
      );
    } else {
      return Column(
        children: [
          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder(
                valueListenable: dateTimeNotifier,
                builder: (_, value, __) => Text(dateTimeNotifier.value.format(format: 'dd/MMM/yyyy')),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: KjpColors.primary.lighten(0.8)),
                child: const Icon(Icons.calendar_month),
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: dateTimeNotifier.value,
                    firstDate: DateTime.now().subtract(const Duration(days: 7)),
                    lastDate: DateTime.now(),
                  );

                  if (selectedDate != null) {
                    dateTimeNotifier.value = dateTimeNotifier.value.copyWith(
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
                valueListenable: dateTimeNotifier,
                builder: (_, value, __) => Text(dateTimeNotifier.value.format(format: 'hh:mm a')),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: KjpColors.primary.lighten(0.8)),
                child: const Icon(Icons.watch_later_outlined),
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialEntryMode: TimePickerEntryMode.input,
                    initialTime: TimeOfDay.fromDateTime(dateTimeNotifier.value),
                  );

                  if (selectedTime != null) {
                    dateTimeNotifier.value = dateTimeNotifier.value.copyWith(
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
        ],
      );
    }
  }
}
