import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpense/core/config/app_config.dart';
import 'package:trackpense/core/extensions/color_extensions.dart';
import 'package:trackpense/core/extensions/datetime_extensions.dart';
import 'package:trackpense/core/extensions/double_extensions.dart';
import 'package:trackpense/core/extensions/string_extensions.dart';
import 'package:trackpense/core/theme/app_colors.dart';
import 'package:trackpense/core/utils/formatters/currency_formatter.dart';
import 'package:trackpense/core/utils/formatters/decimal_input_formatter.dart';
import 'package:trackpense/core/utils/validators/amount_validator.dart';
import 'package:trackpense/core/utils/validators/description_validator.dart';
import 'package:trackpense/core/widgets/common/inputs/app_text_field.dart';
import 'package:trackpense/features/transactions/domain/entities/transaction.dart';
import 'package:trackpense/features/transactions/presentation/blocs/transaction_bloc.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key, this.transaction});

  final Transaction? transaction;

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TransactionBloc _transactionBloc;
  late final TextEditingController descriptionController;
  late final TextEditingController amountController;
  late final TextEditingController notesController;
  late final ValueNotifier<DateTime> dateTimeNotifier;
  late bool isExpense = true;

  @override
  void initState() {
    super.initState();
    _transactionBloc = context.read<TransactionBloc>();
    descriptionController = TextEditingController();
    amountController = TextEditingController();
    notesController = TextEditingController();
    dateTimeNotifier = ValueNotifier(DateTime.now());

    if (widget.transaction != null) {
      descriptionController.text = widget.transaction!.description;
      amountController.text = widget.transaction!.amount.toCommaString();
      isExpense = widget.transaction!.isExpense;
      dateTimeNotifier.value = widget.transaction!.dateTime;
      notesController.text = widget.transaction!.notes ?? '';
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    notesController.dispose();
    dateTimeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.transaction == null;

    return Scaffold(
      appBar: AppBar(title: Text('${isCreate ? 'Create' : 'Edit'} Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUnfocus,
                child: SingleChildScrollView(
                  child: BlocListener<TransactionBloc, TransactionState>(
                    listener: (context, state) {
                      if (state is TransactionReadyState) {
                        context.pop();
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Description
                        AppTextFormField(
                          controller: descriptionController,
                          showTextLengthCounter: true,
                          labelText: 'Description',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: DescriptionValidator.validate,
                        ),

                        // Amount
                        AppTextFormField(
                          controller: amountController,
                          labelText: 'Amount',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            DecimalTextInputFormatter(decimalDigits: 2),
                            CommaSeparatedInputFormatter(),
                          ],
                          validator: AmountValidator.validate,
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
                                  activeTrackColor: AppColors.expense.darken(0.2),
                                  inactiveTrackColor: AppColors.income.darken(0.2),
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
                        AppTextFormField(
                          controller: notesController,
                          keyboardType: TextInputType.multiline,
                          minLines: 3,
                          maxLines: 6,
                          hintText: 'Enter your text here...',
                          outlineBorder: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
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
                style: TextButton.styleFrom(backgroundColor: AppColors.primary.lighten(0.8)),
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
                style: TextButton.styleFrom(backgroundColor: AppColors.primary.lighten(0.8)),
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final amount = amountController.text.toCleanDouble();
    final transaction = Transaction(
      uuid: widget.transaction?.uuid ?? AppConfig.uuid.v4(),
      description: descriptionController.text,
      amount: amount,
      isExpense: isExpense,
      dateTime: dateTimeNotifier.value,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );

    if (widget.transaction == null) {
      _transactionBloc.add(TransactionCreateEvent(transaction));
    } else {
      _transactionBloc.add(TransactionUpdateEvent(transaction));
    }
  }
}
