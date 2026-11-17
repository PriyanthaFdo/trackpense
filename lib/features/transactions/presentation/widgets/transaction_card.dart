import 'package:flutter/material.dart';
import 'package:trackpense/core/extensions/color_extensions.dart';
import 'package:trackpense/core/extensions/datetime_extensions.dart';
import 'package:trackpense/core/extensions/double_extensions.dart';
import 'package:trackpense/core/theme/app_colors.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.date,
    required this.description,
    required this.amount,
    required this.onTap,
    required this.isExpense,
    this.notes,
  });

  final DateTime date;
  final String description;
  final double amount;
  final VoidCallback onTap;
  final bool isExpense;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isExpense ? AppColors.expense.lighten(0.8) : AppColors.income.lighten(0.8),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date: at least 55x55, but grows with the system text size instead of overflowing
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 55, maxWidth: 55, minHeight: 55),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      date.format(format: 'E'),
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      date.format(format: 'dd'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 0.7,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.format(format: 'MMMM'),
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Time and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date.format(format: 'hh:mm a'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      description,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notes != null && notes!.isNotEmpty)
                      Text(
                        _singleLineWithEllipsis(notes!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),

              // Amount
              Center(
                child: Text(
                  amount.toCommaString(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _singleLineWithEllipsis(String text) {
  final hasNewLine = text.contains('\n');

  final firstLine = text.split('\n').first;

  return hasNewLine ? '$firstLine .....' : firstLine;
}
